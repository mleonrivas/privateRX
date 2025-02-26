#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\Libraries\\RX\\threads\\Thread.mq4"
#include "..\\Libraries\\RX\\threads\\RandomThread.mq4"
#include "..\\Libraries\\RX\\threads\\EntropyAndATRThread.mq4"
#include "..\\Libraries\\RX\\threads\\GoldAndBlueStochasticThread.mq4"
#include "..\\Libraries\\RX\\common\\Operation.mq4"
#include "..\\Libraries\\RX\\common\\MonetaryManagement.mq4"
#include "..\\Libraries\\RX\\common\\List.mq4"
#include "..\\Libraries\\RX\\common\\License.mq4"
#include "..\\Libraries\\RX\\workflows\\IWorkflow.mq4"
#include "..\\Libraries\\RX\\workflows\\RecoveryWorkflow.mq4"
#include "..\\Libraries\\RX\\workflows\\ThreadTesterWorkflow.mq4"
#include "..\\Libraries\\RX\\filters\\IFilter.mq4"
#include "..\\Libraries\\RX\\filters\\FilterFactory.mq4"
#include "..\\Libraries\\RX\\targets\\TargetSelectors.mq4"
#include "..\\Libraries\\RX\\events\\RecoveryListenerRegistry.mq4"

#define MAX_ALLOWED_PARALLEL_RECOVERIES 1

//--- input parameters
// Values suggested for XAUUSD in M5.
input int      EXPERT_TestThreadWithoutRecovery = 0;
input int      EXPERT_EnableFilters = 0;
input string   EXPERT_UseFilters = "ATR_HT_FATR,DAY_ATR,HOUR,DIR_RATIO,VOLAT";

IThread *rt;
ITargetSelector *targetSelector;
List<IWorkflow> *openWorkflows;
List<IFilter> *filters;


int OnInit() {
   Print("Initializing...");
   Print("Broker: ", AccountCompany());
   Print("Account Holder: ", AccountName());
   Print("Account Holder-Hex: ", asciiToHex(AccountName()));
   Print("Account Number: ", IntegerToString(AccountNumber()));
   Print("Server:", AccountServer());
   dcl();
   int tf = Period();
   if (tf != PERIOD_M1 && tf != PERIOD_M5 && tf != PERIOD_M15 && tf != PERIOD_M30 && tf != PERIOD_H1) {
      Print("CAN'T START, RECOVERY ONLY WORKS FOR PERIODS M1, M5, M15, M30, H1");
      return INIT_FAILED;
   }
   openWorkflows = new List<IWorkflow>();
   //rt = new RandomThread(); 
   //rt = new EntropyAndATRThread();
   rt = new GoldAndBlueStochasticThread();

   RecoveryListenerRegistry::get();
   
   filters = new List<IFilter>();
   if (EXPERT_EnableFilters > 0) {
      populateFilters(filters, EXPERT_UseFilters);   
   }
   
   if (!MonetaryManagement::get().checkValidParams()) {
      return INIT_FAILED;
   };
   if (!RecoveryWorkflow::validateParams()) {
      return INIT_FAILED;
   };
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   for (int i=0; i<openWorkflows.size(); i++) {
      openWorkflows.get(i).release();
   }
   MonetaryManagement::release();
   TargetSelectors::release();
   RecoveryListenerRegistry::release();
   delete rt;
   openWorkflows.release();
   delete openWorkflows;
   filters.release();
   delete filters;
}

bool passAllFilters() {
   bool passFilters = true;
   int i=0;
   while (passFilters && i<filters.size()) {
      passFilters = passFilters && filters.get(i).check();
      i++;
   }
   return passFilters;
}

void OnTick() {
   // If the filters do not pass, do not start new workflows, including nested workflows. 
   // But allow workflows to continue if already open. 
   Operation op = NO_OP;
   if (passAllFilters()) {
      op = rt.OnTick();
   }

   int size = openWorkflows.size();
   for (int i = 0; i < size; i++) {
      int res = openWorkflows.get(i).processTickAndOp(Ask, Bid, op);
      // has signal been used?
      if (res == 1) {
         // signal should be used only once to avoid putting too much risk in the same entry. 
         op = NO_OP;
      }
      if (openWorkflows.get(i).isFailed()) {
         Print("Closing due to failed workflow");
         ExpertRemove();
         return;
      }
   }
   // remove all completed workflows
   if (Bars%3 == 0) {
      dcl();
   }
   int i = 0;
   while (i < size) {
      if (openWorkflows.get(i).hasFinished()) {
         IWorkflow *wf = openWorkflows.remove(i);
         wf.release();
         delete wf;
         //Print("OT: --- DELETE WORKFLOW in ", i, " workflows; Size ", size, " -> ", openWorkflows.size());
      } else {
         i++;
      }
      size = openWorkflows.size();
   }
   
   // if op is still BUY or SELL, then signal wasn't used, so let's open a new operation.
   if (op != NO_OP && size < MAX_ALLOWED_PARALLEL_RECOVERIES) {
      if (EXPERT_TestThreadWithoutRecovery == 0) {
         openWorkflows.add(new RecoveryWorkflow(1));
      } else {
         openWorkflows.add(new ThreadTesterWorkflow());
      }
      Print("OT: --- ADDED new workflow. Size ", size, " -> ", openWorkflows.size());
      openWorkflows.get(openWorkflows.size()-1).processTickAndOp(Ask, Bid, op);
   }
}
