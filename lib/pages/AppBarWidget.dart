import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            // Add search button functionality
            Navigator.pushNamed(context, '/clothes_search');
          },
          icon: Icon(Icons.search),
        ),
      ],
      backgroundColor: Colors.white70,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
