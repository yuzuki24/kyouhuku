import 'package:flutter/material.dart';

import 'AppBarWidget.dart';
import 'BottomNavBar.dart';

class ClothesSearchPage extends StatelessWidget {
  const ClothesSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: '検索'), // タイトルを渡す
      body: Center(
          // Widgets for clothes search page...
          ),
      bottomNavigationBar: BottomNavBar(), // 共通のフッターを追加
    );
  }
}
