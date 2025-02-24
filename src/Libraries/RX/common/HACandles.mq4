#property library HACandles
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include ".\\List.mq4"
#include ".\\Candle.mq4"

List<Candle>* generateHACandles(int size) {
    List<Candle> *result = new List<Candle>();
    Candle *first = new Candle(Open[0], High[0], Low[0], Close[0]);
    Candle *p = first;
    for (int i = 0; i < size; i++) {
        Candle *n = getHACandle(i, p);
        result.add(n);
        p = n;
    }
    delete first;
    return result;
}

Candle* getHACandle(int i, Candle *prev) {
    double haOpen=(prev.open + prev.close)/2.0;
    double haClose=(Open[i]+High[i]+Low[i]+Close[i])/4.0;
    double haHigh=MathMax(High[i],MathMax(haOpen,haClose));
    double haLow=MathMin(Low[i],MathMin(haOpen,haClose));
    return new Candle(haOpen, haHigh, haLow, haClose);
}