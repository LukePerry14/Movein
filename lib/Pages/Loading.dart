import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Profile.dart';

class loading extends StatefulWidget {
  const loading({Key? key}) : super(key: key);

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {

  void GetData() async {

    Response response = await get('http://jsonplaceholder.typicode.com/todos/1' as Uri);
    
    Map data = jsonDecode(response.body);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Text('example Loading'),
        ),

        bottomNavigationBar: custom_navbar(),
      ),
      routes: {
        '/': (context) => loading(),
        '/Scroller': (context) => scroller(),
        '/Messages': (context) => messages(),
        '/Groups': (context) => groups(),
        '/Profile': (context) => profile(),
        '/Settings': (context) => settings(),
        '/Houses': (context) => houses(),
      },

    );
  }
}
