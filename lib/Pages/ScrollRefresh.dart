import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/navbar.dart';

class RanOut extends StatelessWidget {
  const RanOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final navigator = Navigator.of(context);

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                        LineAwesomeIcons.exclamation_circle,
                        color: Theme.of(context).primaryColor,
                        fill: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,

                  child: Text("You've seen to have run out of groups for now, Consider making your own or refresh to try and have another look",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center
                  ),
                ),
                const SizedBox(height: 25),

                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/Scroller');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "Refresh",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomNavbar(
            onItemSelected: (route) {
              navigator.pushReplacementNamed(route);
            },
          ),
        );
      },
    );
  }
}
