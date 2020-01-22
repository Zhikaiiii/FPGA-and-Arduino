#include <BlockDriver.h>
#include <FreeStack.h>
#include <MinimumSerial.h>
#include <SdFat.h>
#include <SdFatConfig.h>
#include <sdios.h>
#include <SysCall.h>
 
byte b[500];//缓冲区
bool CurrentState[3]={0,0,0};//状态
bool PreState[3]={1,1,1};
const bool standard[7][3] = {{0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0}, {0, 0, 1}, {1, 0, 1}, {1, 1, 1}};
File myFile;
SdFat sd;
int count=0;
int count2=0;
int count3=500;
int count4=0;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(230400);
  
  if (!sd.begin(4)) {
      Serial.println("initialization failed!");
      return;
    }
    Serial.println("initialization done.");//初始化结束
  //myFile = SD.open("RECORD.TXT",FILE_WRITE);//打开指定文件
  pinMode(5,INPUT);//state[0]
  pinMode(6,INPUT);//state[1]
  pinMode(7,INPUT);//state[2]
  pinMode(3,INPUT_PULLUP);//上升沿采样
  pinMode(31,OUTPUT);
  pinMode(33,OUTPUT);
  pinMode(35,OUTPUT);
  pinMode(37,OUTPUT);
  pinMode(39,OUTPUT);
  pinMode(41,OUTPUT);
  pinMode(43,OUTPUT);
  pinMode(45,OUTPUT);
  myFile = sd.open("RECORD.TXT", O_CREAT | O_WRITE);
  sd.remove("RECORD.TXT");
  Serial.println("initialization done.");//初始化结束
  attachInterrupt(digitalPinToInterrupt(3),Collect, RISING);//设置外部中断
}
 


void loop() {
  PreState[0]=CurrentState[0];
  PreState[1]=CurrentState[1];
  PreState[2]=CurrentState[2];
  delay(10);
  CurrentState[2]=digitalRead(7);
  CurrentState[1]=digitalRead(6);
  CurrentState[0]=digitalRead(5);
  Note();
  // put your main code here, to run repeatedly:
}

void Note()//显示提示信息
{
   if (compare(CurrentState, standard[0])&& compare(PreState, standard[3])
   ||(compare(CurrentState, standard[0])&& compare(PreState, standard[6])))
  {
    Serial.println("System initialization. Waiting for instructions...");
    sd.remove("RECORD.TXT");
    count=0;
    count2=0;
    count3=500;
    count4=0;
  }
  else if (compare(CurrentState, standard[1])&& compare(PreState, standard[0]))
  {
    Serial.println("Recording...");
  }
  else if (compare(CurrentState, standard[2])&& compare(PreState, standard[1]))
  {
    Serial.println("Record pause...");
  }
  else if ((compare(CurrentState, standard[3])&& compare(PreState, standard[1]))||
  (compare(CurrentState, standard[3])&& compare(PreState, standard[4])))
  {
    Serial.println("Record finish. Waiting for instructions...");
  }
  else if (compare(CurrentState, standard[4])&&compare(PreState, standard[3]))
  {
    count4=count-1;
    Serial.println("Playing record...");
  }
  else if (compare(CurrentState, standard[5])&&compare(PreState, standard[4]))
  {
    Serial.println("Play pause...");
  }
  else if (compare(CurrentState, standard[6]))
  {
    Serial.println("State error...");
  }
  else
  {
    return;
  }  
}
//比较两个数组是否相等
bool compare(bool a[3], bool b[3])
{
  for (int i = 0; i < 3; i++)
  {
    if (a[i] != b[i])
      return false;
  }
  return true;
}

void Collect()//中断函数  
{
  if(compare(CurrentState, standard[1]))
  {
    if(count2==500)
    {
      myFile = sd.open("RECORD.TXT",O_CREAT|O_APPEND|O_WRITE);//打开指定文件
      if(myFile)
      {
        myFile.write(b,500);
        Serial.println(count);
        count=count+1;
      }
      myFile.close();  
      count2=0;
    }
    else
    {
      b[count2]=Read();
      count2=count2+1;      
    }        
  }
  else if(compare(CurrentState, standard[4]))
  {
    if(!myFile&&count4==count-1)
    {
      myFile = sd.open("RECORD.TXT",O_READ);//打开指定文件
    }  
    if(myFile.available()|| count3!=500)
    {
        if(count3==500)
        {
          myFile.read(b,500);
          count3=0;
          Serial.println(count4);
          count4=count4-1;
        }
        else
        {
          DAC(b[count3]);
          if(count4==1 ||count4==10 ||count4==20)
          {
            Serial.println(b[count3]);
          }
          count3=count3+1;
        }
    }
    else
    {
      myFile.close();
    }
  }
}
//读取A/D数据

byte Read(void)
{
    byte temp;
    /*
    tmp = 0;
    tmp |= (digitalRead(A0)  << 0);
    tmp |= (digitalRead(A1)  << 1);
    tmp |= (digitalRead(A2)  << 2);
    tmp |= (digitalRead(A3)  << 3);
    tmp |= (digitalRead(A4)  << 4);
    tmp |= (digitalRead(A5)  << 5);
    tmp |= (digitalRead(9)  << 6);
    tmp |= (digitalRead(10) << 7);
    */
    //int val=analogRead(A0);
    //temp=val>>2;
    /*
    bitWrite(temp, 0, digitalRead(A0));
    bitWrite(temp, 1, digitalRead(A1));
    bitWrite(temp, 2, digitalRead(A2));
    bitWrite(temp, 3, digitalRead(A3));
    bitWrite(temp, 4, digitalRead(A4));
    bitWrite(temp, 5, digitalRead(A5));
    bitWrite(temp, 6, digitalRead(9));
    bitWrite(temp, 7, digitalRead(8));
    */

    
    temp=Filter();
    return temp;
}

void DAC(byte b)
{
  digitalWrite(31,bitRead(b,0));
  digitalWrite(33,bitRead(b,1));
  digitalWrite(35,bitRead(b,2));
  digitalWrite(37,bitRead(b,3));
  digitalWrite(39,bitRead(b,4));
  digitalWrite(41,bitRead(b,5));
  digitalWrite(43,bitRead(b,6));
  digitalWrite(45,bitRead(b,7));
}


#define FILTER_N 10
int filter_buf[FILTER_N + 1];
int Filter() {
  int i;
  int filter_sum = 0;
  filter_buf[FILTER_N] = analogRead(A0);
  for(i = 0; i < FILTER_N; i++) {
    filter_buf[i] = filter_buf[i + 1]; // 所有数据左移，低位仍掉
    filter_sum += filter_buf[i];
  }
  int average=(filter_sum/ FILTER_N)>>2;
  return (byte)average;
}
/*
byte Filter() {
  int i, j;
  int filter_temp, filter_sum = 0;
  //int anatemp;
  //int filter_buf[FILTER_N];
  for(i = 0; i < FILTER_N; i++) {
    //anatemp=analogRead(A0);
    filter_sum += analogRead(A0);
    //delayMicroseconds(1);
  }
  // 采样值从小到大排列（冒泡法）
  /*
  for(j = 0; j < FILTER_N - 1; j++) {
    for(i = 0; i < FILTER_N - 1 - j; i++) {
      if(filter_buf[i] > filter_buf[i + 1]) {
        filter_temp = filter_buf[i];
        filter_buf[i] = filter_buf[i + 1];
        filter_buf[i + 1] = filter_temp;
      }
    }
  }
  */
 /*
  // 去除最大最小极值后求平均
  //for(i = 1; i < FILTER_N - 1; i++) filter_sum += filter_buf[i];
  int average= filter_sum / (FILTER_N );
  average=average>>2;
  return byte(average);
}
*/
