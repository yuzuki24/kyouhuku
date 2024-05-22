import 'package:flutter/material.dart';

import 'AppBarWidget.dart';
import 'BottomNavBar.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'お気に入り'), // タイトルを渡す
      body: Center(
          // Widgets for favorites page...
          ),
      bottomNavigationBar: BottomNavBar(), // 共通のフッターを追加
    );
  }
}
