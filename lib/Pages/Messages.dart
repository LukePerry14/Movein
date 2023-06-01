import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Profile.dart';

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
          backgroundColor: Colors.orange[300],
          title: Text('${data['groupName']}'),
          centerTitle: true,
          elevation: 0,
          leading: BackButton(
            color: Colors.grey[500],
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              color: Colors.grey[500],
              icon: Icon(Icons.more_vert), //Icon not showing
              onPressed: () {
                // Handle settings button press
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Text('example Messages'),
        ),
        bottomNavigationBar: custom_navbar(),
      ),
      routes: {
        '/Scroller': (context) => Scroller(),
        '/Messages': (context) => Messages(),
        '/Groups': (context) => Groups(),
        '/Profile': (context) => Profile(),
        '/Settings': (context) => Settings(),
        '/Houses': (context) => Houses(),
      },
    );
  }
}
