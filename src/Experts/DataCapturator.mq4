//+------------------------------------------------------------------+
//|                                                    DataCapturator.mq4 |
//|                                            Scientia Trader QuanT |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\Libraries\\RX\\threads\\Thread.mq4"
#include "..\\Libraries\\RX\\threads\\RandomThread.mq4"
#include "..\\Libraries\\RX\\threads\\EntropyAndATRThread.mq4"
#include "..\\Libraries\\RX\\threads\\GoldAndBlueStochasticThread.mq4"
#include "..\\Libraries\\RX\\common\\Operation.mq4"
#include "..\\Libraries\\RX\\orders\\MarketOrder.mq4"
#include "..\\Libraries\\RX\\common\\List.mq4"
#include "..\\Libraries\\RX\\common\\DataRecord.mq4"
#include "..\\Libraries\\RX\\filters\\IFilter.mq4"
#include "..\\Libraries\\RX\\filters\\FilterFactory.mq4"
#include "..\\Libraries\\RX\\targets\\TargetSelectors.mq4"

input double   InitTargetDistance = 6.4;
input double   InitCoverDistance = 6.0;

IThread *rt;
List<DataRecord> *records;
MarketOrder *currentOrder = NULL;
int ref = 0;

int OnInit() {
    int tf = Period();
    if (tf != PERIOD_M1 && tf != PERIOD_M5 && tf != PERIOD_M15 && tf != PERIOD_M30 && tf != PERIOD_H1) {
        Print("CAN'T START, DATA CAPTURATOR ONLY WORKS FOR PERIODS M1, M5, M15, M30, H1");
        return INIT_FAILED;
    }
    //rt = new RandomThread(); 
    //rt = new EntropyAndATRThread(ATRPeriod, ATRFrequentBandPercentage);
    rt = new GoldAndBlueStochasticThread();
    MonetaryManagement::setup(0.01, 0.2);
    TargetSelectors::setup(InitCoverDistance, InitTargetDistance);
    records = new List<DataRecord>();
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    saveData();
    MonetaryManagement::release();
    TargetSelectors::release();
    delete rt;
    rt = NULL;
    records.release();
    delete records;
    records = NULL;
}

void saveData() {
    int fd = FileOpen("DataCapturator-BCKT.csv", FILE_WRITE|FILE_READ|FILE_CSV, ';', CP_UTF8);
    if (fd < 0) {
        Print("ERROR WRITING STATS");
        return;
    }
    int size = records.size();
    for (int i=0; i<size; i++) {
        DataRecord *dr = records.get(i);
        if(FileSeek(fd, 0, SEEK_END)) {
            FileWrite(fd, dr.order.orderId, dr.order.profit, dr.volume);
        }
        
    }
    

    FileClose(fd);
}

bool isOrderClosed() {
    if(currentOrder == NULL) {
        return false;
    }
    if(OrderSelect(currentOrder.orderId, SELECT_BY_TICKET, MODE_TRADES) == true) {
        return OrderCloseTime() > 0;
    }
    return false;

}

void OnTick() {
    //check order
    if (isOrderClosed()) {
        currentOrder.consolidateProfit();
        currentOrder = NULL;
    }
    double midPrice = (Ask + Bid)/2;
    Operation op = rt.OnTick();
    if (currentOrder == NULL && op != NO_OP) {
        double sl = 0.0;
        double tp = 0.0;
        if(op == BUY) {
            sl = midPrice - InitCoverDistance;
            tp = midPrice + InitTargetDistance;
        } else {
            sl = midPrice + InitCoverDistance;
            tp = midPrice - InitTargetDistance;
        }
        ref = ref + 1;
        currentOrder = new MarketOrder(op, 1, ref, sl, tp);
        currentOrder.send();
        records.add(new DataRecord(currentOrder));
    }
}
