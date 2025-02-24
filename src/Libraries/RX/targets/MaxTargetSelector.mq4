#property library   MaxTargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"

class MaxTargetSelector : public ITargetSelector {
    private: 
        ITargetSelector* ts1;
        ITargetSelector* ts2;
    public:
        MaxTargetSelector(ITargetSelector* ts1, ITargetSelector* ts2) {
            this.ts1 = ts1;
            this.ts2 = ts2;
        }   
        Distances getDistances(int level, int step) {

            Distances result1 = this.ts1.getDistances(level, step);
            Distances result2 = this.ts2.getDistances(level, step);
            if(result1.coverDistance > result2.coverDistance) {
                return result1;
            }
            return result2;
        }

        void release() {
            this.ts1.release();
            this.ts1.release();
            this.ts1 = NULL;
            this.ts2 = NULL;
        }
};
