import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/navbar.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({Key? key}) : super(key: key);

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final navigator = Navigator.of(context);
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar( //maybe replace with a sliverappbar to improve polish
              backgroundColor: const Color(0xFFfafafa),
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
              child: Text('example profile information'),
            ),
            bottomNavigationBar: CustomNavbar(
              onItemSelected: (route) {
                navigator.pushNamed(route);
            },)
          ),
        );
      }
    );
  }
}
