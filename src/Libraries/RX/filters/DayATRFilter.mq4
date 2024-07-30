#property library DayATRFilter
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IFilter.mq4"

#define ATR_D1_PERCENTAGE 0.25

class DayATRFilter : public IFilter {
   public:
      bool check() {
         double atrD1 = iATR(NULL,PERIOD_D1,8,0);
         double atrRef = 1.5 * iATR(NULL,PERIOD_M5,10,0);
         double atrD1Fraction = atrD1 * ATR_D1_PERCENTAGE;
         return atrRef < atrD1Fraction;
      }
};