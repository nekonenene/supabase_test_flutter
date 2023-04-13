import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'my_home_page.dart';

final logger = Logger();

void main() async {
  await dotenv.load(fileName: '.env');
  logger.d('START!!!');

  final supabaseUrl = 'https://ivytlevvpjbfagfaqoif.supabase.co';
  final supabaseKey = dotenv.get('SUPABASE_KEY');

  if (supabaseKey == '')
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey!);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
