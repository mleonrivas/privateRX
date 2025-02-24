#property library   ATRTargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"
#include "..\\common\\TrendUtils.mq4"

class ATRTargetSelector : public ITargetSelector {
    public:
        Distances getDistances(int level, int step) {
            Distances result = { 0.0, 0.0 };
            int tf = getUpperTimeframe(1);
            double dist = iATR(Symbol(), tf, 50, 0);
            if(dist <= 0.0) {
               dist = iATR(Symbol(), PERIOD_CURRENT, 14, 0);
            }
            dist = dist * 1.1;
            result.coverDistance = dist;
            result.targetDistance = dist * TARGET_MULT;
            return result;
        }

        void release() { }
};
