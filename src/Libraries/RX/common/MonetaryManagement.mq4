#property library MonetaryManagement
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\Operation.mq4"
#include ".\\List.mq4"
#include "..\\orders\\IOrder.mq4"

extern double MM_MaxGlobalRisk = 0.2;
extern double MM_RiskPerOperation = 0.001;
extern double MM_MinCompensationFactor = 1.1;
extern double MM_MaxCompensationFactor = 1.4;
extern double MM_StepDecay = 0.1;


class MonetaryManagement {
   private:
      // singleton instance
      static MonetaryManagement *instance;

      int symbolMultiplier;
      
      double compensationFactor(int level, int step) {
         if (level > 0) {
            return 1.0;
         }
         return MathMax(MM_MinCompensationFactor, MM_MaxCompensationFactor - MM_StepDecay*step);
         
      }

      MonetaryManagement() { 
         double lotStep = SymbolInfoDouble (Symbol(), SYMBOL_VOLUME_STEP);
         this.symbolMultiplier = (int) MathRound(1.0/lotStep);
      }

   public:
      // returns the global instace of the MonetaryManagement
      static MonetaryManagement* get() {
         if (!instance) {
            instance = new MonetaryManagement();
         }
         return instance;
      }
      // Releases de Global instance of the MonetaryManagement.
      static void release() {
         delete instance;
         instance = NULL;
      }
      
      bool checkValidParams() {
         bool result = MM_MaxGlobalRisk > 0 && MM_MaxGlobalRisk <= 0.4 && MM_RiskPerOperation > 0 && MM_MaxGlobalRisk >= 200*MM_RiskPerOperation;
         if (!result) {
            Print("ERROR IN INPUT PARAMS: MM_MaxGlobalRisk must be between 0.0 and 0.4, and MM_RiskPerOperation must be between 0.0 and MM_MaxGlobalRisk/200");
         }
         return result;
      }
      
      int calcStartingLots(double coverDistance) {
         if (riskIsBeyondThreshold()) {
            return 0;
         }
         double eq = AccountEquity();
         double amountToRisk = eq * MM_RiskPerOperation;
         //Risk = distInTicks * lots * tickValue  ==> lots = amountToRisk / distInTicks * tickValue
         double tickValueInAccountCurrency = MarketInfo(Symbol(), MODE_TICKVALUE);
         double coverDistanceInTicks = coverDistance / MarketInfo(Symbol(), MODE_TICKSIZE);
         double lots = amountToRisk / (tickValueInAccountCurrency * coverDistanceInTicks);
         int iLots = (int) MathCeil(lots*this.symbolMultiplier);
         return normalizeLots(iLots);
      }
      
      bool riskIsBeyondThreshold() {
         double bal = AccountBalance();
         double eq = AccountEquity();
         return eq < bal*(1 - MM_MaxGlobalRisk);
      }

      int calculateLots(Operation op, int boughtLots, int soldLots, double coverDistance, double targetDistance, int level, int step, double price, List<IOrder> *buys, List<IOrder> *sells) {
         if (op == NO_OP) {
            return 0;
         }
         if (boughtLots == soldLots) {
            // no imbalance, we are starting
            return calcStartingLots(coverDistance);
         }
         
         // lots imbalanced
         double targetPrice = 0;
         if (op == BUY) {
            targetPrice = price + targetDistance;
         } else {
            targetPrice = price - targetDistance;
         }
         
         double compensation = this.compensationFactor(level, step);
         double totalProfit = 0.0;
         for (int i=0; i<buys.size(); i++) {
            IOrder *od = buys.get(i);
            totalProfit = totalProfit + od.estimateProfitAtTarget(targetPrice);
         }
         for (int i=0; i<sells.size(); i++) {
            IOrder *od = sells.get(i);
            totalProfit = totalProfit + od.estimateProfitAtTarget(targetPrice);
         }
         // compensate totalProfit with a new order: targetDistance * lots = totalProfit, assuming lots are represented in integers
         double lots = (-totalProfit / targetDistance)*compensation;
         int iLots = (int) MathCeil(lots);
         return normalizeLots(iLots);
      }

      double getActualLots(int lots) {
         double dLots = lots * 1.0;
         return dLots/this.symbolMultiplier;
      }

      int normalizeLots(int lots) {
         if (lots <= 0) {
            return 0;
         }
         double volMinRef = MathMax(SymbolInfoDouble (Symbol(), SYMBOL_VOLUME_MIN), SymbolInfoDouble (Symbol(), SYMBOL_VOLUME_STEP));
         int volMin = (int) MathCeil(volMinRef*this.symbolMultiplier);
         int volMax = (int) MathCeil(SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX) * this.symbolMultiplier);
         
         int result = lots;
         if (lots < volMin) {
            result = volMin;
         }

         if (lots > volMax) {
            result = volMax;
         }
         
         return result;
      }

};

// Need to create the instance like this, forced by the MQL4 compiler.
MonetaryManagement* MonetaryManagement::instance = NULL;