import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const MyApp());
}