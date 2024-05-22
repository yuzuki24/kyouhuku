import 'package:flutter/material.dart';

import 'AppBarWidget.dart';
import 'BottomNavBar.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'MyPage'), // タイトルを渡す
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://example.com/user_profile_image.jpg'), // ユーザーのプロフィール画像
            ),
            SizedBox(height: 20),
            Text(
              'John Doe', // ユーザー名
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'john.doe@example.com', // ユーザーのメールアドレスなどの情報
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ログアウトボタンが押されたときの処理
                // ログアウト処理を行い、ログイン画面などに遷移する
              },
              child: Text('ログアウト'),
            ),
            SizedBox(height: 20),
            Text(
              '持っている服',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 列数
                crossAxisSpacing: 10.0, // 列間のスペース
                mainAxisSpacing: 10.0, // 行間のスペース
              ),
              itemCount: 10, // 服の数に合わせて調整
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.withOpacity(0.3),
                  child: Image.network(
                    'https://via.placeholder.com/150', // 画像のURL
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(), // 共通のフッターを追加
    );
  }
}
