
#property library ATRHistorgramConfig
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double getATRHistogramStep(string sym, int timeframe) {
   if(sym == "GBPUSD" || sym == "GBPUSD." || sym == "GBPUSD.ecn") {
     return stepForGBPUSD(timeframe);
   }
   if(sym == "GBPJPY" || sym == "GBPJPY." || sym == "GBPJPY.ecn") {
     return stepForGBPJPY(timeframe);
   }
   if(sym == "GBPNZD" || sym == "GBPNZD." || sym == "GBPNZD.ecn") {
     return stepForGBPNZD(timeframe);
   }
   if(sym == "EURJPY" || sym == "EURJPY." || sym == "EURJPY.ecn") {
     return stepForEURJPY(timeframe);
   }
   if(sym == "EURGBP" || sym == "EURGBP." || sym == "EURGBP.ecn") {
     return stepForEURGBP(timeframe);
   }
   if(sym == "EURUSD" || sym == "EURUSD." || sym == "EURUSD.ecn") {
     return stepForEURUSD(timeframe);
   }
   if(sym == "EURNZD" || sym == "EURNZD." || sym == "EURNZD.ecn") {
     return stepForEURNZD(timeframe);
   }
   if(sym == "USDJPY" || sym == "USDJPY." || sym == "USDJPY.ecn") {
     return stepForUSDJPY(timeframe);
   }
   if(sym == "AUDUSD" || sym == "AUDUSD." || sym == "AUDUSD.ecn") {
     return stepForAUDUSD(timeframe);
   }
   if(sym == "AUDCAD" || sym == "AUDCAD." || sym == "AUDCAD.ecn") {
     return stepForAUDCAD(timeframe);
   }
   if(sym == "USDCAD" || sym == "USDCAD." || sym == "USDCAD.ecn") {
     return stepForUSDCAD(timeframe);
   }
   if(sym == "USDCHF" || sym == "USDCHF." || sym == "USDCHF.ecn") {
     return stepForUSDCHF(timeframe);
   }
   if(sym == "[IBEX35]" || sym == "SPA35" || sym == "ESP35") {
     return stepForIBEX35(timeframe);
   }
   if(sym == "[CAC40]" || sym == "FRA40") {
     return stepForCAC40(timeframe);
   }
   if(sym == "[SP500]" || sym == "US500" || sym == "SP500") {
     return stepForSP500(timeframe);
   }
   if(sym == "[NQ100]" || sym == "NAS100" || sym == "UT100") {
     return stepForNQ100(timeframe);
   }
   if(sym == "GOLD" || sym == "XAUUSD" || sym == "XAUUSD." || sym == "XAUUSD.ecn") {
     return stepForGOLD(timeframe);
   }
   if(sym == "BRENT" || sym == "XBRUSD" || sym == "XBRUSD." || sym == "UKOUSD") {
     return stepForBRENT(timeframe);
   }
   return 0.0;
}


double stepForGBPUSD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.000241; break;
      case PERIOD_M5:
         step = 0.000288; break;
      case PERIOD_M15:
         step = 0.000318; break;
      case PERIOD_M30:
         step = 0.000339; break;
      case PERIOD_H1:
         step = 0.000391; break;   
   }
   return step;
}

double stepForGBPJPY(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.0354; break;
      case PERIOD_M5:
         step = 0.0425; break;
      case PERIOD_M15:
         step = 0.0438; break;
      case PERIOD_M30:
         step = 0.0460; break;
      case PERIOD_H1:
         step = 0.0517; break;   
   }
   return step;
}

double stepForGBPNZD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.00035; break;
      case PERIOD_M5:
         step = 0.00041; break;
      case PERIOD_M15:
         step = 0.00043; break;
      case PERIOD_M30:
         step = 0.00052; break;
      case PERIOD_H1:
         step = 0.00073; break;   
   }
   return step;
}

double stepForEURJPY(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.0234; break;
      case PERIOD_M5:
         step = 0.0347; break;
      case PERIOD_M15:
         step = 0.0303; break;
      case PERIOD_M30:
         step = 0.0301; break;
      case PERIOD_H1:
         step = 0.0339; break;   
   }
   return step;
}

double stepForEURGBP(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.000180; break;
      case PERIOD_M5:
         step = 0.000208; break;
      case PERIOD_M15:
         step = 0.000210; break;
      case PERIOD_M30:
         step = 0.000227; break;
      case PERIOD_H1:
         step = 0.000253; break;   
   }
   return step;
}

double stepForEURUSD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.000086; break;
      case PERIOD_M5:
         step = 0.000098; break;
      case PERIOD_M15:
         step = 0.000134; break;
      case PERIOD_M30:
         step = 0.000144; break;
      case PERIOD_H1:
         step = 0.000171; break;   
   }
   return step;
}

double stepForEURNZD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.00053; break;
      case PERIOD_M5:
         step = 0.00054; break;
      case PERIOD_M15:
         step = 0.00058; break;
      case PERIOD_M30:
         step = 0.00059; break;
      case PERIOD_H1:
         step = 0.00081; break;   
   }
   return step;
}

double stepForUSDJPY(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.0306; break;
      case PERIOD_M5:
         step = 0.0316; break;
      case PERIOD_M15:
         step = 0.0378; break;
      case PERIOD_M30:
         step = 0.0400; break;
      case PERIOD_H1:
         step = 0.0422; break;   
   }
   return step;
}

double stepForAUDUSD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.0000098; break;
      case PERIOD_M5:
         step = 0.0000091; break;
      case PERIOD_M15:
         step = 0.0000112; break;
      case PERIOD_M30:
         step = 0.0000073; break;
      case PERIOD_H1:
         step = 0.0000118; break;   
   }
   return step;
}

double stepForAUDCAD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.00017; break;
      case PERIOD_M5:
         step = 0.00020; break;
      case PERIOD_M15:
         step = 0.00021; break;
      case PERIOD_M30:
         step = 0.00024; break;
      case PERIOD_H1:
         step = 0.00033; break;   
   }
   return step;
}

double stepForUSDCAD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.00008; break;
      case PERIOD_M5:
         step = 0.00011; break;
      case PERIOD_M15:
         step = 0.00015; break;
      case PERIOD_M30:
         step = 0.00021; break;
      case PERIOD_H1:
         step = 0.00028; break;   
   }
   return step;
}

double stepForUSDCHF(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.00009; break;
      case PERIOD_M5:
         step = 0.00013; break;
      case PERIOD_M15:
         step = 0.00015; break;
      case PERIOD_M30:
         step = 0.00014; break;
      case PERIOD_H1:
         step = 0.00017; break;   
   }
   return step;
}

double stepForIBEX35(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 1.634; break;
      case PERIOD_M5:
         step = 2.845; break;
      case PERIOD_M15:
         step = 4.011; break;
      case PERIOD_M30:
         step = 4.577; break;
      case PERIOD_H1:
         step = 6.647; break;   
   }
   return step;
}

double stepForCAC40(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 2.853; break;
      case PERIOD_M5:
         step = 1.543; break;
      case PERIOD_M15:
         step = 3.194; break;
      case PERIOD_M30:
         step = 3.733; break;
      case PERIOD_H1:
         step = 4.444; break;   
   }
   return step;
}

double stepForSP500(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.871; break;
      case PERIOD_M5:
         step = 0.793; break;
      case PERIOD_M15:
         step = 1.158; break;
      case PERIOD_M30:
         step = 1.289; break;
      case PERIOD_H1:
         step = 2.809; break;   
   }
   return step;
}

double stepForNQ100(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 5.914; break;
      case PERIOD_M5:
         step = 3.302; break;
      case PERIOD_M15:
         step = 4.369; break;
      case PERIOD_M30:
         step = 5.280; break;
      case PERIOD_H1:
         step = 6.082; break;   
   }
   return step;
}

double stepForGOLD(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.427; break;
      case PERIOD_M5:
         step = 0.517; break;
      case PERIOD_M15:
         step = 0.575; break;
      case PERIOD_M30:
         step = 0.571; break;
      case PERIOD_H1:
         step = 0.721; break;   
   }
   return step;
}

double stepForBRENT(int tf) {
   double step = 0.0;
   switch(tf) {
      case PERIOD_M1:
         step = 0.0367; break;
      case PERIOD_M5:
         step = 0.0163; break;
      case PERIOD_M15:
         step = 0.0212; break;
      case PERIOD_M30:
         step = 0.0272; break;
      case PERIOD_H1:
         step = 0.0542; break;   
   }
   return step;
}
