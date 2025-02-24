#property library VolatilityFilter
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IFilter.mq4"

#define ATR_DATAPOINTS 50

class VolatilityFilter : public IFilter {
   public:
      bool check() {
         double dayATR = iATR(Symbol(), PERIOD_D1, 8, 0);
         double sum = 0.0;
         for (int i=0; i<ATR_DATAPOINTS; i++) {
            sum = sum + iATR(Symbol(), PERIOD_D1, 8, i);
         }
         double avg = sum / ATR_DATAPOINTS;
         return dayATR >= avg;
      }
};