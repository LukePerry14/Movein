import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Profile.dart';

class Group {
  final Map<int, String> members;
  final String groupName;

  const Group({required this.members, required this.groupName});

  List<String> username(){
    return members.values.toList();
  }

  String name(){
    if (groupName == "") {
      String nam = "";
      for (var n in members.values) {
        nam = '$nam$n, ';
      }
      return nam.substring(0,nam.length-2);
    }
    else{
      return groupName;
    }
  }
}

class Groups extends StatelessWidget {
  final List<Group> userGroups;

  const Groups({
    Key? key,
    this.userGroups = const [
      Group(members:{1423: "Meghan", 5678: "Jack", 8471: "Tiffany"}, groupName: ""),
      Group(members: {5341: "Petes", 5478: "Pomps", 8472: "Brian"}, groupName: "gcgc"),
      Group(members: {9801: "Dum", 7854: "Dee", 9071: "Me"}, groupName: "Helen Keller"),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: userGroups.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.zero,
              child: Card(
                elevation: 0, // Optional: Set elevation to 0 to remove the shadow
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                color: Colors.transparent, // Set the background color of the Card to transparent
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[500]!,
                      ),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {},
                    title: Text(userGroups[index].name()),
                  ),
                ),
              ),
            );

          },
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
      },
    );
  }
}
