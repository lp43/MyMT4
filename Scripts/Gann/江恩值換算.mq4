//+------------------------------------------------------------------+
//|                                                         江恩換算.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property show_inputs

#include "..\..\Experts\Utils\GannScale.mqh"

enum ENUM_SYMBOL{
   EURUSD,
   USDJPY
};
input ENUM_SYMBOL Country = EURUSD; //請輸入幣別
input double Value; //請輸入欲計算價位

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
 double gannValue;
   switch(Country){
      case EURUSD:{
          gannValue = GannScale::ConvertToGannValue("EURUSD", Value);
       break;
      }
      case USDJPY:{
          gannValue = GannScale::ConvertToGannValue("USDJPY", Value);
         break;
      }
   }
   Alert(Value+"'s GannValue is: "+gannValue);
   
  }
//+------------------------------------------------------------------+
