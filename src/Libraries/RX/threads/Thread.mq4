#property library IThread
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\common\\Operation.mq4"

interface IThread {
   Operation OnTick();
};
