#property library ITargetSelector
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define TARGET_MULT 1.06

struct Distances {
   double targetDistance;
   double coverDistance;
};

interface ITargetSelector {
   Distances getDistances(int level, int step);
   void release();
};
