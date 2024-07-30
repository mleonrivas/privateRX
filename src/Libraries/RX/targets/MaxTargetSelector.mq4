#property library MaxTargetSelector
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\ITargetSelector.mq4"
#include ".\\WideningTargetSelector.mq4"
#include ".\\StatisticTargetSelector.mq4"

class MaxTargetSelector : public ITargetSelector {
    private: 
        ITargetSelector *statsTarget;
        ITargetSelector *wideningTarget; 
    public:
        MaxTargetSelector(ITargetSelector *widening, ITargetSelector *statsTarget) {
            this.statsTarget = statsTarget;
            this.wideningTarget = widening;
        }   
        Distances getDistances(int level, int step) {
            Distances d1 = this.statsTarget.getDistances(level, step);
            Distances d2 = this.wideningTarget.getDistances(level, step);
            if (d1.coverDistance > d2.coverDistance) {
                return d1;
            }
            return d2;
        }

        void release() {
            this.statsTarget = NULL;
            this.wideningTarget = NULL;
        }
};
