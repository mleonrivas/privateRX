
#property library FilterFactory
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\List.mq4"
#include ".\\IFilter.mq4"
#include ".\\ATRGreaterThanFrequentATRFilter.mq4"
#include ".\\DayATRFilter.mq4"
#include ".\\HourFilter.mq4"
#include ".\\DirectionRatioFilter.mq4"
#include ".\\VolatilityFilter.mq4"

extern int FT_HourStart = 14;
extern int FT_HourEnd = 22;
extern double FT_AtrPeriod = 14;

void populateFilters(List<IFilter> *filters, string filtersString) {
   ushort sep = StringGetCharacter(",", 0);
   string filterNames[];
   int k = StringSplit(filtersString, sep, filterNames);
   for (int i=0; i<k; i++) {
      IFilter *f = getFilterByName(filterNames[i]);
      if (f != NULL) {
         filters.add(f);
      } else {
        Print("WARNING: FILTER %s NOT FOUND", filterNames[i]);
      }
   }
}

IFilter* getFilterByName(string filterName) {
    if (filterName == "ATR_HT_FATR") {
        return new ATRGreaterThanFrequentATRFilter(FT_AtrPeriod);
    } else if (filterName == "DAY_ATR") {
        return new DayATRFilter();
    } else if (filterName == "HOUR") {
        return new HourFilter(FT_HourStart, FT_HourEnd);
    } else if (filterName == "DIR_RATIO") {
        return new DirectionRatioFilter();
    } else if (filterName == "VOLAT") {
        return new VolatilityFilter();
    }
    return NULL;
}