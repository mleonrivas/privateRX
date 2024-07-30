#property library RecoveryListenerRegistry
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\List.mq4"
#include ".\\IRecoveryEventListener.mq4"

class RecoveryListenerRegistry : IRecoveryEventListener {
   private:
      // singleton instance
      static RecoveryListenerRegistry *instance;
      List<IRecoveryEventListener> *listeners;

      RecoveryListenerRegistry() {
         this.listeners = new List<IRecoveryEventListener>();
      }

      void releaseInstance() {
         this.listeners.release();
         delete listeners;
         listeners = NULL;
      }
      
   public: 
      static RecoveryListenerRegistry* get() {
         if (!instance) {
            instance = new RecoveryListenerRegistry();
         }
         return instance;
      }

      // Releases de Global instance of the MonetaryManagement.
      static void release() {
         instance.releaseInstance();
         delete instance;
         instance = NULL;
      }

      void registerListener(IRecoveryEventListener *listener) {
         this.listeners.add(listener);
      }

      void started(int id, int level) {
         for (int i=0; i<this.listeners.size(); i++) {
            this.listeners.get(i).started(id, level);
         }
      }

      void hitCover(int id, int level, int step) {
         for (int i=0; i<this.listeners.size(); i++) {
            this.listeners.get(i).hitCover(id, level, step);
         }
      }

      void hitTarget(int id, int level, int step) {
         for (int i=0; i<this.listeners.size(); i++) {
            this.listeners.get(i).hitTarget(id, level, step);
         }
      }

      void completed(int id, int level, int step) {
         for (int i=0; i<this.listeners.size(); i++) {
            this.listeners.get(i).completed(id, level, step);
         }
      }

      void triggeredNestedRecovery(int id, int level, int step) {
         for (int i=0; i<this.listeners.size(); i++) {
            this.listeners.get(i).triggeredNestedRecovery(id, level, step);
         }
      }
};
// Need to create the instance like this, forced by the MQL4 compiler.
RecoveryListenerRegistry* RecoveryListenerRegistry::instance = NULL;
