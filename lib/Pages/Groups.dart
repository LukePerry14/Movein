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
  final List<Group> shortList;

  const Groups({
    Key? key,
    this.userGroups = const [
      Group(members:{1423: "Meghan", 5678: "Jack", 8471: "Tiffany"}, groupName: ""),
      Group(members: {5341: "Petes", 5478: "Pomps", 8472: "Brian"}, groupName: "gcgc"),
      Group(members: {9801: "Dum", 7854: "Dee", 9071: "Me"}, groupName: "Helen Keller"),
    ],
    this.shortList = const [
      Group(members:{1423: "Meghan", 5678: "Jack", 8471: "Tiffany"}, groupName: ""),
      Group(members: {5341: "Petes", 5478: "Pomps", 8472: "Brian"}, groupName: "gcgc"),
      Group(members: {9801: "Dum", 7854: "Dee", 9071: "Me"}, groupName: "Helen Keller"),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFfafafa),
          centerTitle: true,
          elevation: 0,
          title: Text('Groups', style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: userGroups.length + shortList.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0){
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Enrolled Groups',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    }else if(index == userGroups.length+1){
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Shortlist',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    }else if(index < userGroups.length+1){
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.pushNamed(context, '/Messages', arguments: {
                                  'members': userGroups[index-1].members,
                                  'groupName': userGroups[index-1].name(),
                                });
                              },
                              title: Text(userGroups[index-1].name()),
                            ),
                          ),
                        ),
                      );
                    } else{
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.pushNamed(context, '/Messages', arguments: {
                                  'members': shortList[index - userGroups.length - 2].members,
                                  'groupName': shortList[index - userGroups.length - 2].name(),
                                });
                              },
                              title: Text(shortList[index - userGroups.length - 2].name()),
                            ),
                          ),
                        ),
                      );
                    }

                  },
                ),
              ),
      ]
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
