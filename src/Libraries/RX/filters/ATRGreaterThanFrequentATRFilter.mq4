#property library ATRGreaterThanFrequentATRFilter
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IFilter.mq4"
#include "..\\common\\FrequentATR.mq4"

#define FREQ_ATR_MULT 0.6

class ATRGreaterThanFrequentATRFilter : public IFilter {
   private:
      int atrPeriod;
      double frequentATR;
      datetime lastCandleTime; 

   public:
      ATRGreaterThanFrequentATRFilter(int atrPeriod) {
         this.lastCandleTime = NULL;
         this.frequentATR = 0;
         this.atrPeriod = atrPeriod;
      }

      bool check() {
         double currentATR = iATR(Symbol(), PERIOD_CURRENT, this.atrPeriod, 0);
         if(this.lastCandleTime == NULL || this.lastCandleTime != iTime(Symbol(), 0, 0)) {
            this.lastCandleTime = iTime(Symbol(), 0, 0);
            this.frequentATR = getFrequentATR(this.atrPeriod);
         }
        
         return currentATR >= (this.frequentATR * FREQ_ATR_MULT);
      }
};