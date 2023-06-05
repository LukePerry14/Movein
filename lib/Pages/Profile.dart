import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Login.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 10.0,
          leading: IconButton(onPressed: () {}, icon: const Icon(LineAwesomeIcons.angle_left)),
          title: const Text("Profile"),
          backgroundColor: Colors.orange[300],

        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {print("testing");},
                      child: SizedBox(
                        width: 100, height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(image: AssetImage("assets/Pictures/bud-dha.png")),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 30.0,
                        width: 30.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(LineAwesomeIcons.pen_nib, color: Colors.grey),

                      ),
                      ),
                  ],
                ),



                const SizedBox(height: 20.0),

                const Text("Buddha"),

                const SizedBox(height: 30.0),

                const Divider(),

                const SizedBox(height: 60.0),

                ListTile(
                  onTap: () {Navigator.pushNamed(context, '/Settings');},
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey[200]?.withOpacity(0.1),
                    ),
                    child: const Icon(LineAwesomeIcons.cog, color: Colors.black38,),
                  ),
                  title: const Text("Settings"),
                ),

                ListTile(
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey[200]?.withOpacity(0.1),
                    ),
                    child: const Icon(LineAwesomeIcons.user, color: Colors.black38,),
                  ),
                  title: const Text("Profile information"),
                ),

                ListTile(
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey[200]?.withOpacity(0.1),
                    ),
                    child: const Icon(LineAwesomeIcons.alternate_sign_out, color: Colors.black38,),
                  ),
                  title: const Text("Logout", style: TextStyle(
                    color: Colors.red,

                  ),),
                ),



              ],
            ),
          ),

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
        '/Login': (context) => Login(),
      },
    );
  }
}
