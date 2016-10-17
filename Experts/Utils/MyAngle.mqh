//+------------------------------------------------------------------+
//|                                                      MyTimer.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ANGLE{
   ANGLE_0  = 0,
   ANGLE_45 = 45,
   ANGLE_90 = 90,
   ANGLE_135 = 135,
   ANGLE_180 = 180,
   ANGLE_225 = 225,
   ANGLE_270 = 270,
   ANGLE_315 = 315
};

class MyAngle
  {
                             
private:
                  
       
public:
                     MyAngle();
                    ~MyAngle();
             
                    static int GetAngleDegree(int &positionCompare[], int &positionBase[]);
                    static bool IsAngleNum(int &positionCompare[], int &positionBase[]);
                    static bool IsCrossNum(int  &positionCompare[], int &positionBase[]);
   
 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyAngle::MyAngle()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyAngle::~MyAngle()
  {
  }

int MyAngle::GetAngleDegree(int &positionCompare[],int &positionBase[]){
     int AngleDegree = -1;
   
     int BasePositionX = positionBase[0];
     int BasePositionY = positionBase[1];
      
     int ComparePositionX = positionCompare[0];
     int ComparePositionY = positionCompare[1];
     
     if(IsAngleNum(positionCompare, positionBase)){
         if(ComparePositionX < BasePositionX & ComparePositionY > BasePositionY){//東北
            AngleDegree = ANGLE_135;
         }else if(ComparePositionX > BasePositionX & ComparePositionY < BasePositionY){//西南
            AngleDegree = ANGLE_315;
         }else if(ComparePositionX < BasePositionX & ComparePositionY < BasePositionY){//西北
            AngleDegree = ANGLE_45;
         }else if(ComparePositionX > BasePositionX & ComparePositionY > BasePositionY){//東南
            AngleDegree = ANGLE_225;
         }
     }else if(IsCrossNum(positionCompare, positionBase)){
         if(ComparePositionY > BasePositionY){//東
            AngleDegree = ANGLE_180;
         }else if(ComparePositionY < BasePositionY){//西
            AngleDegree = ANGLE_0;
         }else if(ComparePositionX > BasePositionX){//南
            AngleDegree = ANGLE_270;
         }else if(ComparePositionX < BasePositionX){//北
            AngleDegree = ANGLE_90;
         }
     }
     return AngleDegree;
}
bool MyAngle::IsAngleNum(int &positionCompare[],int &positionBase[]){
     bool IsAngle = false;
     
     int BasePositionX = positionBase[0];
     int BasePositionY = positionBase[1];
     //Debug::PrintPosition(cursor, BasePosition);
      
     int ComparePositionX = positionCompare[0];
     int ComparePositionY = positionCompare[1];
      
     int DiffX = ComparePositionX - BasePositionX;
     int DiffY = ComparePositionY - BasePositionY;
     
     IsAngle = DiffX + DiffY == 0 | DiffX - DiffY ==0;
     return IsAngle;
}
bool MyAngle::IsCrossNum(int &positionCompare[],int &positionBase[]){
     bool IsCross = false;
     
     int BasePositionX = positionBase[0];
     int BasePositionY = positionBase[1];
      
     int ComparePositionX = positionCompare[0];
     int ComparePositionY = positionCompare[1];
     
     IsCross =  BasePositionX == ComparePositionX | BasePositionY == ComparePositionY;
     //Alert("["+BasePositionX+"]["+BasePositionY+"] & ["+ComparePositionX+"]["+ComparePositionY+"] is Cross? "+IsCross);
     return IsCross;
}
//+------------------------------------------------------------------+
