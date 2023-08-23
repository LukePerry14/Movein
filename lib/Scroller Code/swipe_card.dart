import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/Friend%20And%20Groups%20Code/FriendFunctions.dart';
import 'package:movein/Themes/lMode.dart';
import '../Auth code/auth.dart';
import '../main.dart';

class SwipeCard extends StatelessWidget {
  final String id;
  final String foreName;
  final int age;
  final String uni;
  final Map<String, dynamic> preferences;
  final String bio;
  final String subject;
  final int yearOfStudy;
  final List<String> images;
  final bool showFriend;

  const SwipeCard({
    Key? key,
    required this.id,
    required this.foreName,
    required this.age,
    required this.uni,
    required this.preferences,
    required this.images,
    required this.bio,
    required this.subject,
    required this.yearOfStudy,
    this.showFriend = false,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = width; // Calculate the height based on the width

        return GestureDetector(
          onTap: () {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => CustomDialog(id: id,foreName: foreName,age: age, uni: uni, preferences: preferences,images: images,bio: bio, subject: subject, yearOfStudy: yearOfStudy, showFriend: showFriend)
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 67, 67, 67),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                )
              ],
              image: DecorationImage(
                image: AssetImage(images[0]),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                    child: Row(
                      children: [
                        Text(
                          "$foreName  $age",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                    child: Text(
                      bio,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RoundedBox extends StatelessWidget {
  final String image;
  const RoundedBox({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = width; // Calculate the height based on the width,
        return Container(
          margin: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 67, 67, 67),
                spreadRadius: 0,
                blurRadius: 6,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

// class CustomDialog extends StatelessWidget {
//   final List<dynamic> images;
//   final String id;
//   final String foreName;
//   final int age;
//   final String uni;
//   final Map<String, dynamic> preferences;
//   final String bio;
//   final String subject;
//   final int yearOfStudy;
//   final bool showFriend;
//
//   const CustomDialog({
//     Key? key,
//     required this.id,
//     required this.foreName,
//     required this.age,
//     required this.uni,
//     required this.preferences,
//     required this.images,
//     required this.bio,
//     required this.subject,
//     required this.yearOfStudy,
//     this.showFriend = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime? dateTime;
//     String formattedTime = '';
//
//     if (preferences.containsKey("Lights Out")) {
//       var lightsOutValue = preferences["Lights Out"];
//       if (lightsOutValue is Timestamp) {
//         dateTime = lightsOutValue.toDate();
//         DateFormat timeFormat = DateFormat.jm();
//         formattedTime = timeFormat.format(dateTime);
//       }
//     }
//
//     // ...
//
//     List<Widget> preferenceWidgets = preferences.entries.map((entry) {
//       if (entry.key == "Lights Out") {
//         return Text(
//           " - ${"asleep-by".tr}: $formattedTime",
//           style: Theme.of(context).textTheme.bodyMedium,
//         );
//       } else {
//         switch (entry.key) {
//           case 'Cleanliness':
//             return Text(
//               ' - ${"my-cleanliness-importance".tr}: ${entry.value}/5',
//               style: Theme.of(context).textTheme.bodyMedium,
//             );
//           case 'Noisiness':
//             return Text(
//               ' - ${"my-noisiness-importance".tr}: ${entry.value}/5',
//               style: Theme.of(context).textTheme.bodyMedium,
//             );
//           case 'NightLife':
//             return Text(
//               ' - ${"my-nightlife-importance".tr}: ${entry.value}/5',
//               style: Theme.of(context).textTheme.bodyMedium,
//             );
//           default:
//             return Text(
//               ' - Empty',
//               style: Theme.of(context).textTheme.bodyMedium,
//             );
//         }
//       }
//
//     }).toList();
//
//     return Dialog(
//       insetPadding: EdgeInsets.zero,
//       backgroundColor: Theme.of(context).canvasColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       child: Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).canvasColor,
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           width: MediaQuery.of(context).size.width * 0.90,
//           height: MediaQuery.of(context).size.height * 0.90,
//           padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//           child: Stack(
//             children: [
//               SizedBox(
//                 width: double.maxFinite,
//                 height: MediaQuery.of(context).size.height,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: images.length+5,
//                   itemBuilder: (context, index) {
//                     switch(index){
//                       case 0 :{
//                         return const SizedBox(
//                           height: 25,
//                         );
//                       }
//                       case 1 :{
//                         return Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             //width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
//                               borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.5), // Shadow color
//                                   spreadRadius: 2, // Spread radius
//                                   blurRadius: 5, // Blur radius
//                                   offset: const Offset(0, 2), // Offset of the shadow
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("$foreName ($age)", style: Theme.of(context).textTheme.headlineMedium,),
//                                 Text(id, style: Theme.of(context).textTheme.bodySmall),
//                               ],
//                             ),
//                           ),
//                         );
//                       }
//                       case 2: {
//                         return RoundedBox(image: images[index-2]);
//                       }
//                       case 3: {
//                         return Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             //width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
//                               borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.5), // Shadow color
//                                   spreadRadius: 2, // Spread radius
//                                   blurRadius: 5, // Blur radius
//                                   offset: const Offset(0, 2), // Offset of the shadow
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("${"attends".tr} $uni", style: Theme.of(context).textTheme.headlineSmall),
//                                 const SizedBox(height:3),
//                                 Text("${"studying".tr} $subject", style: Theme.of(context).textTheme.bodyMedium),
//                               ],
//                             ),
//                           ),
//                         );
//                       }
//                       case 4: {
//                         return RoundedBox(image: images[index-3]);
//                       }
//                       case 5: {
//                         return Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             //width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
//                               borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.5), // Shadow color
//                                   spreadRadius: 2, // Spread radius
//                                   blurRadius: 5, // Blur radius
//                                   offset: const Offset(0, 2), // Offset of the shadow
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("${"bio".tr}:", style: Theme.of(context).textTheme.headlineSmall),
//                                 Text(bio, style: Theme.of(context).textTheme.bodyMedium),
//                               ],
//                             ),
//                           ),
//                         );
//                       }
//                       case 6: {
//                         return RoundedBox(image: images[index-4]);
//                       }
//                       case 7: {
//                         return Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             //width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
//                               borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.5), // Shadow color
//                                   spreadRadius: 2, // Spread radius
//                                   blurRadius: 5, // Blur radius
//                                   offset: const Offset(0, 2), // Offset of the shadow
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("${"preferences".tr}:", style: Theme.of(context).textTheme.headlineSmall,),
//                                 const SizedBox(height: 5), // Add a small gap between title and widgets
//                                 ...preferenceWidgets.map((widget) => Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     widget,
//                                     const SizedBox(height: 5), // Add a small gap between preference widgets
//                                   ],
//                                 )),
//                               ],
//                             )
//
//                           ),
//                         );
//                       }
//                       default: {
//                         return RoundedBox(image: images[index-5]);
//                       }
//                     }
//                   },
//                 ),
//               ),
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: IconButton(
//                   splashRadius: 20,
//                   icon: const Icon(LineAwesomeIcons.times_circle),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//               Visibility(
//                 visible: showFriend,
//                 child: Positioned(
//                   top: 0,
//                   left: 0,
//                   child: IconButton(
//                     splashRadius: 20,
//                     icon: const Icon(LineAwesomeIcons.user_plus),
//                     onPressed: () {
//                       sendFriendInvite(id, Auth().currentUser(),);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               backgroundColor: Theme.of(context).primaryColor,
//                               content: Text('invite_sent'.tr, style: Theme.of(context).textTheme.bodySmall)
//                           )
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//     );
//   }
// }
class CustomDialog extends StatefulWidget {
  final List<dynamic> images;
  final String id;
  final String foreName;
  final int age;
  final String uni;
  final Map<String, dynamic> preferences;
  final String bio;
  final String subject;
  final int yearOfStudy;
  final bool showFriend;
  const CustomDialog({
    Key? key,
    required this.id,
    required this.foreName,
    required this.age,
    required this.uni,
    required this.preferences,
    required this.images,
    required this.bio,
    required this.subject,
    required this.yearOfStudy,
    this.showFriend = false,
  }) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool _friended = false;

  @override
  Widget build(BuildContext context) {
    DateTime? dateTime;
    String formattedTime = '';

    if (widget.preferences.containsKey("Lights Out")) {
      var lightsOutValue = widget.preferences["Lights Out"];
      if (lightsOutValue is Timestamp) {
        dateTime = lightsOutValue.toDate();
        DateFormat timeFormat = DateFormat.jm();
        formattedTime = timeFormat.format(dateTime);
      }
    }

    // ...

    List<Widget> preferenceWidgets = widget.preferences.entries.map((entry) {
      if (entry.key == "Lights Out") {
        return Text(
          " - ${"asleep-by".tr}: $formattedTime",
          style: Theme.of(context).textTheme.bodyMedium,
        );
      } else {
        switch (entry.key) {
          case 'Cleanliness':
            return Text(
              ' - ${"my-cleanliness-importance".tr}: ${entry.value}/5',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          case 'Noisiness':
            return Text(
              ' - ${"my-noisiness-importance".tr}: ${entry.value}/5',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          case 'NightLife':
            return Text(
              ' - ${"my-nightlife-importance".tr}: ${entry.value}/5',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          default:
            return Text(
              ' - Empty',
              style: Theme.of(context).textTheme.bodyMedium,
            );
        }
      }

    }).toList();

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.height * 0.90,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.images.length+5,
                itemBuilder: (context, index) {
                  switch(index){
                    case 0 :{
                      return const SizedBox(
                        height: 25,
                      );
                    }
                    case 1 :{
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          //width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Shadow color
                                spreadRadius: 2, // Spread radius
                                blurRadius: 5, // Blur radius
                                offset: const Offset(0, 2), // Offset of the shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${widget.foreName} (${widget.age})", style: Theme.of(context).textTheme.headlineMedium,),
                              Text(widget.id, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      );
                    }
                    case 2: {
                      return RoundedBox(image: widget.images[index-2]);
                    }
                    case 3: {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          //width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Shadow color
                                spreadRadius: 2, // Spread radius
                                blurRadius: 5, // Blur radius
                                offset: const Offset(0, 2), // Offset of the shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${"attends".tr} ${widget.uni}", style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height:3),
                              Text("${"studying".tr} ${widget.subject}", style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    }
                    case 4: {
                      return RoundedBox(image: widget.images[index-3]);
                    }
                    case 5: {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          //width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Shadow color
                                spreadRadius: 2, // Spread radius
                                blurRadius: 5, // Blur radius
                                offset: const Offset(0, 2), // Offset of the shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${"bio".tr}:", style: Theme.of(context).textTheme.headlineSmall),
                              Text(widget.bio, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    }
                    case 6: {
                      return RoundedBox(image: widget.images[index-4]);
                    }
                    case 7: {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            //width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Shadow color
                                  spreadRadius: 2, // Spread radius
                                  blurRadius: 5, // Blur radius
                                  offset: const Offset(0, 2), // Offset of the shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${"preferences".tr}:", style: Theme.of(context).textTheme.headlineSmall,),
                                const SizedBox(height: 5), // Add a small gap between title and widgets
                                ...preferenceWidgets.map((widget) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget,
                                    const SizedBox(height: 5), // Add a small gap between preference widgets
                                  ],
                                )),
                              ],
                            )

                        ),
                      );
                    }
                    default: {
                      return RoundedBox(image: widget.images[index-5]);
                    }
                  }
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(LineAwesomeIcons.times_circle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Visibility(
              visible: widget.showFriend,
              child: Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  splashRadius: 20,
                  icon: _friended?  Icon(LineAwesomeIcons.user_check, color: LAppTheme.lightTheme.primaryColor,) : const Icon(LineAwesomeIcons.user_plus),
                  onPressed: () {
                    if(!_friended){
                      sendFriendInvite(widget.id, Auth().currentUser(),);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Theme.of(context).primaryColor,
                              content: Text('invite_sent'.tr, style: Theme.of(context).textTheme.bodySmall)
                          )
                      );
                    }
                    setState(() {
                      _friended = true;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
