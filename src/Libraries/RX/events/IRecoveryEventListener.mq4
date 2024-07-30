#property library IRecoveryEventListener
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

interface IRecoveryEventListener {
   void started(int id, int level);
   void hitCover(int id, int level, int step);
   void hitTarget(int id, int level, int step);
   void completed(int id, int level, int step);
   void triggeredNestedRecovery(int id, int level, int step);
};