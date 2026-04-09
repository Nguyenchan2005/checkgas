import 'package:flutter/material.dart';

enum GasStatus { connecting, safe, warning, danger }

class GasData {
  final String value;
  final GasStatus status;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;

  const GasData({
    required this.value,
    required this.status,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
  });

  static GasData initial() => const GasData(
        value: '---',
        status: GasStatus.connecting,
        statusText: 'Đang kết nối Server...',
        statusColor: Color(0xFFF39C12),
        statusIcon: Icons.cloud_sync,
      );
}
