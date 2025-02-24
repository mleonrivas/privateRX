#property library FrequentATR
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\ATRHistogramConfig.mq4"

#define ATR_INTERVALS 40
#define MINUTES_IN_A_WEEK 7200 // a week counts as a 5-day period

extern int ATRFREQ_WeeksForFrequentATR = 1;

double getFrequentATR(int atrPeriod) {
   string symbol = Symbol();
   int period = Period();
   // the histogram step for ATR Intervals
   double step = getATRHistogramStep(symbol, period);

   // create an array to count most frequent interval seen
   int counters[ATR_INTERVALS];
   ArrayInitialize(counters, 0);
   
   int numberOfCandles = ATRFREQ_WeeksForFrequentATR * MINUTES_IN_A_WEEK / period;

   // now check ATR value at each candle.
   for (int candle = 0; candle < numberOfCandles; candle++) {
      double atrValue = iATR(symbol, period, atrPeriod, candle);
      int intervalIndex = MathFloor(atrValue / step);
      if (intervalIndex >=0 && intervalIndex < ATR_INTERVALS) {
        counters[intervalIndex] = counters[intervalIndex] + 1;
      } else {
        Print("THE INTERVAL WENT OUT OF RANGE!!!!!");
      }
   }
   int maxIndex = ArrayMaximum(counters);
   return (maxIndex + 1) * step;
}
