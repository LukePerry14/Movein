import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Map data = {};
  @override
  Widget build(BuildContext context) {

    //retrieves data from previous page to display relevant groupName
    data = ModalRoute.of(context)?.settings.arguments as Map;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar( //maybe replace with a sliverappbar to improve polish
          backgroundColor: const Color(0xFFfafafa),
          title: Text('${data['groupName']}', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LineAwesomeIcons.angle_left, color: Colors.black),
            color: Colors.grey[500],
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              color: Colors.grey[500],
              icon: Icon(Icons.more_vert, color: Colors.black), //Icon not showing
              onPressed: () {
                // Handle settings button press
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Text('example Messages'),
        ),
      ),
    );
  }
}
