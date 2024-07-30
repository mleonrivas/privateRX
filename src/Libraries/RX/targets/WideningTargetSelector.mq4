#property library WideningTargetSelector
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"

extern double DistancesIncreasePercent = 0.15;
extern double DistancesSpreadCompensationFactor = 0.25; 

class WideningTargetSelector : public ITargetSelector {
   private: 
      double initCoverDistance;
      double initTargetDistance; 
   public:
      WideningTargetSelector(double coverDistance, double targetDistance) {
         this.initCoverDistance = coverDistance;
         this.initTargetDistance = targetDistance;
      }   
      Distances getDistances(int level, int step) {
        Distances result = { 0.0, 0.0 };
        int mult = level;
        if (step >= 2) {
           mult = mult + step/2;
        }
        double spreadCompensationFactor = 0.0;
        if(level > 0) {
           //spread compensation factor: 
           spreadCompensationFactor = DistancesSpreadCompensationFactor;
        }
        result.targetDistance = this.initTargetDistance + (this.initTargetDistance * DistancesIncreasePercent * mult) + (this.initTargetDistance * spreadCompensationFactor);
        result.coverDistance = this.initCoverDistance + (this.initCoverDistance * DistancesIncreasePercent * mult);
        return result;
      }

      void release() {

      }
};
