#property library ITargetSelector
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

struct Distances {
   double targetDistance;
   double coverDistance;
};

interface ITargetSelector {
   Distances getDistances(int level, int step);
   void release();
};
