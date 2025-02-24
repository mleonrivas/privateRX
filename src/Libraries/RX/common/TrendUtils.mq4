#property library TrendUtils
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/**
 * returns 1 for a bullish trend (price going up), 0 for undertermined, and -1 for a bearish trend (price going down)
*/
bool nestedWorkflowStartFilter() {
    int trend = calculateUpperTfTrend();
    return trend != 0;
}

int calculateUpperTfTrend(int step = 0) {
    int period1 = getUpperTimeframe(1);
    int period2 = getUpperTimeframe(2);
    
    double ema25 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 0);
    double ema25_2 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 1);
    double ema25_3 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 2);
    double ema25_4 = iMA(Symbol(), PERIOD_CURRENT, 25, 0, MODE_EMA, PRICE_MEDIAN, 3);
    
    double bp0 = iBearsPower(Symbol(), period2, 13, PRICE_MEDIAN, 0);
    double bp1 = iBearsPower(Symbol(), period2, 13, PRICE_MEDIAN, 1);
    double sarVal1_0 = iSAR(Symbol(), period1, 0.02, 0.2, 0);
    double sarVal2_0 = iSAR(Symbol(), period2, 0.02, 0.2, 0);
    
    double price = (Ask + Bid)/2.0;
    int result = 0;
    
    if(sarVal1_0 > price && sarVal2_0 > price && bp0 > bp1 && price < ema25 && ema25 < ema25_2 && ema25_2 < ema25_3 && ema25_3 < ema25_4) { // && price < ema25_p1_0) {
        // bearish trend
        result = -1;
    } else if(sarVal1_0 < price && sarVal2_0 < price && bp0 < bp1 && price > ema25 && ema25 > ema25_2 && ema25_2 > ema25_3 && ema25_3 > ema25_4) { // && price > ema25_p1_0) {
        // bullish trend
        result = 1;
    }
    
    /*if(result != 0 && step == 10) {
       double ema25_p1_0 = iMA(Symbol(), period1, 25, 0, MODE_EMA, PRICE_MEDIAN, 0);
       double ema25_p1_1 = iMA(Symbol(), period1, 25, 0, MODE_EMA, PRICE_MEDIAN, 1);
       //double ema25_p1_2 = iMA(Symbol(), period1, 25, 0, MODE_EMA, PRICE_MEDIAN, 2);
       double ema25_p2_0 = iMA(Symbol(), period2, 25, 0, MODE_EMA, PRICE_MEDIAN, 0);
       //double ema25_p2_1 = iMA(Symbol(), period2, 25, 0, MODE_EMA, PRICE_MEDIAN, 1);
       
       if(result == 1 && (price <= ema25_p1_0 && ema25_p1_0 <= ema25_p1_1 && price <= ema25_p2_0)) {
           result = 0;
       }
       
       if(result == -1 && (price >= ema25_p1_0 && ema25_p1_0 >= ema25_p1_1 && price >= ema25_p2_0)) {
           result = 0;
       }
    }*/
    
    if(result != 0 && step == 10) {
       double osma_0 = iOsMA(Symbol(), PERIOD_CURRENT, 12, 26, 9, PRICE_MEDIAN, 0);
       double osma_1 = iOsMA(Symbol(), period1, 12, 26, 9, PRICE_MEDIAN, 0);
       //double osma_2 = iOsMA(Symbol(), PERIOD_CURRENT, 12, 26, 9, PRICE_MEDIAN, 2);
       if(result == 1 && (osma_0 < 0 || osma_1 < 0)) {
           result = 0;
       }
       
       if(result == -1 && (osma_0 < 0 || osma_1 < 0)) {
           result = 0;
       }
           
    }
    
    
    
    return result;
}

int getUpperTimeframe(int shift) {
    int current = Period();
    for (int i=0; i<shift; i++) {
        current = getNextTimeframe(current);
    }
    return current;
}

int getNextTimeframe(int current) {
    if (current == PERIOD_M1) {
        return PERIOD_M5;
    } else if (current == PERIOD_M5) {
        return PERIOD_M15;
    } else if (current == PERIOD_M15) {
        return PERIOD_M30;
    } else if (current == PERIOD_M30) {
        return PERIOD_H1;
    } else if (current == PERIOD_H1) {
        return PERIOD_H4;
    } else if (current == PERIOD_H4) {
        return PERIOD_D1;
    } else if (current == PERIOD_D1) {
        return PERIOD_W1;
    }
    return -1;
}
