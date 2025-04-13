#include <MKRWAN.h>
LoRaModem modem;
#include "arduino_secrets.h"
String appEui = SECRET_APP_EUI;
String appKey = SECRET_APP_KEY;

#include <DS18B20.h>                  // pour capteur temperature
DS18B20 ds(2);                        // pour capteur temperature

const float referenceVoltage = 3.3;   // pour la batterie
const float dividerRatio = 2.0;       // pour la batterie
const float minVoltage = 3.3;         // pour la batterie
const float maxVoltage = 4.2;         // pour la batterie

void setup() {

  Serial.begin(115200);
  while (!Serial);

  if (!modem.begin(EU868)) {
    Serial.println("Failed to start module");
    while (1) {}
  };
  Serial.print("Your module version is: ");
  Serial.println(modem.version());
  Serial.print("Your device EUI is: ");
  Serial.println(modem.deviceEUI());

  int connected = modem.joinOTAA(appEui, appKey);
  if (!connected) {
    Serial.println("Something went wrong; are you indoor? Move near a window and retry");
    while (1) {}
  }

  modem.minPollInterval(60);

  analogReadResolution(12);   // pour la batterie
}

void loop() {
   int rawValue = analogRead(A0);                                                   // branche utiliser (A0)
  float voltage = (rawValue * referenceVoltage) / 4095.0 * dividerRatio;            // pont diviseur
  int batteryPercentage = (voltage - minVoltage) / (maxVoltage - minVoltage) * 100; // pourcentage batterie
  batteryPercentage = constrain(batteryPercentage, 0, 100);                         // limiter en 0 et 100%
  Serial.println();

  //int T = random(15, 35);
  //int H = random(20, 95);
  //int M = random(0, 21);
  //float P = random(900, 1200);
  String msg = " ";
  msg += "{\"T\": 2"; //DS18B20
  //msg += ds.getTempC();
  //msg += T;
  msg += ";\"H\": 35"; //DHT22
  //msg += H;
  msg += ";\"M\": 75"; //HX711
  //msg += M;
  msg += ";\"P\": 1000"; //BME280
  //msg += P;
  msg += ";\"Bat\": 90";
  //msg += batteryPercentage;
  msg += ";}";

  Serial.print(msg);
  Serial.println();
  Serial.print("Sending: " + msg + " - ");
  for (unsigned int i = 0; i < msg.length(); i++) {
    Serial.print(msg[i] >> 4, HEX);
    Serial.print(msg[i] & 0xF, HEX);
    Serial.print(" ");
  }
  Serial.println();

  int err;
  modem.beginPacket();
  modem.print(msg);
  err = modem.endPacket(true);
  if (err > 0) {
    Serial.println("Message sent correctly!");
  } else {
    Serial.println("Error sending message :(");
    Serial.println("(you may send a limited amount of messages per minute, depending on the signal strength");
    Serial.println("it may vary from 1 message every couple of seconds to 1 message every minute)");
  }
  delay(1800000);
  if (!modem.available()) {
    Serial.println("No downlink message received at this time.");
    return;
  }
  char rcv[64];
  int i = 0;
  while (modem.available()) {
    rcv[i++] = (char)modem.read();
  }
  Serial.print("Received: ");
  for (unsigned int j = 0; j < i; j++) {
    Serial.print(rcv[j] >> 4, HEX);
    Serial.print(rcv[j] & 0xF, HEX);
    Serial.print(" ");
  }
  Serial.println();
}
