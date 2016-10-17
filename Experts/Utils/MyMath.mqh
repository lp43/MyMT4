//+------------------------------------------------------------------+
//|                                                       MyMath.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "../instance/GannValue.mqh"
#include "../instance/CursorValue.mqh"
//#include "Debug.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyMath
  {
private:
                    static void ConstellateArraySort(GannValue* &src_array[], int count,int start_idx, int sort_dir );
                    static void ConsArrayToDoubleArray(double &des_array[][], GannValue* &src_array[]);
                    static void PrintArray(string msg, GannValue* &array[]);
                    static void PrintArray(string msg, double &array[][1]);
public:
                     MyMath();
                    ~MyMath();
                    static double FindClosest(double &array[], double value);
                    static double FindClosest(CursorValue* &array[], double value);
                    static void ReverseArray(double &src_array[], double & des_array[]);
                    static int FindIdxByValue(CursorValue* &src_array[], double value);
                    static int FindIdxByValue(double &src_array[], double value);
                    static GannValue* GetMinimumConstellate(GannValue* &src_array[]);
                    static GannValue* GetMaximumConstellate(GannValue* &src_array[]);
                    static double GetMinimumValue(double &src_array[]);
                    static double GetMaximumValue(double &src_array[]);
                    static void DeleteConsecutiveNums(double &src_array[], double begin_value, double step);
                    static int GetDecimalBits(double target);
                    static bool HasDecimalBits(double target);
                    static void ArrangeConstellate(bool run_type, GannValue* &src_array[]);
                    static double GetHighestPrice(int count, int start_shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyMath::MyMath()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyMath::~MyMath()
  {
  }
//+------------------------------------------------------------------+
static double MyMath::FindClosest(double &array[],double value)
{
    double min = EMPTY_VALUE;
    double closest = value;

    for (double v : array) {
        double diff = MathAbs(v - value);

        if (diff < min) {
            min = diff;
            closest = v;
        }
    }

    return closest;
}
static double MyMath::FindClosest(CursorValue* &array[],double value)
{
    double min = EMPTY_VALUE;
    double closest = value;

    for (CursorValue* v : array) {
        double diff = MathAbs(v.value - value);

        if (diff < min) {
            min = diff;
            closest = v.value;
        }
    }

    return closest;
}

static void MyMath::ReverseArray(double &src_array[], double &des_array[])
{
   int src_array_size = ArraySize(src_array);
   ArrayResize(des_array, src_array_size, 0);
   for( int i = src_array_size - 1; i >= 0; i-- ) {
      int desIdx = src_array_size - i - 1;
      des_array[desIdx] = src_array[i];
      //Alert("reverse::: src i = "+i+" => des i = "+desIdx);
   }
}

static int MyMath::FindIdxByValue(double &src_array[], double value)
{
    int found_idx = -1;
    int size = ArraySize(src_array);
    //Alert("size src_array is : "+size);
    for(int i =0;i<size;i++){
      //Alert("i: "+i+" is "+src_array[i]+", want to find: "+value);
      if(src_array[i]==value){
         found_idx = i;
         break;
      }
    }
    return found_idx;
}

static int MyMath::FindIdxByValue(CursorValue* &src_array[], double value)
{
    int found_idx = -1;
    for(int i =0;i<ArraySize(src_array);i++){
      //Alert("i: "+i+" is "+src_array[i]);
      if(src_array[i].value==value){
         found_idx = i;
         break;
      }
    }
    return found_idx;
}

static GannValue* MyMath::GetMinimumConstellate(GannValue* &src_array[])
{
   GannValue *minConstellate = NULL;
   
   double doubleArray[][2];
   ConsArrayToDoubleArray( doubleArray, src_array);
   int MinIdx = ArrayMinimum(doubleArray, WHOLE_ARRAY, 0);
   double MinValue = doubleArray[MinIdx][0];
   int SrcIdx = doubleArray[MinIdx][1];
   //Alert("MinValue: "+MinValue+", value is: "+MinValue+", SrcIdx is: "+SrcIdx);
   if(MinIdx>=0){
      minConstellate = src_array[SrcIdx];
   }else{
      minConstellate = NULL;;
   }
   return minConstellate;
}

static GannValue* MyMath::GetMaximumConstellate(GannValue* &src_array[])
{
   GannValue *maxConstellate = NULL;
   
   double doubleArray[][2];
   ConsArrayToDoubleArray( doubleArray, src_array);
   int MaxIdx = ArrayMaximum(doubleArray, WHOLE_ARRAY, 0);
   double MaxValue = doubleArray[MaxIdx][0];
   int SrcIdx = doubleArray[MaxIdx][1];
   //Alert("MaxIdx: "+MaxIdx+", value is: "+MaxValue+", SrcIdx is: "+SrcIdx);
   if(MaxIdx>=0){
      maxConstellate = src_array[SrcIdx];
   }else{
      maxConstellate = NULL;
   }
   return maxConstellate;
}

static double MyMath::GetMinimumValue(double &src_array[])
{
   double minValue = EMPTY_VALUE;
   int MinIdx = ArrayMinimum(src_array, WHOLE_ARRAY, 0);
   //Alert("MnIdx: "+MinIdx);
   if(MinIdx>=0){
      minValue = src_array[MinIdx];
   }else{
      minValue = EMPTY_VALUE;
   }
   return minValue;
}

static double MyMath::GetMaximumValue(double &src_array[])
{
   double maxValue = EMPTY_VALUE;
   int MaxIdx = ArrayMaximum(src_array, WHOLE_ARRAY, 0);
   //Alert("MaxIdx: "+MaxIdx);
   if(MaxIdx>=0){
      maxValue = src_array[MaxIdx];
   }else{
      maxValue = EMPTY_VALUE;
   }
   return maxValue;
}

static void MyMath::DeleteConsecutiveNums(double &src_array[], double begin_value, double step)
{
   // 1.將啟始值帶進來，目的預防漏算第1筆目標值是否為連續值
   double compute_array[];
   int src_size = ArraySize(src_array);
   ArrayResize(compute_array, ++src_size, 0);
   compute_array[0]=begin_value;
   for(int i = 0 ; i<ArraySize(src_array);i++){
      compute_array[i+1] = src_array[i];
   }
   
   // 2.將不是連續數的值存進暫存temp array
   double temp[];
   int compute_array_size = ArraySize(compute_array);
   for(int j = 1; j < compute_array_size; j++){
      //Alert("j is: "+j +", diff is: "+MathAbs(compute_array[j]-compute_array[j-1]));
      if(MathAbs(compute_array[j]-compute_array[j-1]) != MathAbs(step)){
         //Alert("j is: "+j);
         int tmp_size = ArraySize(temp);
         ArrayResize(temp, ++tmp_size);
         temp[tmp_size-1]=compute_array[j];
         //Alert("add: "+temp[tmp_size-1]);
      }
   }
   
   // 3.將temp array存回src_array
   ArrayResize(src_array, ArraySize(temp), 0);
   ArrayCopy(src_array, temp, 0, 0, WHOLE_ARRAY);
}

static int MyMath::GetDecimalBits(double target) {
    int decimalbits = 0;
    
    if(HasDecimalBits(target)){
        double testingTarget = target;
        for(int i = 1; i< 20; i++){
            double pow = MathPow(10, i);
            double testingTarget = testingTarget * pow;
            if(HasDecimalBits(testingTarget) == FALSE){
               //Alert("testingTarget "+testingTarget+" ,pow "+pow);
               decimalbits = i;
               break;
            }
        }
    }
    return decimalbits;
}

static bool MyMath::HasDecimalBits(double target)
{  
   bool hasDecimal = (0.0 != MathMod(target, 1));
   if(hasDecimal == FALSE){
      //Alert(target+ " has no DecimalBits");
   }
   return hasDecimal;
}

static void MyMath::ConsArrayToDoubleArray(double &des_array[][], GannValue* &src_array[]){
   int size_src2 = ArraySize(src_array);
   //Alert("size_src2: "+size_src2);
   ArrayResize(des_array, size_src2, 0);
          
   for(int i = 0; i<size_src2;i++){
      des_array[i][0]=src_array[i].value;
      des_array[i][1]=i;
      //Alert("des_array ["+des_array[i][0]+"]["+des_array[i][1]+"]");
   }
}
static void MyMath::PrintArray(string msg, double &array[][1])
{
   int size_array = ArraySize(array);
   Alert("PrintArray=>size_array: "+size_array);
   for(int i =0; i<ArraySize(array);i++)
   {
      Alert(msg+":::"+"["+i+"] "+array[i][0]);
      //Alert(msg+":::"+"["+i+"] "+array[i][1]);
   }
}
static void MyMath::ConstellateArraySort(GannValue* &src_array[], int count,int start_idx, int sort_dir )
{
   double doubleArray[][2];
   int size_src1 = ArraySize(src_array);
   //Alert("size_src1: "+size_src1);
   //PrintArray("BeforeConsArrayToDoubleArray", src_array);
   ConsArrayToDoubleArray(doubleArray, src_array);
   //PrintArray("AfterConsArrayToDoubleArray", doubleArray);
   
   // 做到這裡20161009
   ArraySort(doubleArray, count, start_idx, sort_dir);
   //PrintArray("AfterSortDoubleArray", doubleArray);
   
   int size_src = ArraySize(src_array);
   //Alert("size_src", size_src);
   GannValue* temp[];
   for(int i = 0; i <size_src;i++){
      int size_temp = ArraySize(temp);
      ArrayResize(temp, ++size_temp);
      //Alert("size_temp"+size_temp);
      int idxFromDoubleArray = doubleArray[i][1];
      //Alert("doubleArray["+i+"][1]="+(doubleArray[i][1]));
     
      temp[size_temp-1]=src_array[idxFromDoubleArray];
      //Alert("temp["+(size_temp-1)+"]="+(temp[size_temp-1].value));
   }
   ArrayFree(src_array);
   ArrayCopy(src_array, temp, 0, 0, WHOLE_ARRAY);
   ArrayFree(temp);
}


static void MyMath::PrintArray(string msg, GannValue* &array[])
{
   string temp[];
   for(int i =0;i<ArraySize(array);i++){
      int size = ArraySize(temp);
      ArrayResize(temp, ++size);
      temp[size-1] = "第"+array[i].part+"段:::"+array[i].value;
      
      Alert(msg+":::"+"["+i+"] "+temp[i]);
   }
}

static void MyMath::ArrangeConstellate(bool run_type, GannValue* &src_array[])
{  //diff = 3
   // 1 2 3  8  9  10 ==> 9跟10比，小於3  留9
   //Alert("===ArrangeConstellate===");
   if(run_type){
      ConstellateArraySort(src_array, WHOLE_ARRAY, 0, MODE_ASCEND);
   }else{
      ConstellateArraySort(src_array, WHOLE_ARRAY, 0, MODE_DESCEND);
   }

   //PrintArray("AfterConstellateArraySort", src_array);
   
   int size_srcarray = ArraySize(src_array);
   //Alert("size_srcarray: "+size_srcarray);
   
   GannValue *returnarray[];
   GannValue* temp[];
   int distance = 10;
   
   
   for(int i=0; i<size_srcarray; i++){
      
      double valueNow = src_array[i].value;
      double valueNext = EMPTY_VALUE;
      if(i<size_srcarray-1)valueNext = src_array[i+1].value;
      //Alert("valueNow = "+valueNow+ " <==> valueNext = "+valueNext);
      if(MathAbs(valueNow-valueNext)<distance){
         int size_temp1 = ArraySize(temp);
         ArrayResize(temp, ++size_temp1, 0);
         temp[size_temp1-1]=src_array[i];
         int size_temp2 = ArraySize(temp);
         ArrayResize(temp, ++size_temp2, 0);
         temp[size_temp2-1]=src_array[i+1]; 
         //Alert("into src_array["+i+"]"+src_array[i].value+" - src_array["+(i+1)+"]"+src_array[i+1].value+" < diff "+distance);        
      }else{
         if(ArraySize(temp)>0){
            //1.先將之前的接近數整理出來
             
            ConstellateArraySort(temp, WHOLE_ARRAY, 0, MODE_ASCEND);
            
            GannValue* cons;
            if(run_type){
               //PrintArray("GetMaxFromArray", temp);
               cons = GetMaximumConstellate(temp);
               //Alert("Max is "+cons.value);
            }else{
               //PrintArray("GetMinFromArray", temp);
               cons = GetMinimumConstellate(temp);
               //Alert("Min is "+cons.value);
            }
            int size_returnarray = ArraySize(returnarray);
            ArrayResize(returnarray, ++size_returnarray, 0);
            returnarray[size_returnarray-1]=cons;
            //Alert("into add value "+value+" to returnarray["+(size_returnarray-1)+"]");
            ArrayFree(temp);
            //如果篩選出值，下一個值需跳過避免重覆比對
            continue;
         }
         
         //2.再將當下的新的非連續數值存入
         int size_returnarray3 = ArraySize(returnarray);
         ArrayResize(returnarray, ++size_returnarray3, 0);
         returnarray[size_returnarray3-1]=src_array[i];
         //Alert("returnarray["+(size_returnarray3-1)+"]"+" is "+src_array[i]);

      }
   }
   ArrayFree(src_array);
   ArrayCopy(src_array, returnarray, 0, 0, WHOLE_ARRAY);

}

 static double MyMath::GetHighestPrice(int count, int start_shift){
   int shift = iHighest(Symbol(), Period(), MODE_HIGH, count, start_shift);
   double price = High[shift];
   Alert("highest price shift is: "+shift+", price is "+price);
   return price;
 }