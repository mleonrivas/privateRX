#property library IOrder
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

interface IOrder {
    bool send();
    bool close();
    bool partialClose(int lots);
    bool isStillOpen();
    int getRemainingLots();
    bool isInProfit(double askPrice, double bidPrice);
};