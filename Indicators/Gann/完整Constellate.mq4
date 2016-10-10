//+------------------------------------------------------------------+
//|                                                  Constellate.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include "..\..\Experts\Utils\Gann.mqh"
#include "..\..\Experts\Utils\GannScale.mqh"

enum ENUM_RUNMODE
{
   求接下來低點,
   求接下來高點
};
extern ENUM_RUNMODE RunMode;//跑圖方向
extern double beginValue = 125.889;//起跑點
extern int times = 8;//欲跑段數
extern bool arrange_consecutiveNums = true;//降低連續值

Gann gann;
Constellate* Constellates[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   
//--- indicator buffers mapping
   double baseValue = 1;
   //double beginValue = 1235;//美日現今空頭司令
   double bGannValue = GannScale::ConvertToGannValue(Symbol(), beginValue);
   Alert("bGannValue: "+bGannValue);
   double step = 1;
   // 詢問建議圈數
   int recommandSize = gann.GetRecommandSize(baseValue, bGannValue, step, 2);
   gann.DrawSquare(1, step, recommandSize, DRAW_CW);  // CW為順時針
   
   
   // Constellate完整跑圖
   int runmode = RUN_HIGH;
   if(RunMode==求接下來低點){
      runmode = RUN_LOW;
   }

   gann.RunFullConstellate(runmode, bGannValue, step, times, arrange_consecutiveNums, Constellates);
   
   string result = NULL;
   for(int i =0;i<ArraySize(Constellates);i++){
      double value = GannScale::ConvertToValue(Symbol(), Constellates[i].value);
      result+=value+"("+Constellates[i].value+")"+", ";
      DrawLine("HLINE"+i, value);
   }
   Alert("result: "+result);
   
   
//---
   return(INIT_SUCCEEDED);
  }
  
  int deinit()
  {
//----
   ObjectsDeleteAll();
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_CHART_CHANGE){
      for(int i =0; i < ArraySize(Constellates);i++){
          double value = GannScale::ConvertToValue(Symbol(), Constellates[i].value);
         int part = Constellates[i].part;
         int x, y; 
         ChartTimePriceToXY(ChartID(), 0, Time[0], value, x, y); 
         x = ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS,0)-60;
         y-=15;
         //Alert("x: "+x);
         DrawLabel("TEXT"+i, "第"+part+"段目標價", x, y);
      }

   }
  }
//+------------------------------------------------------------------+

void DrawLine(string obj_name, double positionY){
   ObjectCreate(obj_name, OBJ_HLINE , 0, Time[0], positionY);
   ObjectSet(obj_name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(obj_name, OBJPROP_COLOR, Orange);
   ObjectSet(obj_name, OBJPROP_WIDTH, 2);
   //ObjectSetText(obj_name, "What you want to call your line", 8, "Arial", Orange); 
}

void DrawLabel(string obj_name, string text, double positionX, double positionY){
   ObjectCreate(obj_name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(obj_name, text, 7, "Verdana", Orange);
   ObjectSet(obj_name, OBJPROP_CORNER, 0);
   ObjectSet(obj_name, OBJPROP_XDISTANCE, positionX);
   ObjectSet(obj_name, OBJPROP_YDISTANCE, positionY);

}
