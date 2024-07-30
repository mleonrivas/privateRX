#property library HourFilter
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IFilter.mq4"

class HourFilter : public IFilter {
   private:
      int start;
      int end;
   public:
      HourFilter(int startHour, int endHour) {
        this.start = startHour;
        this.end = endHour;
      }
      bool check() {
         int h = Hour();
         return h >= start && h < end;
      }
};