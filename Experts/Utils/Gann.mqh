//+------------------------------------------------------------------+
//|                                                         Gann.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Cursor.mqh"

Cursor cursor;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Gann
  {
private:
                    int NowInsertIdx;
                    void GenerateValues(double &values[], double begin, double step, int size);
                    void InsertValues(double &values[], int size, bool isCW);
                    void InsertValueLeftToRight(double &values[]);
                    void InsertValueBottomToTop(double &values[]);
                    void InsertValueRightToLeft(double &values[]);
                    void InsertValueTopToBottom(double &values[]);
                    bool IsCursorOnCenter();
public:
                     Gann();
                    ~Gann();
                    void DrawSquare(double begin, double step, int size, bool isCW); //CW 順時針
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Gann::Gann()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Gann::~Gann()
  {
  }
//+------------------------------------------------------------------+
Gann::DrawSquare(double begin, double step, int size, bool isCW)
{
     double Values[];
     
   GenerateValues(Values, begin, step, size);
   InsertValues(Values, size, isCW);
   
  
}
void Gann::GenerateValues(double &values[], double begin, double step, int size)
{
   int length = MathPow(((1+size)+size),2);// 總數=(size+1)+(size)的平方
   ArrayResize(values, length);
   
   for(int i = 0;i<ArraySize(values);i++){
      if(i==0){
         values[i]=begin;
      }else{
         values[i] = values[i-1]+step;
      }
  
   }
}
void Gann::InsertValues(double &values[], int size, bool isCW)
{
   // 開出一個空白江恩矩形的矩陣
   cursor.InitSquareArray(size);
 
 //=========開始將產生出來的值塞入江恩矩陣================
   int position[2];
   // 先將指標移至最後一筆
   int last = cursor.GetLastIdxOnChart(isCW);
   cursor.SetCursorTo(last);
   NowInsertIdx = ArraySize(values)-1;
   cursor.SetValue(values[NowInsertIdx]);
   
   // 再用迴圈將江恩值由外圍向內圍塞完
   if(isCW){ // 順時針
      
      do{
         InsertValueLeftToRight(values);
         InsertValueBottomToTop(values);
         InsertValueRightToLeft(values);
         InsertValueTopToBottom(values);
      }
      while(IsCursorOnCenter() == FALSE);
   }else{  //逆時針
      do{
         InsertValueRightToLeft(values);
         InsertValueBottomToTop(values);
         InsertValueLeftToRight(values);
         InsertValueTopToBottom(values);
      }
      while(IsCursorOnCenter() == FALSE);
   }
 
   
   cursor.PrintSquare();

}

void Gann::InsertValueLeftToRight(double &values[])
{  

 //Alert("InsertValueLeftToRight, Start From InsertIdx: "+NowInsertIdx);
    while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Right())
    {
         if(cursor.HasValue()==FALSE)
         {
            cursor.SetValue(values[--NowInsertIdx]); 
         
            int positions[2];
            cursor.GetCursorPosition(positions);
            Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));
         }else{
            if(IsCursorOnCenter() == FALSE){
               cursor.Left();//因為已填值，因此將指針移回前一位置
            }
            break;
            
         }
         
    }
}

void Gann::InsertValueBottomToTop(double &values[])
{  
      //Alert("InsertValueBottomToTop, Start From InsertIdx: "+NowInsertIdx);
   
    while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Up())
    {
         if(cursor.HasValue()==FALSE)
         {
             cursor.SetValue(values[--NowInsertIdx]); 
         
             int positions[2];
             cursor.GetCursorPosition(positions);
             Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));
         }else{
               if(IsCursorOnCenter() == FALSE){
                  cursor.Down();//因為已填值，因此將指針移回前一位置
               }
               break;
         }
    }
}

void Gann::InsertValueRightToLeft(double &values[])
{  
      //Alert("InsertValueRightToLeft, Start From InsertIdx: "+NowInsertIdx);
      while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Left())
       {
            if(cursor.HasValue()==FALSE)
            {
               cursor.SetValue(values[--NowInsertIdx]); 
            
               int positions[2];
               cursor.GetCursorPosition(positions);
               Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));     
            }else{
               if(IsCursorOnCenter() == FALSE){
                  cursor.Right();//因為已填值，因此將指針移回前一位置
               }
               break;
            }
            
       }
}

void Gann::InsertValueTopToBottom(double &values[])
{  
    //Alert("InsertValueTopToBottom, Start From InsertIdx: "+NowInsertIdx);
       while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Down())
       {
            if(cursor.HasValue()==FALSE){
               cursor.SetValue(values[--NowInsertIdx]); 
            
               int positions[2];
               cursor.GetCursorPosition(positions);
               Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));  
            }else{
               if(IsCursorOnCenter() == FALSE){
                  cursor.Up();//因為已填值，因此將指針移回前一位置
               }
               break;
            }
         
       }
}

bool Gann::IsCursorOnCenter(void)
{
   return cursor.GetCursorIdx() == cursor.GetCenterIdx();
}