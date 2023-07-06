import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/HScroll.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';


class Scroller extends StatefulWidget {
  const Scroller({Key? key}) : super(key: key);

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  bool refresh = true;
  int index = 0;
  String userId = "iKxLSxcDqlT6vtHe71Bp"; //change to stored userId when cache implemented


  Future<void> addToBlacklist(String groupId) async {
    final CollectionReference groupCollection = FirebaseFirestore.instance.collection('Groups');

    try {
      // Access the group document
      DocumentSnapshot groupSnapshot = await groupCollection.doc(groupId).get();
      if (groupSnapshot.exists) {
        // Access the Blacklist subcollection within the group document
        CollectionReference blacklistCollection =
        groupCollection.doc(groupId).collection('Blacklist');

        // Access the BList document within the Blacklist subcollection
        DocumentReference blistDocument = blacklistCollection.doc('BList');

        // Update the List field within the BList document
        await blistDocument.update({'List': FieldValue.arrayUnion(['INSERT STORED USERID'])});
      } else {
        throw FirebaseException(message: 'Error: Group Does not exist', plugin: 'cloud_firestore');
      }
    } catch (e) {
      throw FirebaseException(message: 'Error adding to BlackList: $e', plugin: 'cloud_firestore');
    }
  }

  Future<void> addToShortList(String groupId) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

    usersCollection.doc('INSERT STORED USERID').update({
      'ShortList': FieldValue.arrayUnion([groupId])})
        .catchError((e) {
      throw FirebaseException(message: 'Error adding to shortlist: $e', plugin: 'cloud_firestore');
    });
  }

  Future<void> addToApplicants(String groupId) async {
    final CollectionReference groupsCollection =
    FirebaseFirestore.instance.collection('Groups');

    final DocumentReference groupDocRef = groupsCollection.doc(groupId);

    groupDocRef.update({
      'Applicants': FieldValue.arrayUnion(['INSERT STORED USERID'])
    }).catchError((e) {
      throw FirebaseException(message: 'Error adding to group field "Applicants": $e', plugin: 'cloud_firestore');
    });

    final DocumentReference userDocRef =
    FirebaseFirestore.instance.collection('Users').doc('INSERT STORED USERID');

    userDocRef.update({
      'Applications': FieldValue.arrayUnion([groupId])
    }).catchError((e) {
      throw FirebaseException(message: 'Error adding to user field "Applications": $e', plugin: 'cloud_firestore');
    });
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    List<Map<String, dynamic>> groups = [];
    final CollectionReference docGroups = FirebaseFirestore.instance.collection("Groups");

    try {
      QuerySnapshot querySnapshot = await docGroups
          .where('AllowedUnis', arrayContains: 'Durham')
          .get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        DocumentSnapshot blacklistDoc = await docSnapshot.reference.collection('Blacklist').doc('bList').get();
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

        if (blacklistDoc.exists && !blacklistDoc['List'].contains('example_id') && !docSnapshot['Members'].contains('INSERT STORED USERID')) { //change this line to use the stored userId
          // Convert dynamic values to String
          Map<String, dynamic> groupData = {
            'GroupName': data!['GroupName'].toString(),
            'Members': List<String>.from(data['Members'].map((member) => member.toString())),
          };
          groups.add(groupData);
        }
      }
    } catch (e) {
      throw FirebaseException(message: 'Error fetching data: $e', plugin: 'cloud_firestore');
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
          List<Map<String, dynamic>> groupData = snapshot.data ?? [];

          return Builder(
            builder: (context) {
              final navigator = Navigator.of(context);

              return Material(
                color: Colors.transparent,
                child: SafeArea(
                  child: Scaffold(
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                    body: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Gscroller(
                            groupName: groupData.isNotEmpty ? groupData[index]['GroupName'] : '',
                            members: groupData.isNotEmpty ? groupData[index]['Members'] : [],
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          heroTag: "Block",
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          onPressed: () {
                            if (index < groupData.length - 1) {
                              addToBlacklist(groupData[index]['GroupName'])
                                  .then((_) {
                                setState(() {
                                  index++;
                                });
                              })
                                  .catchError((e) {
                                throw FirebaseException(message: 'Error calling addToBlacklist: $e', plugin: 'cloud_firestore');
                              });
                            } else {
                              navigator.pushReplacementNamed('/ScrollRefresh');
                            }
                          },
                          child: const Icon(LineAwesomeIcons.times, color: Colors.white),
                        ),
                        FloatingActionButton(
                          heroTag: "Next",
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          onPressed: () {
                            if (index < groupData.length - 1) {
                              setState(() {
                                index++;
                              });
                            } else {
                              navigator.pushReplacementNamed('/ScrollRefresh');
                            }
                          },
                          child: const Icon(LineAwesomeIcons.angle_right, color: Colors.white),
                        ),
                        FloatingActionButton(
                          heroTag: "Shortlist",
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          onPressed: () {
                            if (index < groupData.length - 1) {
                              addToShortList(groupData[index]['GroupName'])
                                  .then((_) {
                                setState(() {
                                  index++;
                                });
                              })
                                  .catchError((e) {
                                throw FirebaseException(message: 'Error calling addToShortlist: $e', plugin: 'cloud_firestore');
                              });
                            } else {
                              navigator.pushReplacementNamed('/ScrollRefresh');
                            }
                          },
                          child: const Icon(LineAwesomeIcons.archive, color: Colors.white),
                        ),
                        FloatingActionButton(
                          heroTag: "Apply",
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          onPressed: () {
                            if (index < groupData.length - 1) {
                              addToApplicants(groupData[index]['GroupName'])
                                  .then((_) {
                                setState(() {
                                  index++;
                                });
                              })
                                  .catchError((e) {
                                throw FirebaseException(message: 'Error calling addToApplicants: $e', plugin: 'cloud_firestore');
                              });
                            } else {
                              navigator.pushReplacementNamed('/ScrollRefresh');
                            }
                          },
                          child: const Icon(LineAwesomeIcons.check, color: Colors.white),
                        ),
                      ],
                    ),


                    bottomNavigationBar: CustomNavbar(
                      onItemSelected: (route) {
                        navigator.pushReplacementNamed(route);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}