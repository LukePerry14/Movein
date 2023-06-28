import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  final userId = "iKxLSxcDqlT6vtHe71Bp";
  final appsMax = 3;

  Future<List<List<Map<String, dynamic>>>> fetchGroups() async {
    final List<List<Map<String, dynamic>>> allGroups = [];

    for (String type in ["Joined", "Applications", "ShortList"]) {
      List<Map<String, dynamic>> groups = [];
      List<String> tGroups = [];
      final CollectionReference docGroups =
      FirebaseFirestore.instance.collection("Groups");
      final CollectionReference docUsers =
      FirebaseFirestore.instance.collection("Users");

      try {
        DocumentSnapshot docSnapshot = await docUsers.doc(userId).get();
        Map<String, dynamic>? data =
        docSnapshot.data() as Map<String, dynamic>?;

        tGroups = List<String>.from(data?[type] ?? []);

        for (var group in tGroups) {
          if (group is String && group.isNotEmpty) {
            DocumentSnapshot groupSnapshot = await docGroups.doc(group).get();
            Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;

            groups.add({
              "GroupName": groupData?["GroupName"],
              "GroupId": group,
              "Members": groupData?["Members"]
            });
          }
        }

        allGroups.add(groups);
      } catch (e) {
        throw FirebaseException(
            message: 'Error fetching $type data: $e',
            plugin: 'cloud_firestore');
      }
    }

    return allGroups;
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the data to load, you can show a loading indicator
          return const Center(
            child: FractionallySizedBox(
              heightFactor: 0.3,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Data has been successfully fetched
          List<dynamic> data = snapshot.data!;
          List<Map<String,dynamic>> joined = data[0];
          List<Map<String,dynamic>> applications = data[1];
          List<Map<String,dynamic>> shortList = data[2];

          return Builder(
            builder: (context){
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Applied: ${applications.length}/$appsMax",
                            style: Theme.of(context).textTheme.bodyLarge,
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
                        itemCount: joined.length + applications.length + shortList.length + 3,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Joined',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            );
                          } else if (index <= joined.length) {
                            return Padding(
                              padding: EdgeInsets.zero,
                              child: Card(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
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
                                        'members': joined[index - 1]["Members"],
                                        'groupId': joined[index - 1]["GroupId"],
                                        'groupName': joined[index - 1]["GroupName"],
                                      });
                                    },
                                    title: Text(joined[index - 1]["GroupName"],
                                        style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ),
                              ),
                            );
                          } else if (index == joined.length + 1) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Applications',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            );
                          } else if (index <= joined.length + applications.length + 1) {
                            int applicationIndex = index - joined.length - 2;
                            return Padding(
                              padding: EdgeInsets.zero,
                              child: Card(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
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
                                        'members': applications[applicationIndex]["Members"],
                                        'groupId': joined[applicationIndex]["GroupId"],
                                        'groupName': applications[applicationIndex]["GroupName"],
                                      });
                                    },
                                    title: Text(applications[applicationIndex]["GroupName"],
                                        style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ),
                              ),
                            );
                          } else if (index == joined.length + applications.length + 2) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Shortlist',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            );
                          } else {
                            int shortlistIndex = index - joined.length - applications.length - 3;
                            return Padding(
                              padding: EdgeInsets.zero,
                              child: Card(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
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
                                        'members': shortList[shortlistIndex]["Members"],
                                        'groupId': joined[shortlistIndex]["GroupId"],
                                        'groupName': shortList[shortlistIndex]["GroupName"],
                                      });
                                    },
                                    title: Text(
                                        shortList[shortlistIndex]["GroupName"],
                                        style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),

                    ),
                  ],
                ),
                bottomNavigationBar: CustomNavbar(
                  onItemSelected: (route) {
                    navigator.pushNamed(route);
                  },
                ),
              );

            },
          );


        }
      },
    );
  }
}

