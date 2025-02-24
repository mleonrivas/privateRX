#property library DataRecord
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\orders\\MarketOrder.mq4"
#include "..\\filters\\DirectionRatioFilter.mq4"

class DataRecord {
    public:
        MarketOrder *order;
        double volume;
        double atr;
        double volat;
        double dirRatio;
        double rsi;
        double adx;
        double momentum;
        double mfi;
        double bwmfi;
        
        
        DataRecord(MarketOrder *o) {
            this.order = o;
            this.volume = iVolume(Symbol(), PERIOD_CURRENT, 0);
            this.atr = iATR(Symbol(), PERIOD_CURRENT, 14, 0);
            this.volat = getVolatility(0, 20);
            DirectionRatioFilter filter* = new DirectionRatioFilter();
            this.dirRatio = filter.directionRatio(0);
            delete filter;
            this.rsi = iRSI(Symbol(), PERIOD_CURRENT, 12, PRICE_MEDIAN, 0);
            this.adx = iADX(Symbol(), PERIOD_CURRENT, 14, PRICE_MEDIAN, MODE_MAIN, 0);
            this.momentum = iMomentum(Symbol(), PERIOD_CURRENT, 14, PRICE_MEDIAN, 0);
            this.mfi = iMFI(Symbol(), PERIOD_CURRENT, 14, 0);
            this.bwmfi = iBWMFI(Symbol(), PERIOD_CURRENT, 0);  
        }
        
        
        double getVolatility(int i, int size) {
            double result = 0.0;
            for (int j=i; j<(i+size); j++) {
                double closingPrice = iClose(Symbol(),0,j);
                double prevClosingPrice = iClose(Symbol(),0,j+1);
                result = result + MathAbs(closingPrice-prevClosingPrice);
            }
            return result;
        }
        
};
