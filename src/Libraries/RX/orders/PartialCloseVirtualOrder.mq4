#property library MarketOrder
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"
#include ".\\IOrder.mq4"
#include "..\\common\\List.mq4"
#include "..\\common\\MonetaryManagement.mq4"

/**
 * Represents a virtual order from closing partially an existing position in the opposite direction.
*/
class PartialCloseVirtualOrder : public IOrder { 
   private:
      Operation type;
      List<IOrder> *buyPositions;
      List<IOrder> *sellPositions;
      int lots;
      int remainingLots;
      double refVirtualPrice;
   
      bool executeOpByPartiallyClosingPositions(Operation op, int lots){
         int remaining = lots;
         List<IOrder> *orders = NULL;
         double closingPrice = 0.0;
         if (op == BUY) {
            // To mock a buy operation by partially closing sell orders.
            orders = this.sellPositions;
            closingPrice = Ask;
         } else if (op == SELL) {
            orders = this.buyPositions;
            closingPrice = Bid;
         }
         this.refVirtualPrice = closingPrice;
         int i = orders.size()-1;
         while (remaining > 0 && i >= 0) {
            IOrder *od = orders.get(i);
            int partialLots = MonetaryManagement::get().normalizeLots(MathMin(remaining, od.getRemainingLots()));
            if (partialLots <= 0) {
               i--;
               continue;
            }
            od.partialClose(partialLots);
            remaining = remaining - partialLots;
         }
         //TODO return a value that makes sense
         return true;
      }

      void release() {
        buyPositions = NULL;
        sellPositions = NULL;
      }

   public:
      PartialCloseVirtualOrder(Operation op, List<IOrder> *buyOrders, List<IOrder> *sellOrders, int lots) {
         this.type = op;
         this.buyPositions = buyOrders;
         this.sellPositions = sellOrders;
         this.lots = lots;
         this.remainingLots = lots;
         this.refVirtualPrice = 0.0;
      }

      bool send() {
         return executeOpByPartiallyClosingPositions(this.type, this.remainingLots);
      }

      bool close() {
        return partialClose(this.remainingLots);
      }

      bool partialClose(int lots) {
        Operation closingOp = this.type == BUY ? SELL : BUY;
        bool res = executeOpByPartiallyClosingPositions(closingOp, lots);
        this.remainingLots = this.remainingLots - lots;
        if (isStillOpen() == false) {
           release();
        }
        return res;
      }

      bool isStillOpen() {
         return this.remainingLots > 0;
      }

      int getRemainingLots() {
         return this.remainingLots;
      }
      
      bool isInProfit(double askPrice, double bidPrice) {
         double diff = 0.0;
         if (this.type == BUY) {
            // have to sell to close
            diff = bidPrice - this.refVirtualPrice;
         } else {
            // have to buy to close
            diff = this.refVirtualPrice - askPrice;
         }
         
         return diff > 0.0;
      }
    
};
