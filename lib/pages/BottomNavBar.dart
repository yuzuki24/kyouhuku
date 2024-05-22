import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            onPressed: () {
              // Add home button functionality
              Navigator.pushNamed(context, '/manual_coordination');
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              // Add registration button functionality
              Navigator.pushNamed(context, '/add_item');
            },
            icon: Icon(Icons.add_circle),
          ),
          IconButton(
            onPressed: () {
              // Add my page button functionality
              Navigator.pushNamed(context, '/mypage');
            },
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }
}
