class MqttConstants {
  static const String broker = 'broker.emqx.io';
  static const int port = 8883;
  static const String topicValue = 'simon_house/gas/value';
  static const String topicAlert = 'simon_house/gas/alert';
}

class AlertKeywords {
  static const List<String> danger = ['CANH BAO', 'NGUY HIEM', 'RO RI'];
  static const String safe = 'An toan';
}
