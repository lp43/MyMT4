//+------------------------------------------------------------------+
//|                                                       MyMath.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyMath
  {
private:

public:
                     MyMath();
                    ~MyMath();
                    static double FindClosest(double &array[], double value);
                    static void ReverseArray(double &src_array[], double & des_array[]);
                    static int FindIdxByValue(double &src_array[], double value);
                    static double GetMinimumValue(double &src_array[]);
                    static void DeleteConsecutiveNums(double &src_array[], double begin_value, double step);
                    static int GetDecimalBits(double target);
                    static bool HasDecimalBits(double target);
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
    for(int i =0;i<ArraySize(src_array);i++){
      //Alert("i: "+i+" is "+src_array[i]);
      if(src_array[i]==value){
         found_idx = i;
         break;
      }
    }
    return found_idx;
}

static double MyMath::GetMinimumValue(double &src_array[])
{
   int minValue = -1;
   int MinIdx = ArrayMinimum(src_array, WHOLE_ARRAY, 0);
   //Alert("MnIdx: "+MinIdx);
   if(MinIdx>=0){
      minValue = src_array[MinIdx];
   }else{
      minValue = EMPTY_VALUE;
   }
   return minValue;
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