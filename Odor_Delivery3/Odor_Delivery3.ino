/*
  Arduino odor delivery system on Yoshi's FLIM scope

  HIGH == valve off
  LOW == Valve on
  The exception is valve 5==pin8 whose valve works in the opposite direction.
  Pin sto valves

*/
int inputS = 0;
int protocol[2];
int time[2];
int length;
int defaultValve = 8; //valve is normall open and must turn off when delivering other odors
int startPIN = 3; //this pin sends ttl to scanimage and NI board recording sensort data
int stopPIN = 2; //this pin sends ttl to scanimage and NI board recording sensort data
int reset = 0;
void setup()
{
  for (int i = 4; i <= 8; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }
  pinMode(startPIN, OUTPUT);
  pinMode(stopPIN, OUTPUT);
  digitalWrite(startPIN, LOW);
  digitalWrite(stopPIN, LOW);
  Serial.begin(9600);
}


int getSerialInt(int inputS, char punct) {
  int value = 0;
  while (inputS != punct) {
    //Serial.println(F("Waiting2 for Serial"));
    if (inputS >= '0' && inputS <= '9') {
      value = (value * 10) + (inputS - '0');
    }
    inputS = Serial.read();
  }

  return value;
}

//found that I could not pass unsigned long int from functions - reason unknown
int getSerialLong(int inputS, char punct) {
  unsigned long value4 = 0;
  while (inputS != punct) {
    //Serial.println(F("Waiting3 for Serial"));
    if (inputS >= '0' && inputS <= '9') {
      value4 = (value4 * 10) + (inputS - '0');
    }
    inputS = Serial.read();
  }
  Serial.println(value4);
  return value4;
}


void loop() {
  if (Serial.available() > 0) {
    inputS = Serial.read();
    if (inputS == '<') {
      inputS = Serial.read();
      int array_length;
      /* get the number of intervals to be tested
        This number ends in number # sign.
      */
      array_length = getSerialInt(inputS, '#');

      //create an array with pin number for each interval in the protocol
      int protocol[array_length];
      for (int i = 0; i < array_length; i++) {
        inputS = Serial.read();
        protocol[i] = getSerialInt(inputS, ',');
      }
      // print pin array back to control to confirm receipt
      for (int i = 0; i < array_length; i++) {
        Serial.println(protocol[i]);
      }

      //create an array holding time ms for each interval in the protocol
      unsigned long int time[array_length]; // for some reason cannot asign values above 32000 (acting like an int data type
      for (int i = 0; i < array_length; i++) {
        inputS = Serial.read();
        unsigned long value4 = 0;
        while (inputS != ',') {
          //Serial.println(F("Waiting3 for Serial"));
          if (inputS >= '0' && inputS <= '9') {
            value4 = (value4 * 10) + (inputS - '0');
          }
          inputS = Serial.read();
        }
        time[i] = value4;
        /*

          long time1 = getSerialLong(inputS, ','); //found that I could not pass long unsigned integers - reason unknown
          Serial.println(F("time1"));
          Serial.println(time1);
          time[i] = time1;
        */
      }
      // print pin array back to control to confirm receipt
      for (int i = 0; i < array_length; i++) {
        Serial.println(time[i]);
      }

      //Starting Protocol - keeping protocol in a loop until > is sent for repeat odor delivery
      reset = Serial.read();
      while (reset != '>') {
        reset = Serial.read();
        //Starting odor protocol - waiting for trigger
        if (reset == '1') {
          digitalWrite(startPIN, HIGH); //trigger for imaging and sensors
          for (int i = 0; i < array_length; i++) {
            if (protocol[i] != 0) {
              digitalWrite(protocol[i], LOW);
              digitalWrite(defaultValve, LOW);
              delay(time[i]);
              digitalWrite(protocol[i], HIGH);
              digitalWrite(defaultValve, HIGH);
            }
            else {
              delay(time[i]);
            }
          }
          digitalWrite(startPIN, LOW); //trigger for imaging and sensors
          digitalWrite(stopPIN, HIGH); //trigger for imaging and sensors
          delay(100);
          digitalWrite(stopPIN, LOW); //trigger for imaging and sensors
          for (int i = 4; i <= 8; i++) {
            digitalWrite(i, HIGH);
          }
        }
      }
    }

  }
  /*
    Detecting input from master pulse and starting protocol

  */





}
