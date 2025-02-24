#property library   FixedTargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"

class FixedTargetSelector : public ITargetSelector {
   private: 
      double initCoverDistance;
      double initTargetDistance; 
   public:
      FixedTargetSelector(double coverDistance, double targetDistance) {
         this.initCoverDistance = coverDistance;
         this.initTargetDistance = targetDistance;
      }   
      Distances getDistances(int level, int step) {
        Distances result = { 0.0, 0.0 };
        result.targetDistance = this.initTargetDistance;
        result.coverDistance = this.initCoverDistance;
        return result;
      }

      void release() { }
};
