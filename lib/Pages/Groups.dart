import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/SettingsPage.dart';
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
  final List<Group> applications;
  final List<Group> shortList;

  const Groups({
    Key? key,
    this.applications = const [
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
  final int appsNum = 0;
  final int appsMax = 3;

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).canvasColor,
          centerTitle: true,
          elevation: 0,
          title: Text('Groups', style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Applied: ${applications.length}/$appsMax", style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),



            const SizedBox(width: 20.0),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: applications.length + shortList.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0){
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Applications',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      );
                    }else if(index == applications.length+1){
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Shortlist',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      );
                    }else if(index < applications.length+1){
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                                  'members': applications[index-1].members,
                                  'groupName': applications[index-1].name(),
                                });
                              },
                              title: Text(applications[index-1].name(), style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                        ),
                      );
                    } else{
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                                  'members': shortList[index - applications.length - 2].members,
                                  'groupName': shortList[index - applications.length - 2].name(),
                                });
                              },
                              title: Text(shortList[index - applications.length - 2].name(), style: Theme.of(context).textTheme.bodyMedium),
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
