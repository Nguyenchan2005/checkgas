import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());
}

/* ===================== APP ROOT ===================== */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simon House Gas Monitor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GasMonitorScreen(),
    );
  }
}

/* ===================== MAIN SCREEN ===================== */

class GasMonitorScreen extends StatefulWidget {
  const GasMonitorScreen({super.key});

  @override
  State<GasMonitorScreen> createState() => _GasMonitorScreenState();
}

class _GasMonitorScreenState extends State<GasMonitorScreen> {
  /* ---------- MQTT CONFIG (TLS 8883) ---------- */
  final String broker = 'broker.emqx.io';
  final int port = 8883;

  final String topicValue = 'simon_house/gas/value';
  final String topicAlert = 'simon_house/gas/alert';

  late MqttServerClient client;

  /* ---------- UI STATE ---------- */
  String gasValue = "---";
  String statusText = "Đang kết nối Server...";
  Color statusColor = const Color(0xFFF39C12);
  IconData statusIcon = Icons.cloud_sync;

  bool isNotificationEnabled = true;
  DateTime lastNotificationTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    requestPermission();
    connectMQTT();
  }

  /* ===================== PERMISSION ===================== */

  Future<void> requestPermission() async {
    await Permission.notification.request();
  }

  /* ===================== NOTIFICATION ===================== */

  Future<void> showAlarmNotification(String message) async {
    if (DateTime.now().difference(lastNotificationTime).inSeconds < 10) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gas_alarm_channel',
      'Cảnh báo Khí Gas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Colors.red,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '⚠️ NGUY HIỂM!',
      'Trạng thái: $message',
      const NotificationDetails(android: androidDetails),
    );

    lastNotificationTime = DateTime.now();
  }

  /* ===================== MQTT CONNECT ===================== */

  Future<void> connectMQTT() async {
    final String clientId =
        'flutter_tls_${Random().nextInt(100000)}';

    client = MqttServerClient(broker, clientId);
    client.port = port;

    // 🔐 TLS CONFIG (BẮT BUỘC CHO 8883)
    client.useWebSocket = false;
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;

    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.onDisconnected = _onDisconnected;
    client.setProtocolV311();

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      print('🔵 Đang kết nối MQTT TLS đến $broker:$port ...');
      await client.connect();
    } catch (e) {
      print('🔴 Lỗi kết nối MQTT: $e');
      return;
    }

    if (client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      print('✅ KẾT NỐI THÀNH CÔNG (MQTT TLS 8883)');

      setState(() {
        statusText = "Đã kết nối! Đang đợi dữ liệu...";
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.cloud_done;
      });

      client.subscribe(topicValue, MqttQos.atMostOnce);
      client.subscribe(topicAlert, MqttQos.atMostOnce);

      client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final message = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message);
        processMessage(c[0].topic, message);
      });
    } else {
      print('❌ Kết nối thất bại');
      client.disconnect();
    }
  }

  /* ===================== MQTT MESSAGE ===================== */

  void processMessage(String topic, String message) {
    if (!mounted) return;

    setState(() {
      if (topic == topicValue) {
        gasValue = message;
      }

      if (topic == topicAlert) {
        statusText = message;

        if (message.contains("CANH BAO") ||
            message.contains("NGUY HIEM") ||
            message.contains("RO RI")) {
          statusColor = const Color(0xFFE74C3C);
          statusIcon = Icons.warning_amber_rounded;
          if (isNotificationEnabled) {
            showAlarmNotification(message);
          }
        } else if (message.contains("An toan")) {
          statusColor = const Color(0xFF2ECC71);
          statusIcon = Icons.security;
        } else {
          statusColor = const Color(0xFFF39C12);
          statusIcon = Icons.info_outline;
        }
      }
    });
  }

  /* ===================== DISCONNECT ===================== */

  void _onDisconnected() {
    print('⚠️ Mất kết nối – AutoReconnect đang hoạt động');
    if (mounted) {
      setState(() {
        statusText = "Mất kết nối... Đang tự kết nối lại";
        statusColor = const Color(0xFFF39C12);
        statusIcon = Icons.cloud_off;
      });
    }
  }

  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F9),
      appBar: AppBar(
        title: const Text(
          "Simon House IOT",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Switch(
            value: isNotificationEnabled,
            activeColor: Colors.red,
            onChanged: (v) => setState(() => isNotificationEnabled = v),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 350,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "🔥 GIÁM SÁT KHÍ GAS",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Icon(statusIcon, size: 80, color: statusColor),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          gasValue,
                          style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                        const Text(
                          "ppm",
                          style:
                              TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Mode: MQTT TLS 8883 (FINAL – ANDROID)",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}