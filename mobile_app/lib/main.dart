import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/services/tcp_service.dart';


import 'screens/connect_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final TcpService tcp = TcpService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: ConnectScreen(tcp: tcp),
    );
  }
}


