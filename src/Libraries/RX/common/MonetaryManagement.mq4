#property library MonetaryManagement
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\Operation.mq4"

#define LOT_COMPENSATION_FACTOR 1.1

class MonetaryManagement {
   private:
      // singleton instance
      static MonetaryManagement *instance;

      double maxRiskPerOperation;
      double maxGlobalRisk;
      int symbolMultiplier;
      
      int calcStartingLots(double coverDistance) {
         double eq = AccountEquity();
         double amountToRisk = eq * this.maxRiskPerOperation;
         double tickValueInAccountCurrency = MarketInfo(Symbol(), MODE_TICKVALUE);
         double coverDistanceInPips = coverDistance / Point();
         double lots = amountToRisk / (tickValueInAccountCurrency * coverDistanceInPips);
         int iLots = (int) MathCeil(lots*this.symbolMultiplier);
         return normalizeLots(iLots);
      }

      MonetaryManagement(double maxRiskPerOperation, double maxTotalRisk) { 
         double lotStep = SymbolInfoDouble (Symbol(), SYMBOL_VOLUME_STEP);
         this.symbolMultiplier = (int) MathRound(1.0/lotStep);
         this.maxRiskPerOperation = maxRiskPerOperation;
         this.maxGlobalRisk = maxTotalRisk;
      }

   public:
      // sets the values for the correclty calculating the lots
      static void setup(double maxRiskPerOperation, double maxTotalRisk) {
         if (!instance) {
            instance = new MonetaryManagement(maxRiskPerOperation, maxTotalRisk);
         }
      }   
      // returns the global instace of the MonetaryManagement
      static MonetaryManagement* get() {
         return instance;
      }
      // Releases de Global instance of the MonetaryManagement.
      static void release() {
         delete instance;
         instance = NULL;
      }

      /*
            All entries in a recovery happen in 2 price lines:
              - The First entry prices determines the first line.
              - The coverDistance from first entry determines the second line
            Therefore, all entries should ideally happen at these two prices.
            So the lots (X) should be calculated as:
               For a buying operation:
                  --> (X+boughtLots)*targetDistance = soldLots*(coverDistance+targetDistance)
                  --> X = soldLots * (coverDistance + targetDistance) / targetDistance - boughtLots
               For a selling operation, exchange boughtLots and soldLots
      */
      int calculateLots(Operation op, int boughtLots, int soldLots, double coverDistance, double targetDistance) { 
         // TODO. calculate global risk and return 0 if reached.
         if (op == NO_OP) {
            return 0;
         }

         if (boughtLots == soldLots) {
            // no imbalance, we are starting
            return calcStartingLots(coverDistance);
         }
         // lots imbalanced
         double lots = 0.0;
         if (op == BUY) {
            lots = ((soldLots * (coverDistance + targetDistance)/targetDistance) - boughtLots) * LOT_COMPENSATION_FACTOR;
         } else if (op == SELL) {
            lots = ((boughtLots * (coverDistance + targetDistance)/targetDistance) - soldLots) * LOT_COMPENSATION_FACTOR;
         }
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