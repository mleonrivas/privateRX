#property library DirectionRatioFilter
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\IFilter.mq4"

#define HISTORY_SIZE 14
#define THRESHOLD 0.6

class DirectionRatioFilter : public IFilter {
   private: 
      double getMovementVelocity(int i) {  
         double closingPrice=iClose(Symbol(),0,i);
         double previousClosingPrice=iClose(Symbol(),0,i+10);
         double velocity = closingPrice - previousClosingPrice;
         return MathAbs(velocity);
      }

      double getVolatility(int i) {
         double result = 0.0;
         for (int j=i; j<(i+HISTORY_SIZE); j++) {
            double closingPrice = iClose(Symbol(),0,j);
            double prevClosingPrice = iClose(Symbol(),0,j+1);
            result = result + MathAbs(closingPrice-prevClosingPrice);
         }
         return(result);
      }
   public:
      bool check() {
         double ratio = directionRatio(0);
         return ratio > THRESHOLD;
      }
      
      double directionRatio(int i) {
         double sum=0.0;
         for (int j=i;j<i+HISTORY_SIZE;j++) {
            double volat = getVolatility(j);
            if (volat > 0.0) {
               double vel = getMovementVelocity(j);
               sum = sum + (vel/volat);
            }      
         }
         return sum/HISTORY_SIZE;
      }

};
