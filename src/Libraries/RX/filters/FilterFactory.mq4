
#property library FilterFactory
#property copyright "Scientia Trader QuanT"
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

struct FiltersParameters {
   int atrPeriod;
   int hourStart;
   int hourEnd;
};

void populateFilters(List<IFilter> *filters, string filtersString, FiltersParameters &params) {
   ushort sep = StringGetCharacter(",", 0);
   string filterNames[];
   int k = StringSplit(filtersString, sep, filterNames);
   for (int i=0; i<k; i++) {
      IFilter *f = getFilterByName(filterNames[i], params);
      if (f != NULL) {
         filters.add(f);
      } else {
        Print("WARNING: FILTER %s NOT FOUND", filterNames[i]);
      }
   }
}

IFilter* getFilterByName(string filterName, FiltersParameters &params) {
    if (filterName == "ATR_HT_FATR") {
        return new ATRGreaterThanFrequentATRFilter(params.atrPeriod);
    } else if (filterName == "DAY_ATR") {
        return new DayATRFilter();
    } else if (filterName == "HOUR") {
        return new HourFilter(params.hourStart, params.hourEnd);
    } else if (filterName == "DIR_RATIO") {
        return new DirectionRatioFilter();
    } else if (filterName == "VOLAT") {
        return new VolatilityFilter();
    }
    return NULL;
}