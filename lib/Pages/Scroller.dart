import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/HScroll.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/SettingsPage.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Scroller extends StatelessWidget {
  const Scroller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final navigator = Navigator.of(context);

        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 20.0,
                      alignment: Alignment.bottomCenter,
                      child: null,
                    ),
                    const Gscroller(),
                  ],
                ),
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor?.withOpacity(0.5),
                    onPressed: () {},
                    child: const Icon(LineAwesomeIcons.angle_right, color: Colors.white),
                  ),
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor?.withOpacity(0.5),
                    onPressed: () {},
                    child: const Icon(LineAwesomeIcons.times, color: Colors.white),
                  ),
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor?.withOpacity(0.5),
                    onPressed: () {},
                    child: const Icon(LineAwesomeIcons.check, color: Colors.white),
                  ),
                ],
              ),
              bottomNavigationBar: CustomNavbar(
                onItemSelected: (route) {
                  navigator.pushNamed(route);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
