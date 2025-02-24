#property library EspecialPartialOrder
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"
#include ".\\IOrder.mq4"
#include ".\\MarketOrder.mq4"
#include ".\\PartialCloseVirtualOrder.mq4"
#include "..\\common\\List.mq4"
#include "..\\common\\MonetaryManagement.mq4"

/**
 * Represents a virtual order from closing partially an existing position in the opposite direction.
*/
class EspecialPartialOrder : public IOrder { 
   private:
      Operation type;
      int magicPrefix;
      IOrder* partialCloseOrder;
      IOrder* marketOrder;
      int lotsPartialClose;
      int lotsMarket;
      int remainingLots;
      double refVirtualPrice;
   
      void release() {
         delete this.partialCloseOrder;
         delete this.marketOrder;
         this.partialCloseOrder = NULL;
         this.marketOrder = NULL;
      }

   public:
      EspecialPartialOrder(Operation op, List<IOrder> *buyOrders, List<IOrder> *sellOrders, int lots, int marketLots, int magicPrefix) {
         this.type = op;
         this.magicPrefix = magicPrefix;
         this.lotsMarket = MonetaryManagement::get().normalizeLots(marketLots);
         this.lotsPartialClose = MonetaryManagement::get().normalizeLots(lots);
         this.partialCloseOrder = new PartialCloseVirtualOrder(op, buyOrders, sellOrders, this.lotsPartialClose);
         this.marketOrder = new MarketOrder(op, this.lotsMarket, magicPrefix);
         this.remainingLots = this.lotsPartialClose + this.lotsMarket;
         this.refVirtualPrice = 0.0;
      }

      bool send() {
         this.refVirtualPrice = this.type == BUY? Ask : Bid;
         bool res1 = this.marketOrder.send();
         bool res2 = this.partialCloseOrder.send();
         return res1 && res2;
      }

      bool close() {
         bool res1 = this.marketOrder.close();
         bool res2 = this.partialCloseOrder.close();
         this.lotsPartialClose = 0;
         this.lotsMarket = 0;
         this.remainingLots = 0;
         release();
         return res1 && res2;
      }

      bool partialClose(int lots) {
         int remaining = lots;
         if(this.lotsMarket > 0) {
            int mLots = MonetaryManagement::get().normalizeLots(MathMin(remaining, this.lotsMarket));
            this.marketOrder.partialClose(mLots);
            this.remainingLots = this.remainingLots - mLots;
            this.lotsMarket = this.lotsMarket - mLots;
            remaining = remaining - mLots;
         }

         if(remaining > 0 && this.lotsPartialClose > 0) {
            int pLots = MonetaryManagement::get().normalizeLots(MathMin(remaining, this.lotsPartialClose));
            this.partialCloseOrder.partialClose(pLots);
            this.remainingLots = this.remainingLots - pLots;
            this.lotsPartialClose = this.lotsPartialClose - pLots;
            remaining = remaining - pLots;
         }
         if (isStillOpen() == false) {
            release();
         }
         return remaining <= 0;
      }

      bool isStillOpen() {
         return this.remainingLots > 0;
      }

      int getRemainingLots() {
         return this.remainingLots;
      } 
      
      bool isInProfit(double askPrice, double bidPrice) {
         double closingPrice = this.type == BUY ? bidPrice : askPrice;
         return estimateProfitAtTarget(closingPrice) > 0.0;
      }

      double estimateProfitAtTarget(double targetPrice) {
         double diff = 0.0;
         if (this.type == BUY) {
            // have to sell to close
            diff = targetPrice - this.refVirtualPrice;
         } else {
            // have to buy to close
            diff = this.refVirtualPrice - targetPrice;
         }
         return diff * this.remainingLots;
      }
};