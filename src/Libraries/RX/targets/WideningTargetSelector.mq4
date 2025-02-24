#property library WideningTargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"

extern double TS_W_DistancesIncreasePercent = 0.15;

class WideningTargetSelector : public ITargetSelector {
    private: 
        ITargetSelector* ts;
    public:
        WideningTargetSelector(ITargetSelector* base) {
            this.ts = base;
        }   
        Distances getDistances(int level, int step) {
            Distances result = {0.0, 0.0};
            Distances ba = this.ts.getDistances(level, step);
            int mult = level*3 + step/2;
            result.targetDistance = ba.targetDistance;
            result.coverDistance = ba.coverDistance + (ba.coverDistance * TS_W_DistancesIncreasePercent * mult);
            return result;
        }

        void release() { 
            this.ts = NULL;
        }
};
