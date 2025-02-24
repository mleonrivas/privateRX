#property library IWorkflow
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"

interface IWorkflow {
   /**
    *  It processes the tick information plus the combined signal from the thread+classifier+filters
    *  It returns:
    *   - -1 when the risk for the account has been exhausted. It indicates a failure of the algorithm and it should stop the expert.
    *   - 0 when the signal was not used.
    *   - 1 when the signal was used
    **/
    int processTickAndOp(double askPrice, double bidPrice, Operation op);

    bool isCompleted();

    bool isFailed();

    bool hasFinished();

    /**
     * releases objects in memory (shutdown)
    */
    void release();

    void writeStats(string fileName);
};