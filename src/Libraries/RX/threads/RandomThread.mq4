#property library RandomThread
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"
#include "Thread.mq4"

extern int RandomSeed = 1;
class RandomThread : public IThread {
   public:
      RandomThread() {
         MathSrand(RandomSeed);
      }
      Operation OnTick() {
         int r = MathRand()%10;
         Operation op = NO_OP;
         if (r == 1) {
            op = BUY;
         } else if (r == 2) {
            op = SELL;
         } 
         return op;
      }
};
