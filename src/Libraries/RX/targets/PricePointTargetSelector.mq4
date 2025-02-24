#property library   PricePointTargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"
#include "..\\common\\TrendUtils.mq4"

extern double TS_PricePointPercentage = 0.25;

class PricePointTargetSelector : public ITargetSelector {
    public:
        Distances getDistances(int level, int step) {
            Distances result = { 0.0, 0.0 };
            double priceRef = (Ask + Bid)/2;
            double dist = priceRef * TS_PricePointPercentage / 100;
            result.coverDistance = dist;
            result.targetDistance = dist * TARGET_MULT;
            return result;
        }

        void release() { }
};
