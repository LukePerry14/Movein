import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movein/navbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,

              elevation: 0.0,
              centerTitle: true,
              title: Text("Profile", style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium),
              backgroundColor: Theme
                  .of(context)
                  .canvasColor,

            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("testing");
                          },
                          child: SizedBox(
                            width: 100, height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const Image(image: AssetImage("assets/Pictures/ph.png")),
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
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(LineAwesomeIcons.pen_nib,
                                color: Colors.grey),

                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 20.0),

                    const Text("Place Holder"),

                    const SizedBox(height: 30.0),

                    const Divider(),

                    const SizedBox(height: 60.0),

                    ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/Settings');
                      },
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey[200]?.withOpacity(0.1),
                        ),
                        child: const Icon(
                          LineAwesomeIcons.cog, color: Colors.black38),
                      ),
                      title: Text("Settings", style: Theme.of(context).textTheme.bodyMedium,),
                    ),

                    ListTile(
                      onTap: () {
                        // open preferences
                      },
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey[200]?.withOpacity(0.1),
                        ),
                        child: const Icon(LineAwesomeIcons.heart, color: Colors.black38,),
                      ),
                      title: Text("Preferences", style: Theme.of(context).textTheme.bodyMedium,),
                    ),

                    ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey[200]?.withOpacity(0.1),
                        ),
                        child: const Icon(
                          LineAwesomeIcons.user, color: Colors.black38,),
                      ),
                      title: Text("Profile information", style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium,),
                    ),

                    ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey[200]?.withOpacity(0.1),
                        ),
                        child: const Icon(LineAwesomeIcons.alternate_sign_out,
                          color: Colors.black38,),
                      ),
                      title: Text("Logout",
                          style: GoogleFonts.roboto(color: Colors.red)),
                    ),


                  ],
                ),
              ),

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
