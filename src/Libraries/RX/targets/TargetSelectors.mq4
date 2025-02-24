#property library TargetSelectors
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\ITargetSelector.mq4"
#include ".\\StatisticTargetSelector.mq4"
#include ".\\WideningTargetSelector.mq4"
#include ".\\FixedTargetSelector.mq4"
#include ".\\ATRTargetSelector.mq4"
#include ".\\PricePointTargetSelector.mq4"
#include ".\\MaxTargetSelector.mq4"
#include ".\\HATargetSelector.mq4"

extern double TS_StaticTargetDistance = 6.4;
extern double TS_StaticCoverDistance = 6.0;

class TargetSelectors {
    private:
        // singleton instance
        static TargetSelectors *instance;

        ITargetSelector *stats;
        ITargetSelector *atr;
        ITargetSelector *fixed;
        ITargetSelector *price;
        ITargetSelector *ha;

        TargetSelectors() {
            this.stats = new StatisticTargetSelector(TS_StaticCoverDistance, TS_StaticTargetDistance);
            this.fixed = new FixedTargetSelector(TS_StaticCoverDistance, TS_StaticTargetDistance);
            this.atr = new ATRTargetSelector();
            this.price = new PricePointTargetSelector();
            this.ha = NULL;
        }

        void releaseTS() {
            stats.release();
            delete stats;
            stats = NULL;

            fixed.release();
            delete fixed;
            fixed = NULL;

            atr.release();
            delete atr;
            atr = NULL;

            price.release();
            delete price;
            price = NULL;
            
            if (ha != NULL) {
                ha.release();
                delete ha;
                ha = NULL;
            }
            
        }

    public:
        static TargetSelectors* get() {
            if (!instance) {
                instance = new TargetSelectors();
            }
            return instance;
        }
        // Releases de Global instance of the MonetaryManagement.
        static void release() {
            if (instance == NULL) {
               return;
            }
            instance.releaseTS();
            delete instance;
            instance = NULL;
        }

        ITargetSelector* getWideningTS(ITargetSelector* base) {
            return new WideningTargetSelector(base);
        }

        ITargetSelector* getMaxTS(ITargetSelector* ts1, ITargetSelector* ts2) {
            return new MaxTargetSelector(ts1, ts2);
        }

        ITargetSelector* getStatisticTS() {
            return this.stats;
        }

        ITargetSelector* getFixedTS() {
            return this.fixed;
        }

        ITargetSelector* getAtrTS() {
            return this.atr;
        }

        ITargetSelector* getPriceBasedTS() {
            return this.price;
        }
        
        ITargetSelector* getHATS() {
            if(this.ha == NULL) {
                this.ha = new HATargetSelector();
            }
            return this.ha;
        }
};

// Need to create the instance like this, forced by the MQL4 compiler.
TargetSelectors* TargetSelectors::instance = NULL;