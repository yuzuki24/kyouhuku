import 'package:flutter/material.dart';

import 'AppBarWidget.dart';
import 'BottomNavBar.dart';

class UserRegistrationPage extends StatelessWidget {
  const UserRegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: '利用者登録'), // タイトルを渡す
      body: Center(
          // Widgets for user registration page...
          ),
      bottomNavigationBar: BottomNavBar(), // 共通のフッターを追加
    );
  }
}
