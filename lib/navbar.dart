import 'package:flutter/material.dart';

class custom_navbar extends StatelessWidget {
  const custom_navbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.orange[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Scroller');
            },
            icon: Icon(Icons.view_headline),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Groups');
            },
            icon: Icon(Icons.group),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Profile');
            },
            icon: Icon(Icons.person),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Houses');
            },
            icon: Icon(Icons.home),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
