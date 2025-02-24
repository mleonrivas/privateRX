#property library IFilter
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

interface IFilter {
   /**
    *  Returns true if the current conditions pass the filter.
    */ 
   bool check();
};