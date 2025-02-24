#property library Candle
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class Candle {
    public:
        double open;
        double high;
        double low;
        double close;
    
    Candle(double o, double h, double l, double c) {
        this.open = o;
        this.high = h;
        this.low = l;
        this.close = c;
    }
};