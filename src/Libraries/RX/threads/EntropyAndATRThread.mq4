#property library EntropyAndATRThread
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\FrequentATR.mq4"
#include "..\\common\\ShannonEntropy.mq4"
#include "..\\common\\Operation.mq4"
#include ".\\Thread.mq4"

extern double THREAD_AtrFreqPeriod = 14;
extern double THREAD_AtrFreqBandPercentage = 0.33;

class EntropyAndATRThread : public IThread {
   private:
      int atrPeriod;
      double atrFrequentBandPercentage;
      double frequentATR;
      int entropyBlock;
      datetime lastCandleTime;
   public:
      EntropyAndATRThread() {
         this.atrPeriod = THREAD_AtrFreqPeriod;
         this.atrFrequentBandPercentage = THREAD_AtrFreqBandPercentage;
         this.frequentATR = 0;
         this.entropyBlock = 0;
         this.lastCandleTime = NULL;
      }    

      Operation OnTick() {
         Operation op = NO_OP;
         double currentATR = iATR(Symbol(), PERIOD_CURRENT, this.atrPeriod, 0);
         if(this.lastCandleTime == NULL || this.lastCandleTime != iTime(Symbol(), 0, 0)) {
            this.lastCandleTime = iTime(Symbol(), 0, 0);
            this.frequentATR = getFrequentATR(this.atrPeriod);
            this.entropyBlock = shannonEntropy();
         }
         double lowBand = this.frequentATR * (1.0 - this.atrFrequentBandPercentage);
         double highBand = this.frequentATR * (1.0 + this.atrFrequentBandPercentage);

         if (currentATR < lowBand || currentATR > highBand) {
            // fails to be around the frequent ATR, return NO_OP
            return op;
         }
         if (this.entropyBlock <= 0) {
            //low entropy, let's buy
            op = BUY;
         } else {
            // block == 1. high entropy, let's sell
            op = SELL;
         }
          
         return op;
      }
};

