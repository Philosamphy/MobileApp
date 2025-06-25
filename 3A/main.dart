// main.dart
import 'package:flutter/material.dart';
import 'client_dashboard_screen.dart';

void main() {
  runApp(const DigitalCertificateApp());
}

class DigitalCertificateApp extends StatelessWidget {
  const DigitalCertificateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Certificate Repository',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const ClientDashboardScreen(),
    );
  }}