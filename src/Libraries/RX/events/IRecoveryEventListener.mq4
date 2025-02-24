#property library IRecoveryEventListener
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
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