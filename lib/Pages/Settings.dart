import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar( //maybe replace with a sliverappbar to improve polish
          backgroundColor: const Color(0xFFfafafa),
          title: Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LineAwesomeIcons.angle_left, color: Colors.black),
            color: Colors.grey[500],
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              color: Colors.grey[500],
              icon: const Icon(Icons.more_vert), //Icon not showing
              onPressed: () {
                // Handle settings button press
              },
            ),
          ],
        ),
        body: const SafeArea(
          child: Text('example Settings'),
        ),

      ),

    );
  }
}
