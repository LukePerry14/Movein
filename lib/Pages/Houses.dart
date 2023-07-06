import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';


class Houses extends StatefulWidget {
  const Houses({Key? key}) : super(key: key);

  @override
  State<Houses> createState() => _HousesState();
}

class _HousesState extends State<Houses> {
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);


          return Scaffold(
            body: const SafeArea(
              child: Text('example Houses'),
            ),
          bottomNavigationBar: CustomNavbar(
            onItemSelected: (route) {
              navigator.pushReplacementNamed(route);
            },
          ),
          );
        }
    );
  }
}
