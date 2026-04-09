import 'dart:io';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../utils/constants.dart';

typedef MessageCallback = void Function(String topic, String message);
typedef StatusCallback = void Function(bool connected);

class MqttService {
  late MqttServerClient _client;
  final MessageCallback onMessage;
  final StatusCallback onStatusChange;

  MqttService({required this.onMessage, required this.onStatusChange});

  Future<void> connect() async {
    final String clientId = 'flutter_tls_${Random().nextInt(100000)}';

    _client = MqttServerClient(MqttConstants.broker, clientId);
    _client.port = MqttConstants.port;
    _client.useWebSocket = false;
    _client.secure = true;
    _client.securityContext = SecurityContext.defaultContext;
    _client.keepAlivePeriod = 60;
    _client.autoReconnect = true;
    _client.onDisconnected = _onDisconnected;
    _client.setProtocolV311();

    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await _client.connect();
    } catch (e) {
      print('🔴 Lỗi kết nối MQTT: $e');
      return;
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      onStatusChange(true);
      _client.subscribe(MqttConstants.topicValue, MqttQos.atMostOnce);
      _client.subscribe(MqttConstants.topicAlert, MqttQos.atMostOnce);
      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        onMessage(c[0].topic, message);
      });
    } else {
      _client.disconnect();
    }
  }

  void _onDisconnected() {
    print('⚠️ Mất kết nối – AutoReconnect đang hoạt động');
    onStatusChange(false);
  }

  void disconnect() {
    _client.disconnect();
  }
}
