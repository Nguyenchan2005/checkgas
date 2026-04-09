import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/gas_model.dart';
import '../services/mqtt_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class GasMonitorScreen extends StatefulWidget {
  const GasMonitorScreen({super.key});

  @override
  State<GasMonitorScreen> createState() => _GasMonitorScreenState();
}

class _GasMonitorScreenState extends State<GasMonitorScreen> {
  late MqttService _mqttService;
  GasData _gasData = GasData.initial();
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    Permission.notification.request();
    _mqttService = MqttService(
      onMessage: _processMessage,
      onStatusChange: _onStatusChange,
    );
    _mqttService.connect();
  }

  void _onStatusChange(bool connected) {
    if (!mounted) return;
    setState(() {
      if (connected) {
        _gasData = GasData(
          value: _gasData.value,
          status: GasStatus.safe,
          statusText: 'Đã kết nối! Đang đợi dữ liệu...',
          statusColor: const Color(0xFF2ECC71),
          statusIcon: Icons.cloud_done,
        );
      } else {
        _gasData = GasData(
          value: _gasData.value,
          status: GasStatus.connecting,
          statusText: 'Mất kết nối... Đang tự kết nối lại',
          statusColor: const Color(0xFFF39C12),
          statusIcon: Icons.cloud_off,
        );
      }
    });
  }

  void _processMessage(String topic, String message) {
    if (!mounted) return;
    setState(() {
      String newValue = _gasData.value;
      GasStatus newStatus = _gasData.status;
      String newText = _gasData.statusText;
      Color newColor = _gasData.statusColor;
      IconData newIcon = _gasData.statusIcon;

      if (topic == MqttConstants.topicValue) {
        newValue = message;
      }

      if (topic == MqttConstants.topicAlert) {
        newText = message;
        final isDanger = AlertKeywords.danger.any((k) => message.contains(k));

        if (isDanger) {
          newStatus = GasStatus.danger;
          newColor = const Color(0xFFE74C3C);
          newIcon = Icons.warning_amber_rounded;
          if (_isNotificationEnabled) {
            NotificationService.showAlarmNotification(message);
          }
        } else if (message.contains(AlertKeywords.safe)) {
          newStatus = GasStatus.safe;
          newColor = const Color(0xFF2ECC71);
          newIcon = Icons.security;
        } else {
          newStatus = GasStatus.warning;
          newColor = const Color(0xFFF39C12);
          newIcon = Icons.info_outline;
        }
      }

      _gasData = GasData(
        value: newValue,
        status: newStatus,
        statusText: newText,
        statusColor: newColor,
        statusIcon: newIcon,
      );
    });
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F9),
      appBar: AppBar(
        title: const Text(
          'Simon House IOT',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Switch(
            value: _isNotificationEnabled,
            activeColor: Colors.red,
            onChanged: (v) => setState(() => _isNotificationEnabled = v),
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
                      '🔥 GIÁM SÁT KHÍ GAS',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Icon(_gasData.statusIcon,
                        size: 80, color: _gasData.statusColor),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _gasData.value,
                          style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: _gasData.statusColor),
                        ),
                        const Text(
                          'ppm',
                          style: TextStyle(
                              fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _gasData.statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _gasData.statusText,
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
                'Mode: MQTT TLS 8883 (ANDROID)',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
