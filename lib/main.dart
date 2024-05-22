import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/AppBarWidget.dart';
import 'pages/BottomNavBar.dart';
import 'pages/FavoritesPage.dart';
import 'pages/SettingsPage.dart';
import 'pages/ManualCoordinationPage.dart';
import 'pages/Mypage.dart';
import 'pages/UserRegistrationPage.dart';
import 'pages/ClothesSearchPage.dart';
import 'pages/AddItemPage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 追加
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothing Management App',
      theme: ThemeData(
          // Theme settings...
          ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/manual_coordination': (context) => const ManualCoordinationPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/clothes_search': (context) => const ClothesSearchPage(),
        '/settings': (context) => const SettingsPage(),
        '/mypage': (context) => const MyPage(),
        '/user_registration': (context) => const UserRegistrationPage(),
        '/add_item': (context) => const AddItemPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'), // Japanese
        Locale('en', 'US'), // English
        // Add more locales as needed
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'きょうふく'), // タイトルを渡す
      body: Center(
        child: Column(),
      ),
      bottomNavigationBar: BottomNavBar(), // 共通のフッターを追加
    );
  }
}
