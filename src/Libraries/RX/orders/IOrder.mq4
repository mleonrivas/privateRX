#property library IOrder
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
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
    double estimateProfitAtTarget(double targetPrice);
};