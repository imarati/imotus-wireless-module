#include <ESP8266WiFi.h>

const char* ssid     = "ESP8266_AP";
const char* password = "12345678";

WiFiServer server(4210);
WiFiClient client;

void setup() {
  Serial.begin(115200);
  WiFi.softAP(ssid, password);
  server.begin();
}

void loop() {

  if (!client || !client.connected()) {
    if (client && !client.connected()) {
      client.stop();
    }

    WiFiClient newClient = server.available();
    if (newClient) {
      client = newClient;
    }
  }

  if (client && client.connected()) {

    while (client.available()) {
      int b = client.read();
      if (b >= 0) {
        Serial.write((uint8_t)b);
      }
    }

    while (Serial.available()) {
      int b = Serial.read();
      if (b >= 0) {
        client.write((uint8_t)b);
      }
    }
  }
}