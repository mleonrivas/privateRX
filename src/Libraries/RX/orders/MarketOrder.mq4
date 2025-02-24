#property library MarketOrder
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"
#include "..\\common\\MonetaryManagement.mq4"
#include ".\\IOrder.mq4"

/**
 * Represents a standard market order: BUY or SELL, opening a new position.
*/
class MarketOrder : public IOrder { 
   private:
      // auto-increment for magic numbers. the mgic number is used to identify the orderId when the ticketId changes (in partial closes)
      static int refAutoIncrement;

      Operation type;
      int reference;
      double price;
      int lots;
      int remainingLots;
      double stopLoss;
      double takeProfit;

      int findNewOrderId() {
         for(int i = 0; i < OrdersTotal(); i++) {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true) {
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==this.reference) {
                  return OrderTicket();
               }
            }
         }
         return -1;
      }

      int incrementAndGet() {
         refAutoIncrement = refAutoIncrement + 1;
         return refAutoIncrement;
      }

   public:
      int orderId;
      double profit;

      MarketOrder(Operation t, int lots, int refId, double sl = 0.0, double tp = 0.0) {
         this.type = t;
         this.lots = lots;
         this.price = t == BUY ? Ask: Bid;
         this.orderId = -1;
         this.reference = refId * 10000 + incrementAndGet();
         this.remainingLots = lots;
         this.stopLoss = sl;
         this.takeProfit = tp;
         this.profit = 0.0;
      }

      void consolidateProfit() {
         if(OrderSelect(this.orderId, SELECT_BY_TICKET, MODE_HISTORY) == true) {
            double prof = OrderProfit();
            this.profit = this.profit + prof;
         }
      }

      bool send() {
         if(this.orderId > -1) {
            // already sent
            return false;
         }
         int cmd = this.type == BUY ? OP_BUY : OP_SELL;
         double actualLots = MonetaryManagement::get().getActualLots(this.lots);
         this.orderId = OrderSend(Symbol(), cmd, actualLots, this.price, 0, this.stopLoss, this.takeProfit, "", this.reference);
         if (this.orderId == -1) {
            Print("Error Sending ORDER ", cmd, " ", actualLots, " with ref ", this.reference, ", ", GetLastError());
            return false;
         }
         this.remainingLots = this.lots;
         return true;
      }

      bool close() {
         if(this.remainingLots <= 0) {
            return false;
         }
         return partialClose(this.remainingLots);
      }

      bool partialClose(int closingLots) {
         double closingPrice = Ask;
         if (this.type == BUY) {
            closingPrice = Bid;
         }
         double actualLots = MonetaryManagement::get().getActualLots(closingLots);
         bool result = OrderClose(this.orderId, actualLots, closingPrice, 0);
         if (result) {
            this.remainingLots = this.remainingLots - closingLots;
         }
         
         consolidateProfit();
         
         int newOID = findNewOrderId();
         this.orderId = newOID;
         
         return result;
      }

      bool isStillOpen() {
         bool result = false;
         if (OrderSelect(this.orderId, SELECT_BY_TICKET, MODE_HISTORY)) {
            result = OrderCloseTime() == 0;
         }
         return result;
      }

      int getRemainingLots() {
         return this.remainingLots;
      }
      
      bool isInProfit(double askPrice, double bidPrice) {
         double closingPrice = this.type == BUY ? bidPrice : askPrice;
         return estimateProfitAtTarget(closingPrice) > 0.0;
      }

      double estimateProfitAtTarget(double targetPrice) {
         double baseProfit = this.profit;
         if(remainingLots == 0) {
            return baseProfit;
         }
         
         double diff = 0.0;
         if (this.type == BUY) {
            // have to sell to close
            diff = targetPrice - this.price;
         } else {
            // have to buy to close
            diff = this.price - targetPrice;
         }
         return baseProfit + diff * this.remainingLots;
      }
};

int MarketOrder::refAutoIncrement = 0;