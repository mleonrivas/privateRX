#property library IFilter
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

interface IFilter {
   /**
    *  Returns true if the current conditions pass the filter.
    */ 
   bool check();
};