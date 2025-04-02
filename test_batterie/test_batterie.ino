const float referenceVoltage = 3.3;  // Tension de référence interne
const float dividerRatio = 2.0;      // Résistance diviseur 1MΩ / 1MΩ
const float minVoltage = 3.3;        // Tension min de la batterie (0%)
const float maxVoltage = 4.2;        // Tension max de la batterie (100%)

void setup() {
  Serial.begin(115200);
  while (!Serial);

  analogReadResolution(12);  // Résolution ADC à 12 bits
}

void loop() {
  int rawValue = analogRead(A0);  
  float voltage = (rawValue * referenceVoltage) / 4095.0 * dividerRatio;

  // Calcul du pourcentage (approximation linéaire)
  int batteryPercentage = (voltage - minVoltage) / (maxVoltage - minVoltage) * 100;
  
  // Limiter entre 0% et 100%
  batteryPercentage = constrain(batteryPercentage, 0, 100);

  Serial.print("Tension Batterie : ");
  Serial.print(voltage);
  Serial.print(" V | Niveau : ");
  Serial.print(batteryPercentage);
  Serial.println("%");

  delay(15000);
}
