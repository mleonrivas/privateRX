#property library RecoveryRangeFilter
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class RecoveryRangeFilter {
   private:
      bool enabled;
      double roof;
      double floor;
      
   public:
      RecoveryRangeFilter() {
        disable();
      }

      bool check() {
         if (enabled == false) {
            return true;
         }
         double price = (Ask + Bid)/2;
         return price > roof || price < floor;
      }

      void disable() {
         this.enabled = false;
         this.roof = 0.0;
         this.floor = 0.0;
      }

      void enable(double target1, double target2) {
         if(target1 > target2) {
            this.roof = target1;
            this.floor = target2;
         } else {
            this.roof = target2;
            this.floor = target1;
         }
         this.enabled = true;
      }
};