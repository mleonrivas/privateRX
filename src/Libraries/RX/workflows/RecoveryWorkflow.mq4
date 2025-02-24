#property library RecoveryWorkflow
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IWorkflow.mq4"
#include "..\\common\\Operation.mq4"
#include "..\\common\\List.mq4"
#include "..\\common\\TrendUtils.mq4"
#include "..\\common\\MonetaryManagement.mq4"
#include "..\\orders\\IOrder.mq4"
#include "..\\orders\\MarketOrder.mq4"
#include "..\\orders\\PartialCloseVirtualOrder.mq4"
#include "..\\orders\\EspecialPartialOrder.mq4"
#include "..\\targets\\SmartTargetSelector.mq4"
#include "..\\targets\\TargetPainter.mq4"
#include "..\\events\\RecoveryListenerRegistry.mq4"

extern int RW_LoopDivisions = 13;
extern int RW_MaxStepsPerRecovery = 5;
extern int RW_MaxNestedRecoveries = 0;
extern int RW_AcceptLossesOnEnd = 1;
extern double RW_TrailingBufferFactor = 0.3;
extern string RW_BehaviorOnReachingGlobalRisk = "CLOSE_ALL|COMPENSATE|DO_NOTHING";
extern int RW_RecordStats = 0;

enum State {
   STARTED,
   // Just opened a new order, and now we wait to hit targets: TP closes the op, SL triggers recovery.
   WAITING_TO_HIT_TARGETS,
   // Price hit TP, now doing trailing to leverage trend. 
   TRAILING,
   // End of loop: Reached the max ops, paired buy and sell lots, and now waiting for a thread signal to start a nested loop. 
   RECOVERY_WAITING_FOR_THREAD_SIGNAL,
   // created a nested loop and waiting for it to complete. 
   RECOVERY_WAITING_FOR_NESTED_LOOP,
   // Completed, all positions closed.
   COMPLETE,
   // FAILED means that the recovery hit one of the limitations that indicates that is not working properly and we should stop automated operations.
   FAILED
};

class RecoveryWorkflow : public IWorkflow {
   private:
      // The Strategy used to define target distances
      ITargetSelector *targetSelector;
      
      // target distances, calculated via TargetSelector.
      double currentTargetDistance;
      double currentCoverDistance;

      // threadId identifies which thread triggered the workflow.
      int threadId;
      // represents the nested recovery loop
      RecoveryWorkflow *nestedLoop;
      // represents the parent recovery loop in a nested recovery loop.
      RecoveryWorkflow *parentLoop;
      // indicates the depth of this loop (0,1,2...), it cna go from 0 to maxNestedRecoveries
      int depthLevel;

      // represents the current state of the loop
      State state;
      // number of operations that we have executed in this loop
      int currentStep;
      // take profit target for current state of the loop
      double currentTarget;
      // trailing target
      double currentTrailingTarget;
      // trailing distance that we allow for price to bounce.
      double trailingBuffer;
      // cover loss price for the current state of the loop
      double currentCover;
      // total bought lots in the current state of the loop
      int boughtLots;
      // total sold lots in the curent state of the loop
      int soldLots;
      // lots used for starting nested loops
      int lotsForNestedLoops;

      // init lots for a nested loop, calculated from open lots divided by loopDivisions
      int initLots;

      // keep track of all orders created within this workflow.
      List<IOrder> *buyOrders;
      List<IOrder> *sellOrders;
      
      void initRecoveryWorkflow(Operation op, double askPrice, double bidPrice) {
         Print("Starting workflow at depth ", this.depthLevel);
         
         if (this.depthLevel > 0) {
            // we are in a nested loop, first op is a partial close.
            executePartialCloseOp(op, askPrice, bidPrice, this.initLots);
            this.state = WAITING_TO_HIT_TARGETS;
            return;
         } 
         double price = (askPrice + bidPrice)/2.0;
         // we are in a top-level recovery, first operation is a new position.
         int lots = MonetaryManagement::get().calculateLots(op, 0, 0, this.currentCoverDistance, this.currentTargetDistance, this.depthLevel, this.currentStep, price, NULL, NULL);
         
         if (placeNewOrder(op, askPrice, bidPrice, lots)) {
            this.state = WAITING_TO_HIT_TARGETS;
         } else {
            this.state = FAILED;
         }
      }
      
      bool passNextStepFilters() {
         if (this.currentStep >= RW_MaxStepsPerRecovery) {
            // if we reached the end of the loop, we do not need to wait for the filters.
            return true;
         }
         
         Operation op = getNextOp();
         int trend = calculateUpperTfTrend(this.currentStep+1);
         int svlev = this.depthLevel * 10 + this.currentStep;
         bool doNotPassFilter = svlev > 1 && ((op == BUY && trend != 1) || (op == SELL && trend != -1));
         return !doNotPassFilter;
      }
      
      int getImbalance() {
         return this.boughtLots - this.soldLots;
      }
      
      Operation getNextOp() {
         int imbalance = getImbalance();
         return imbalance > 0 ? SELL : BUY;
      }
      
      bool levelBuyAndSellOrders(double askPrice, double bidPrice) {
         int imbalance = getImbalance();
         Operation op = getNextOp();
         int lots = MathAbs(imbalance);
         return placeNewOrder(op, askPrice, bidPrice, lots);
      }

      void nextRecoveryStep(double askPrice, double bidPrice) {
         Operation op = getNextOp();

         // CASE 1: We need to cover another position, and we are still within the allowed number of steps.
         if (this.currentStep < RW_MaxStepsPerRecovery) {
            updateTargetDistances();
            
            int lots = MonetaryManagement::get().calculateLots(op, this.boughtLots, this.soldLots, this.currentCoverDistance, this.currentTargetDistance, this.depthLevel, this.currentStep + 1, (askPrice+bidPrice)/2.0, this.buyOrders, this.sellOrders);
            
            if (placeNewOrder(op, askPrice, bidPrice, lots)) {
               this.state = WAITING_TO_HIT_TARGETS;
               this.currentStep = this.currentStep + 1;
            } else {
               this.state = FAILED;
            }
            return;
         }
         
         
         // CASE 2: No more steps (new covers) allowed, so we have to check whether more nested loops are allowed or not:
         if (this.depthLevel < RW_MaxNestedRecoveries) {
            // another nested loop is allowed, so level lots and wait for another signal.
            bool leveled = levelBuyAndSellOrders(askPrice, bidPrice);
            if (leveled) {
               // calculate the lots for all nested workflows
               this.lotsForNestedLoops = MonetaryManagement::get().normalizeLots(this.boughtLots / RW_LoopDivisions);
               this.state = RECOVERY_WAITING_FOR_THREAD_SIGNAL;
            } else {
               this.state = FAILED;
            }
            return;
         }
         // CASE 3: no more nested loops allowed
         if(RW_AcceptLossesOnEnd > 0) {
            // accept losses and continue
            this.closePositions(askPrice, bidPrice);
            moveToComplete();
            return;
         } else {
            //fail
            Print("No more nested loops allowed. Failing... ", this.depthLevel);
            this.state = FAILED;
         }
      }
      
      void closePositionsWithProfit(double askPrice, double bidPrice, bool inProfit) {
         for (int i=0; i<this.sellOrders.size(); i++) {
            IOrder *od = this.sellOrders.get(i);
            if (od.isStillOpen() && od.isInProfit(askPrice, bidPrice) == inProfit) {
               od.close();
            }
         }
         for (int i=0; i<this.buyOrders.size(); i++) {
            IOrder *od = this.buyOrders.get(i);
            if (od.isStillOpen() && od.isInProfit(askPrice, bidPrice) == inProfit) {
               od.close();
            }
         }
      }

      void closePositions(double askPrice, double bidPrice) {
         this.closePositionsWithProfit(askPrice, bidPrice, true);
         this.closePositionsWithProfit(askPrice, bidPrice, false);
      }

      void updateLotsAndTargets(Operation op, double askPrice, double bidPrice, int lots) {
         double price = (askPrice + bidPrice) / 2.0;
         
         if (op == BUY) {
            this.currentTarget = price + this.currentTargetDistance;
            this.currentCover = price - this.currentCoverDistance;
            this.boughtLots = this.boughtLots + lots;
         } else if (op == SELL) {
            this.currentTarget = price - this.currentTargetDistance;
            this.currentCover = price + this.currentCoverDistance;
            this.soldLots = this.soldLots + lots;
         }
         renderTargets(this.currentTarget, this.currentCover);
      }

      void executePartialCloseOp(Operation op, double askPrice, double bidPrice, int lots) {
         int magic = this.threadId * 10000 + this.depthLevel*1000 + this.currentStep*100 + 90;
         int lotsMarket = MonetaryManagement::get().normalizeLots(lots/4);
         IOrder *esp = new EspecialPartialOrder(op, this.parentLoop.buyOrders, this.parentLoop.sellOrders, lots, lotsMarket, magic);
         esp.send();
         if (op == BUY) {
            this.buyOrders.add(esp);
         } else {
            this.sellOrders.add(esp);
         }
         updateLotsAndTargets(op, askPrice, bidPrice, lots+lotsMarket);
      }
      
      bool placeNewOrder(Operation op, double askPrice, double bidPrice, int lots) {
         if (lots == 0) {
            Print("IGNORE PLACING NEW ORDER WITH 0 LOTS");
            return true;
         }
         double price = (askPrice + bidPrice) / 2.0;
         
         int magic = this.threadId * 1000 + this.depthLevel*100 + this.currentStep;
         IOrder *od = new MarketOrder(op, lots, magic);
         bool succeeded = od.send();
         if (op == BUY && succeeded) {
            // valid buy order
            this.buyOrders.add(od);
         } else if (op == SELL && succeeded) {
            // valid sell order
            this.sellOrders.add(od);
         }
         updateLotsAndTargets(op, askPrice, bidPrice, lots);
         
         return succeeded;
      }

      int delegateTickToNestedLoop(double askPrice, double bidPrice, Operation op) {
         if (this.nestedLoop == NULL || this.nestedLoop.hasFinished()) {
            return 0;
         }
         int res = this.nestedLoop.processTickAndOp(askPrice, bidPrice, op);
         if (this.nestedLoop.isCompleted()) {
            if(this.soldLots == 0 && this.boughtLots == 0) {
               // we are done with this recovery workflow
               moveToComplete();
            } else {
               // we still have nested loops to go through
               this.state = RECOVERY_WAITING_FOR_THREAD_SIGNAL;
            }
            releaseNestedWorkflow();
         } else if (this.nestedLoop.isFailed()) {
            Print("Nested loop FAILED, marking parent loop as FAILED too");
            this.state = FAILED;
            releaseNestedWorkflow();
         }
         return res;
      }

      /**
       * return true if price hit the take profit target:
      */
      bool hitTarget(double price) {
         bool hitTarget = false;
         if (this.boughtLots > this.soldLots) {
            // lots imbalanced to buy (more loaded in the buy leg, so eq to a buy op)
            hitTarget = price >= this.currentTarget;
         } else if (this.boughtLots < this.soldLots) {
            // lots imbalanced to sell (more loaded in the sell leg, so eq to a sell op)
            hitTarget = price <= this.currentTarget;
         }
         return hitTarget;
      }
      
      /**
       * return true if price hit the take profit target:
      */
      bool hitMaxRisk() {
         return MonetaryManagement::get().riskIsBeyondThreshold();
      }

      /**
       * return true if price hit the cover target:
      */
      bool hitCover(double price) {
         return hitSupportLevel(price, this.currentCover);
      }
      
      bool changesTrend(double price) {
         int imbalance = getImbalance();
         double ema25_0 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 0);
         double ema25_1 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 1);
         double ema25_2 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 2);
         
         bool result = false;
         if (imbalance > 0) {
            result = price < ema25_0 && price < ema25_1 && price < ema25_2;
         } else if (imbalance < 0) {
            result = price > ema25_0 && price > ema25_1 && price > ema25_2;
         }
         if(result) {
            Print("P=",price,"; E25-0=", ema25_0, "; E25_1=", ema25_1, " (I=",imbalance, ")");
         }
         return result;
      }
      
      bool hitSupportLevel(double price, double level) {
         bool hitLevel = false;
         if (this.boughtLots > this.soldLots) {
            // lots imbalanced to buy (more loaded in the buy leg, so eq to a buy op)
            hitLevel = price <= level;
         } else if (this.boughtLots < this.soldLots) {
            // lots imbalanced to sell (more loaded in the sell leg, so eq to a sell op)
            hitLevel = price >= level;
         }
         return hitLevel;
      }

      void updateTargetDistances() {
         Distances dist = this.targetSelector.getDistances(this.depthLevel, this.currentStep);
         this.currentCoverDistance = dist.coverDistance;
         this.currentTargetDistance = dist.targetDistance;
      }

      void moveToComplete() {
         this.state = COMPLETE;
         RecoveryListenerRegistry::get().completed(this.threadId, this.depthLevel, this.currentStep);
         removeTargets();
         Print("WORKFLOW WITH DEPT - ", this.depthLevel, " - COMPLETE AT STEP: ", this.currentStep);
         if (RW_RecordStats == 1) {
            string fp = Symbol() + "_ExecStats_.csv";
            writeStats(fp);
         }
      }
      
      void updateTrailingTarget(double askPrice, double bidPrice){
         double price = (askPrice + bidPrice)/2.0;
         // update trailing target
         if (this.boughtLots > this.soldLots) {
            this.currentTrailingTarget = MathMax(this.currentTrailingTarget, price - this.trailingBuffer);
         } else if (this.boughtLots < this.soldLots) {
            this.currentTrailingTarget = MathMin(this.currentTrailingTarget, price + this.trailingBuffer);
         }
      }

      void startTrailing(double askPrice, double bidPrice) {
         this.trailingBuffer = this.currentTargetDistance*RW_TrailingBufferFactor;
         this.currentTrailingTarget = (askPrice + bidPrice) / 2.0;
         updateTrailingTarget(askPrice, bidPrice);
         renderTrailing(this.currentTrailingTarget);
      }

      void doTrailing(double askPrice, double bidPrice) {
         // first check if trailing threshold is hit
         double price = (askPrice + bidPrice)/2.0;
         if (hitSupportLevel(price, this.currentTrailingTarget)) {
            this.closePositions(askPrice, bidPrice);
            moveToComplete();
            return;
         }

         updateTrailingTarget(askPrice, bidPrice);
         renderTrailing(this.currentTrailingTarget);
      }
      
      void deactivateRecovery(double askPrice, double bidPrice) {
         if(RW_BehaviorOnReachingGlobalRisk == "CLOSE_ALL") {
            Print("CLOSING POSITIONS DUE TO RW_BehaviorOnReachingGlobalRisk = CLOSE_ALL");
            this.closePositions(askPrice, bidPrice);
            moveToComplete();
         } else if(RW_BehaviorOnReachingGlobalRisk == "COMPENSATE") {
            Print("COMPENSATING POSITIONS DUE TO RW_BehaviorOnReachingGlobalRisk = COMPENSATE");
            this.levelBuyAndSellOrders(askPrice, bidPrice);
         } else {
            // DO_NOTHING
            Print("NO ACTION TAKEN due to RW_BehaviorOnReachingGlobalRisk = DO_NOTHING");
         }
         
         
      
      }
      
   public:
      static bool validateParams() {
         if (RW_AcceptLossesOnEnd != 0 && RW_AcceptLossesOnEnd != 1) {
            Print("RW_AcceptLossesOnEnd must be either 0 or 1");
            return false;
         }
         if (RW_BehaviorOnReachingGlobalRisk != "CLOSE_ALL" && RW_BehaviorOnReachingGlobalRisk != "COMPENSATE" && RW_BehaviorOnReachingGlobalRisk != "DO_NOTHING") {
            Print("RW_BehaviorOnReachingGlobalRisk must be one of CLOSE_ALL, COMPENSATE, or DO_NOTHING");
            return false;
         }
         return true;
      }
   
      RecoveryWorkflow(int threadIndex, int depth = 0, int initLots = 0, RecoveryWorkflow *parentLoop = NULL) {
         this.targetSelector = new SmartTargetSelector();
         this.threadId = threadIndex;
         this.depthLevel = depth;
         this.currentStep = 0;
         this.nestedLoop = NULL;
         this.buyOrders = new List<IOrder>();
         this.sellOrders = new List<IOrder>();
         this.parentLoop = parentLoop;
         this.initLots = initLots;
         this.lotsForNestedLoops = 0;
         this.currentTrailingTarget = 0.0;
         updateTargetDistances();
      }
      
      bool isCompleted() {
         return state == COMPLETE;
      }

      bool isFailed() {
         return state == FAILED;
      }

      bool hasFinished() {
         return this.isCompleted() || this.isFailed();
      }

      /**
       *  It processes the tick information plus the combined signal from the thread+classifier+filters
       *  It returns:
       *   - -1 when the risk for the account has been exhausted. It indicates a failure of the algorithm and it should stop the expert.
       *   - 0 when the signal was not used.
       *   - 1 when the signal was used to start a new nested recovery workflow
      **/
      int processTickAndOp(double askPrice, double bidPrice, Operation op) {
         int result = 0;
         double price = (askPrice + bidPrice)/2.0;
         switch(state) {
            case STARTED:
               if (op != NO_OP) {
                  result = 1;
                  this.initRecoveryWorkflow(op, askPrice, bidPrice);
                  RecoveryListenerRegistry::get().started(this.threadId, this.depthLevel);
               }
               break;
            case RECOVERY_WAITING_FOR_NESTED_LOOP:
               // if we are in a nested loop, let's delegate to the nested loop.
               result = this.delegateTickToNestedLoop(askPrice, bidPrice, op);
               break;
            case RECOVERY_WAITING_FOR_THREAD_SIGNAL:
               if (op != NO_OP && nestedWorkflowStartFilter()) {
                  result = 1;
                  this.state = RECOVERY_WAITING_FOR_NESTED_LOOP;
                  // delegate nestedLots to the nested workflow, so removing them from this workflow.
                  this.boughtLots = MathMax(0, this.boughtLots - this.lotsForNestedLoops);
                  this.soldLots = MathMax(0, this.soldLots - this.lotsForNestedLoops);
                  this.nestedLoop = new RecoveryWorkflow(this.threadId, this.depthLevel+1, this.lotsForNestedLoops, GetPointer(this));
                  RecoveryListenerRegistry::get().triggeredNestedRecovery(this.threadId, this.depthLevel, this.currentStep);
                  this.delegateTickToNestedLoop(askPrice, bidPrice, op);
               }
               break;
            case WAITING_TO_HIT_TARGETS:
               result = 0;
               if (this.hitTarget(price)) {
                  RecoveryListenerRegistry::get().hitTarget(this.threadId, this.depthLevel, this.currentStep);
                  this.state = TRAILING;
                  startTrailing(askPrice, bidPrice);
               } else if (this.hitMaxRisk()) {
                  Print("DEACTIVATING EXPERT DUE TO REACH OF GLOBAL RISK");
                  Print("BALANCE: ", AccountBalance(), " EQUITY: ", AccountEquity());
                  deactivateRecovery(askPrice, bidPrice);
                  ExpertRemove();
               }else if (this.hitCover(price)){
                  if(passNextStepFilters()) {
                     this.nextRecoveryStep(askPrice, bidPrice);
                     RecoveryListenerRegistry::get().hitCover(this.threadId, this.depthLevel, this.currentStep);
                  }
               } 
               break;
            case TRAILING:
               doTrailing(askPrice, bidPrice);
               break;
         }

         return result;
      }

      void releaseNestedWorkflow() {
         if(this.nestedLoop != NULL) {
            this.nestedLoop.release();
         }
         delete nestedLoop;
         this.nestedLoop = NULL;
      }

      void release() {
         buyOrders.release();
         delete buyOrders;
         buyOrders = NULL;

         sellOrders.release();
         delete sellOrders;
         sellOrders = NULL;

         // parent loop will be released at the parent level, do not delete.
         parentLoop = NULL;

         this.targetSelector.release();
         delete this.targetSelector;
         this.targetSelector = NULL;
      }

      void writeStats(string fileName) {
         int fd = FileOpen(fileName, FILE_WRITE|FILE_READ|FILE_CSV, ';', CP_UTF8);
         if (fd < 0) {
            Print("ERROR WRITING STATS");
            return;
         }
         
         if(FileSeek(fd, 0, SEEK_END)) {
            int hasNested = 0;
            if(this.nestedLoop != NULL) {
               hasNested = 1;
            }
            FileWrite(fd, this.depthLevel, this.initLots, hasNested, this.currentStep, this.boughtLots, this.soldLots);
         }

         FileClose(fd);
      }
};
