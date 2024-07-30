#property library TrendUtils
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/**
 * returns 1 for a bullish trend (price going up), 0 for undertermined, and -1 for a bearish trend (price going down)
*/
extern double ADXThreshold = 45;

bool nestedWorkflowStartFilter() {
    int tf = getUpperTrendTimeframe();
    //double adxVal = iADX(Symbol(), tf, 14, PRICE_MEDIAN, MODE_MAIN, 0);
    //if (adxVal < ADXThreshold) {
    //    return 0;
    //}  
    /*
    long vol0 = iVolume(Symbol(), tf, 0);
    long vol1 = iVolume(Symbol(), tf, 1);
    double mfi0 = iBWMFI(Symbol(), tf, 0);
    double mfi1 = iBWMFI(Symbol(), tf, 1);
    if (mfi0 <= mfi1 || vol0 <= vol1) {
        return false;
    }
    */
    int trend = calculateTrend(tf);
    return trend != 0;
}

int calculateTrend(int period) {
    double bp0 = iBearsPower(Symbol(), period, 13, PRICE_MEDIAN, 0);
    double bp1 = iBearsPower(Symbol(), period, 13, PRICE_MEDIAN, 1);
    //double bp2 = iBearsPower(Symbol(), period, 13, PRICE_MEDIAN, 2);
    
    double sarVal = iSAR(Symbol(), period, 0.02, 0.2, 0);
    double sarVal2 = iSAR(Symbol(), period/2, 0.02, 0.2, 0);
    double price = (Ask + Bid)/2.0;
    int result = 0;
    if(sarVal > price && sarVal2 > price && bp0 > bp1) {
        // bearish trend
        result = -1;
    } else if(sarVal < price && sarVal2 < price && bp0 < bp1) {
        // bullish trend
        result = 1;
    }
    return result;
}

int getUpperTrendTimeframe() {
    int current = Period();
    if (current == PERIOD_M1) {
        return PERIOD_M15;
    } else if (current == PERIOD_M5) {
        return PERIOD_M30;
    } else if (current == PERIOD_M15) {
        return PERIOD_H1;
    } else if (current == PERIOD_M30) {
        return PERIOD_H4;
    } else if (current == PERIOD_H1) {
        return PERIOD_H4;
    } else if (current == PERIOD_H4) {
        return PERIOD_D1;
    } else if (current == PERIOD_D1) {
        return PERIOD_W1;
    }
    return current;
}
