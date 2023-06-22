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
  int index = 0;

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

        if (blacklistDoc.exists && !blacklistDoc['List'].contains('example_id')) {
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
          return const CircularProgressIndicator();
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
                          backgroundColor: Theme.of(context).primaryColor?.withOpacity(0.5),
                          onPressed: () {
                            if(index < groupData.length-1){
                              setState(() {
                                index++;
                              });
                            }
                          },
                          child: const Icon(LineAwesomeIcons.angle_right, color: Colors.white),
                        ),
                        FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor?.withOpacity(0.5),
                          onPressed: () {
                            if(index < groupData.length-1){
                              setState(() {
                                index++;
                              });
                            }
                          },
                          child: const Icon(LineAwesomeIcons.times, color: Colors.white),
                        ),
                        FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor?.withOpacity(0.5),
                          onPressed: () {
                            if(index < groupData.length-1){
                              setState(() {
                                index++;
                              });
                            }
                          },
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
      },
    );
  }
}
