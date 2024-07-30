#property library ThreadTesterWorkflow
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IWorkflow.mq4"
#include "..\\common\\Operation.mq4"
#include "..\\orders\\IOrder.mq4"
#include "..\\orders\\MarketOrder.mq4"
#include "..\\common\\MonetaryManagement.mq4"

class ThreadTesterWorkflow : public IWorkflow {
   private:
      static int magicNumber;
      // allow only one operation per operation type.
      IOrder* buy;
      IOrder* sell; 
      double coverDistance;
      double targetDistance;

      int incrementAndGet() {
         magicNumber = magicNumber + 1;
         return magicNumber;
      }

      void checkOrders() {
         if (this.buy != NULL && this.buy.isStillOpen() == false) {
            delete this.buy;
            this.buy = NULL;
         }

         if (this.sell != NULL && this.sell.isStillOpen() == false) {
            delete this.sell;
            this.sell = NULL;
         }
      }


   public:
      ThreadTesterWorkflow(double coverDistance, double targetDistance) {
         this.buy = NULL;
         this.sell = NULL;
         this.coverDistance = coverDistance;
         this.targetDistance = targetDistance;
      }

      int processTickAndOp(double askPrice, double bidPrice, Operation op) {
         int res = 0;

         double midpoint = (Ask + Bid) / 2.0;
         double vol = MonetaryManagement::get().normalizeLots(MarketInfo(Symbol(), MODE_MINLOT));
         
         if (op == BUY && this.buy == NULL) {
            res = 1;
            int magic = incrementAndGet();
            double sl = midpoint - this.coverDistance;
            double tp = midpoint + this.targetDistance;
            this.buy = new MarketOrder(op, vol, magic, sl, tp);
            this.buy.send();
         }
         if (op == SELL && this.sell == NULL) {
            res = 1;
            int magic = incrementAndGet();
            double sl = midpoint + this.coverDistance;
            double tp = midpoint - this.targetDistance;
            this.sell = new MarketOrder(op, vol, magic, sl, tp);
            this.sell.send();
         }

         checkOrders();
         return res;
      }

      void release() {
         if (this.buy != NULL) {
            delete this.buy;
            this.buy = NULL;   
         }  
         if (this.sell != NULL) {
            delete this.sell;
            this.sell = NULL;   
         }
      } 

      bool isCompleted() {
         return false;
      }

      bool isFailed() {
         return false;
      }

      bool hasFinished() {
         return false;
      }

      void writeStats(string fileName) {
         Print("Ignoring writeStats for ThreadTesterWorkflow");
      }

};

int ThreadTesterWorkflow::magicNumber = 0;