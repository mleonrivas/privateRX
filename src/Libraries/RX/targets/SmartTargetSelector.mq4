#property library   SmartTargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"
#include "TargetSelectors.mq4"

class SmartTargetSelector : public ITargetSelector {
    private: 
        ITargetSelector* ts1;
        ITargetSelector* ts2;
        ITargetSelector* ts3;
    public:
        SmartTargetSelector() {
            //this.ts1 = TargetSelectors::get().getHATS();
            this.ts1 = TargetSelectors::get().getWideningTS(TargetSelectors::get().getPriceBasedTS());
            this.ts2 = TargetSelectors::get().getStatisticTS();
            this.ts3 = TargetSelectors::get().getStatisticTS();
        }   
        Distances getDistances(int level, int step) {
            
            int score = level*10 + step;
            if(score <=3 ) {
                return this.ts1.getDistances(level, step);
            } else if(score <= 9) {
                return this.ts2.getDistances(level, step);
            }
            return this.ts3.getDistances(level, step);
            
            //return this.ts1.getDistances(level, step);
        }

        void release() {
            this.ts1.release();
            this.ts2.release();
            this.ts3.release();
            delete this.ts1;
            this.ts1 = NULL;
            this.ts2 = NULL;
            this.ts3 = NULL;
        }
};