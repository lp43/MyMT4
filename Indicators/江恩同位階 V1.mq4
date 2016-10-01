//+------------------------------------------------------------------+
//|                                                        江恩同位階.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_color1 Blue // Long signal
#property indicator_color2 Red // Short signal
#property indicator_width1 5 // Long signal arrow
#property indicator_width2 5 // Short signal arrow

#include "..\Experts\Utils\Gann.mqh"
#include "..\Experts\Utils\GannScale.mqh"

int margin = 50;
extern int 欲繪圖天數 = 90;
extern int 同位階價位比對天數 = 30; //比對該值一個月內的同位階
extern double 基數值 = 1;
extern double 每步間隔 = 1;
enum ENUM_TRADELEADER
{
   空方司令,
   多方司令
};
extern ENUM_TRADELEADER 盤勢目前主導人; 

double         UpArrowBuffer[]; 
double         DownArrowBuffer[];
int Icon[] = {140, 141, 142, 143, 144, 145, 146, 147, 148, 149};
color Color[] = {clrOldLace, clrRed, clrDarkViolet, clrDarkTurquoise, clrMediumSpringGreen, clrLightGray, clrGoldenrod, clrLavenderBlush
	, clrSeaGreen,  	clrLightSalmon};
class SameLevelObj{
   public:
      int shift;
      double price;
      double gannValue;
};
class SameLevelGroup{
 public:
   SameLevelObj *GroupArray[]; 
};

SameLevelGroup *SameLevelPool[]; 


Gann gann;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //---- 詢問建議圈數
   double beginValue = 1235;//美日現今空頭司令
   int recommandSize = gann.GetRecommandSize(基數值, beginValue, 每步間隔, 2);
   gann.DrawSquare(1, 每步間隔, recommandSize, DRAW_CW);  // CW為順時針
   
   int beginValueType = IS_LOW;
   if(盤勢目前主導人 == 多方司令){
      beginValueType = IS_HIGH;
   }
   Alert("beginValueType: "+beginValueType);
   
  //---- 開始檢查同位階
  for(int i = 0; i< 欲繪圖天數;i++){
   //Alert("value i: "+i);
      //---- 先找出轉折點位
      double value = iCustom(Symbol(), Period(), "趨勢轉向", 0, i);
      
      //---- 從轉折點中找出同位階
      if(value!=EMPTY_VALUE){
          //Alert("value i: "+i+" Time: "+TimeToStr(Time[i], TIME_DATE|TIME_MINUTES)+" is: "+value);
          string time1 = TimeToStr(iTime(Symbol(), Period(), i), TIME_DATE);
          double price1 = Low[i];

          
         //Alert("至低點為: "+TimeToStr(Time[i], TIME_DATE | TIME_MINUTES)+", 價位在: "+Low[i]);
          double gannValue1 = GannScale::ConvertToGannValue(Symbol(), price1);

          //同位階測試
          double SameLevel = gann.RunSameLevel(gannValue1, beginValueType, 每步間隔); 
     
          int FoundSameLevelShift = FindSameLevelShift(i, 同位階價位比對天數, SameLevel);
          if(FoundSameLevelShift!=-1){
                string time2 = TimeToStr(iTime(Symbol(), Period(), FoundSameLevelShift), TIME_DATE);
                double price2 = iLow(Symbol(), Period(), FoundSameLevelShift);
                //double price2 = Low[FoundSameLevelShift];
                double gannValue2 = GannScale::ConvertToGannValue(Symbol(), price2);
                //Alert("======"+i+" ["+time1+"] "+DoubleToStr(value1, Digits)+"("+gannValue1+")"+" 出現同位階 ,對應點位 "+FoundSameLevelShift+"["+time2+"]" +DoubleToStr(value2, Digits)+"("+gannValue2+") ======");
                
                SameLevelObj *sameLevelObj_1 = new SameLevelObj();
                sameLevelObj_1.shift = i;
                sameLevelObj_1.price = price1;
                sameLevelObj_1.gannValue = gannValue1;
                
                SameLevelObj *sameLevelObj_2 = new SameLevelObj();
                sameLevelObj_2.shift = FoundSameLevelShift;
                sameLevelObj_2.price = price2;
                sameLevelObj_2.gannValue = gannValue2;
                
                AddToSameLevelPool(sameLevelObj_1, sameLevelObj_2);
          }
      
      }
        
   }
//---
   return(INIT_SUCCEEDED);
  }
  
  int FindSameLevelShift(int start_shift, int find_days, double gann_value1){
         int returnShift = -1;
            //檢查全部K棒Loading太重，因此只檢查前後15天
          for(int j = start_shift-(find_days/2); j <start_shift+(find_days/2); j++){
             //單位轉換測試
             
             double gannValue2 = GannScale::ConvertToGannValue(Symbol(), iLow(Symbol(), Period(), j));
             if(gannValue2 == gann_value1){
                returnShift = j;
                break;
             }
          }
      return returnShift;
  }
  
  void AddToSameLevelPool(SameLevelObj *obj_1, SameLevelObj *obj_2){
      //Alert("obj1_1: "+obj_1.shift+", obj_2: "+obj_2.shift);
      int idx_1 = FindSameLevelGroupIdxFromPool(obj_1.gannValue);
      int idx_2 = FindSameLevelGroupIdxFromPool(obj_2.gannValue);
      if(idx_1==-1 & idx_2==-1){
         Alert("江恩值 "+obj_1.gannValue+"、"+obj_2.gannValue+" 尚未放入同位階池");
         
         SameLevelGroup *group = new SameLevelGroup();
         ArrayResize(group.GroupArray, 2, 0);
         group.GroupArray[0]=obj_1;
         group.GroupArray[1]=obj_2;
         
         int size_samelevelpool = ArraySize(SameLevelPool);
         ArrayResize(SameLevelPool, ++size_samelevelpool);
         SameLevelPool[size_samelevelpool-1] = group;
         
      }else{
         if(idx_1!=-1){
            //Alert("即將將江恩值: "+obj_2.gannValue+"放入同位階池idx: "+idx_1);
            
            int size_samelevelpool_group = ArraySize(SameLevelPool[idx_1].GroupArray);
            ArrayResize(SameLevelPool[idx_1].GroupArray, ++size_samelevelpool_group);
            SameLevelPool[idx_1].GroupArray[size_samelevelpool_group-1] = obj_2;
         }
         if(idx_2!=-1){
            //Alert("即將將江恩值: "+obj_1.gannValue+"放入同位階池idx: "+idx_2);
            
            int size_samelevelpool_group = ArraySize(SameLevelPool[idx_2].GroupArray);
            ArrayResize(SameLevelPool[idx_2].GroupArray, ++size_samelevelpool_group);
            SameLevelPool[idx_2].GroupArray[size_samelevelpool_group-1] = obj_1;
         }
      }
      PrintPool();
  }
  
  int FindSameLevelGroupIdxFromPool(double find_gannvalue){
      int returnGroupIndex = -1;
      for(int i =  0; i < ArraySize(SameLevelPool);i++){
         int size_samelevelpool = ArraySize(SameLevelPool);
         if(size_samelevelpool>0){
            int size_samelevelpool_grouparray = ArraySize(SameLevelPool[i].GroupArray);
            if(size_samelevelpool_grouparray>0){
               for(int j = 0 ; j< size_samelevelpool_grouparray;j++){
                  SameLevelObj* obj = SameLevelPool[i].GroupArray[j];
                  if(obj.gannValue == find_gannvalue){
                     returnGroupIndex = i;
                     break;
                  }
               }
            }
         }
      }
      return returnGroupIndex;
  }
  
  void PrintPool(){
    Alert("同位階池共有"+ ArraySize(SameLevelPool)+"組同位階陣列");
    
    for(int i = 0; i < ArraySize(SameLevelPool);i++){
      string temp = NULL;
      for(int j = 0;j<ArraySize(SameLevelPool[i].GroupArray);j++){
         //temp +=SameLevelPool[i].GroupArray[j].gannValue+" ";
         temp +="["+SameLevelPool[i].GroupArray[j].shift+"]"+SameLevelPool[i].GroupArray[j].price+"("+SameLevelPool[i].GroupArray[j].gannValue+") ";
      }
      Alert("第"+i+"組同位階陣列有"+ temp);
      temp = NULL;
    }
  }
  
   int deinit()
  {
//----
   ObjectsDeleteAll();
//----
   return(0);
  }
  
  int start()
   {
      
     //int limit;
     //int counted_bars=IndicatorCounted();
     // //---- check for possible errors
     //if(counted_bars<0) return(-1);
     // //---- the last counted bar will be recounted
     //if(counted_bars>0) {
     //    counted_bars--;
     //  //Alert("counted_bars: "+counted_bars);
     //}
     //limit=Bars-counted_bars;

      for(int i = 0; i<ArraySize(SameLevelPool);i++){  
         Alert("====即將繪製第"+i+"組====");
         //Alert("shift_1: "+Same[i].shift1+", Time is: "+Time[Same[i].shift1]);
         //Alert("shift_2: "+Same[i].shift2+", Time is: "+Time[Same[i].shift2]);
         
         
         for(int j = 0; j < ArraySize(SameLevelPool[i].GroupArray); j++){
            string object_name="SameLevel_"+i+"-"+j;
            if(ObjectCreate(object_name,OBJ_ARROW,0,Time[SameLevelPool[i].GroupArray[j].shift], SameLevelPool[i].GroupArray[j].price))
            {  
               ObjectSetInteger(ChartID(),object_name,OBJPROP_ARROWCODE,Icon[i]);
               ObjectSet (object_name,OBJPROP_COLOR,Color[i]);         
            }
         }

     }
     
      
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

