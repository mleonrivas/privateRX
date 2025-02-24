#property library   HATargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ITargetSelector.mq4"
#include "..\\common\\List.mq4"
#include "..\\common\\Candle.mq4"
#include "..\\common\\HACandles.mq4"

extern int TS_HA_HistorySize = 1400;

class HATargetSelector : public ITargetSelector {
    private:
        double distance;
        int lastRef;
        
        double calculateDistance() {
            List<Candle> *candles = generateHACandles(TS_HA_HistorySize);
            // calculate impulses
            double imps[] = {};
            double impMin = -1;
            double impMax = -1;
            int direction = 0;
            int count = 0;
            for (int i=0; i<candles.size(); i++) {
                Candle *c = candles.get(i);
                int currDirection = c.close - c.open >= 0 ? 1 : -1;
                int nextDirection = currDirection;
                // BLOCK: Allow 1 candle in the opposite direction between candles of the same direction:
                // Example: Pos - Neg - Pos --> Consider this a unique positive impulse.
                if (i<candles.size()-1) {
                    Candle *next = candles.get(i+1);
                    nextDirection = next.close - next.open >= 0 ? 1 : -1;
                }
                if (nextDirection == direction && nextDirection != currDirection) {
                   currDirection = direction;
                }
                // END OF BLOCK
                if(direction != currDirection) {
                    if (direction != 0 && count > 5) {
                        int size = ArraySize(imps);
                        ArrayResize(imps, size+1, TS_HA_HistorySize);
                        imps[size] = impMax - impMin;
                    } 
                    direction = currDirection;
                    impMin = -1;
                    impMax = -1;
                    count = 0;
                }
                if (impMax == -1) {
                    impMax = c.high;
                    impMin = c.low;
                } else {
                    impMax = MathMax(impMax, c.high);
                    impMin = MathMin(impMin, c.low);
                }
                count++;
                
            }
            ArraySort(imps);
            double dist = imps[int(ArraySize(imps)*0.7)];
            Print("SELECTED HA DISTANCE = ", dist);
            candles.release();
            delete candles;
            return dist;
        }
        
    public:

        HATargetSelector() {
            this.lastRef = DayOfYear()/5;
            this.distance = this.calculateDistance();
        }

        Distances getDistances(int level, int step) {
            int currentRef = DayOfYear()/5;
            if (this.lastRef != currentRef) {
               this.lastRef = currentRef;
               this.distance = this.calculateDistance();
            }
            Distances result = { 0.0, 0.0 };
            result.coverDistance = this.distance/TARGET_MULT;
            result.targetDistance = this.distance;
            return result;
        }

        void release() { }
};  