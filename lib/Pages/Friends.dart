import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';

class Friends extends StatelessWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            body: const SafeArea(
              child: Text("Placeholder Friends"),
            ),

            bottomNavigationBar: CustomNavbar(
              onItemSelected: (route) {
                navigator.pushNamed(route);
              },
            ),
          );

        }
    );
  }
}
