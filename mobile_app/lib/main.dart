import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/services/tcp_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: ConnectScreen(tcp: tcp),
    );
  }
}


