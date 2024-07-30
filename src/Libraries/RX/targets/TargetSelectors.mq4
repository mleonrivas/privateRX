#property library TargetSelectors
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\ITargetSelector.mq4"
#include ".\\StatisticTargetSelector.mq4"
#include ".\\WideningTargetSelector.mq4"
#include ".\\MaxTargetSelector.mq4"

class TargetSelectors {
    private:
        // singleton instance
        static TargetSelectors *instance;

        ITargetSelector *widening;
        ITargetSelector *stats;
        ITargetSelector *max;

        TargetSelectors(double coverDistance, double targetDistance) {
            this.widening = new WideningTargetSelector(coverDistance, targetDistance);
            this.stats = new StatisticTargetSelector(coverDistance, targetDistance);
            this.max = new MaxTargetSelector(this.widening, this.stats);
        }

        void releaseTS() {
            max.release();
            delete max;
            max = NULL;

            widening.release();
            delete widening;
            widening = NULL;

            stats.release();
            delete stats;
            stats = NULL;
        }

    public:
        static void setup(double coverDistance, double targetDistance) {
            if (!instance) {
                instance = new TargetSelectors(coverDistance, targetDistance);
            }
        }
        static TargetSelectors* get() {
            return instance;
        }
        // Releases de Global instance of the MonetaryManagement.
        static void release() {
            instance.releaseTS();
            delete instance;
            instance = NULL;
        }

        ITargetSelector* getWideningTS() {
            return this.widening;
        }

        ITargetSelector* getStatisticTS() {
            return this.stats;
        }

        ITargetSelector* getMaxTS() {
            return this.max;
        }
};

// Need to create the instance like this, forced by the MQL4 compiler.
TargetSelectors* TargetSelectors::instance = NULL;