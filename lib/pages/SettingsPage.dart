import 'package:flutter/material.dart';

import 'AppBarWidget.dart';
import 'BottomNavBar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: '設定'), // タイトルを渡す
      body: Center(
          // Widgets for settings page...
          ),
      bottomNavigationBar: BottomNavBar(), // 共通のフッターを追加
    );
  }
}
