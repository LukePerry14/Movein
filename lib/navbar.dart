import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({Key? key, required this.onItemSelected}) : super(key: key);

  final Function(String) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () {
              onItemSelected('/Scroller');
            },
            icon: const Icon(LineAwesomeIcons.bars),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              onItemSelected('/Groups');
            },
            icon: const Icon(Icons.group),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              onItemSelected('/Profile');
            },
            icon: const Icon(Icons.person),
            color: Colors.white,
          ),
          IconButton(
              onPressed: () {
                onItemSelected('/Friends');
              },
              icon: const Icon(Icons.mail),
              color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              onItemSelected('/Houses');
            },
            icon: const Icon(Icons.home),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

