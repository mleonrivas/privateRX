#property library GoldAndBlueStochasticThread
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"
#include "..\\common\\TrendUtils.mq4"
#include ".\\Thread.mq4"


/**
 *  RECOMMENDED/TESTED SYMBOLS FOR THIS THREAD: USDJPY, GBPUSD, EURGBP, EURJPY
*/
class GoldAndBlueStochasticThread : public IThread {
   public:
      GoldAndBlueStochasticThread () {
         Print("SELECTED Thread: GoldAndBlueStochastic");
      }

      Operation OnTick() {
         Operation op = NO_OP;
         
         double blue = iStochastic(Symbol(),PERIOD_CURRENT,8,3,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,1); 
         double red = iStochastic(Symbol(),PERIOD_CURRENT,76,3,4,MODE_SMA,STO_LOWHIGH,MODE_MAIN,1);
         
         // get trend
         int trend = calculateUpperTfTrend();

         // check op conditions
         if (blue > 50.0 && blue > red && trend == 1) {
            op = BUY;
         } else if(blue < 50.0 && blue < red && trend == -1) {
            op = SELL;
         }
     
         return op;
      }
};
