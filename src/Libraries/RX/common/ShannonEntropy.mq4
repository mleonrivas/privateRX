#property library ShannonEntropy
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define ENTROPY_PERIOD 200

extern double SH_ENT_EntropyCoeficient = 1.0;

/*
 Calculates the Shannon Entropy of the closing price, and returns whether it is within a standard deviation band from the last {ENTROPY_PERIOD}.
 It returns in which part of the STD DEV band the last entropy falls:
    > 0 if it is within the band.
    > 1 if it is above the band.
    > -1 if it is below the band.
*/
int shannonEntropy() {
   double entropies[ENTROPY_PERIOD];
   double log10_3 = MathLog10(3);
   for (int candle = 1; candle <= ENTROPY_PERIOD; candle++) {
      if(iClose(Symbol(), PERIOD_CURRENT, candle-1) != 0) {
         entropies[candle-1] =  MathLog10(iClose(Symbol(), PERIOD_CURRENT, candle) / iClose(Symbol(), PERIOD_CURRENT, candle-1)) / log10_3;
      } else {
         entropies[candle-1] = 0.0;
      }
   }

    // calc std dev on the values 
    double sigma = iStdDevOnArray(entropies, 0, ENTROPY_PERIOD, 0, MODE_SMA, 0);

    // last entropy data
    double lastEntropy = MathLog10(iClose(Symbol(), PERIOD_CURRENT, 2) / iClose(Symbol(), PERIOD_CURRENT, 1)) / log10_3;

    // classify into an entropy block
    if (lastEntropy > SH_ENT_EntropyCoeficient * sigma) {
        return 1; 
    }
    if (lastEntropy < -SH_ENT_EntropyCoeficient * sigma) {
        return -1;
    }
    return 0;
}

