#property library StatisticTargetSelector
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"
#include "..\\events\\IRecoveryEventListener.mq4"
#include "..\\events\\RecoveryListenerRegistry.mq4"

#define GRACE_BUFFER 1.05;

class StatisticTargetSelector : public ITargetSelector {
   private:
      double initCoverDistance;
      double initTargetDistance;

   public:
      StatisticTargetSelector(double coverDistance, double targetDistance) {
         this.initCoverDistance = coverDistance;
         this.initTargetDistance = targetDistance;
      }
      
      Distances getDistances(int level, int step) {
         Distances result = { 0.0, 0.0 };
         double priceRef = (Ask + Bid)/2.0;
         double minPrice = priceRef;
         double maxPrice = priceRef;
         int i = 0;
         int total = 12 + level*2 + step/2;
         while(i < total) {
            minPrice = MathMin(minPrice, iLow(NULL, PERIOD_CURRENT, i));
            maxPrice = MathMax(minPrice, iHigh(NULL, PERIOD_CURRENT, i));
            i++;
         }
         // now calculate distances from price ref to max and min with the grace buffer
         double toMinPriceDistance = (priceRef - minPrice) * GRACE_BUFFER;
         double toMaxPriceDistance = (maxPrice - priceRef) * GRACE_BUFFER;
         double maxDistance = MathMax(toMinPriceDistance, toMaxPriceDistance);
         double coverDistance = MathMax(maxDistance, initCoverDistance);
         double targetDistance = MathMax(maxDistance, initTargetDistance);

         double spreadComp = 1.0;
         if(level > 0) {
            spreadComp = 1.25;
         }
         targetDistance = maxDistance * spreadComp;
         result.targetDistance = targetDistance;
         result.coverDistance = coverDistance;
         return result;
      }


      void release() {
         
      }
};


