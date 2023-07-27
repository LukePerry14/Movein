import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movein/navbar.dart';
import 'package:movein/HScroll.dart';
import 'package:movein/ad_helper.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Scroller extends StatefulWidget {
  const Scroller({Key? key}) : super(key: key);

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  bool refresh = true;
  int index = 0;
  final String userId = "iKxLSxcDqlT6vtHe71Bp"; //change to stored userId when cache implemented
  late NativeAd _ad;
  bool _isAdLoaded = false;
  bool adTime = true;



  Future<List<Map<String, dynamic>>> getGroups() async {
    List<Map<String, dynamic>> groups = [];
    final CollectionReference docGroups = FirebaseFirestore.instance.collection("Groups");

    try {
      QuerySnapshot querySnapshot = await docGroups
          .where('AllowedUnis', arrayContains: 'Durham')
          .get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {

        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

        if (docSnapshot.exists && !data?["BlackList"].contains(userId)) { //change this line to use the stored userId

          Map<String, dynamic> groupData = {
            'Id': docSnapshot.id,
            'GroupName': data!['GroupName'].toString(),
            'GroupPicture': data['GroupPicture'].toString(),
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

  Future<void> addToBlacklist(String groupId) async {
    final CollectionReference groupCollection = FirebaseFirestore.instance.collection('Groups');
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');

    try {
      // Access the group document
      DocumentSnapshot groupSnapshot = await groupCollection.doc(groupId).get();

      if (groupSnapshot.exists) {
        // Perform array union on BlackList field within the group document
        await groupCollection.doc(groupId).update({'BlackList': FieldValue.arrayUnion([userId])});

        // Access the user document
        DocumentSnapshot userSnapshot = await userCollection.doc(userId).get();
        if (userSnapshot.exists) {
          // Perform array union on BlockedGroups field within the user document
          await userCollection.doc(userId).update({'BlockedGroups': FieldValue.arrayUnion([groupId])});
        } else {
          throw FirebaseException(message: 'Error: User Does not exist', plugin: 'cloud_firestore');
        }
      } else {
        throw FirebaseException(message: 'Error: Group Does not exist', plugin: 'cloud_firestore');
      }
    } catch (e) {
      throw FirebaseException(message: 'Error adding to BlackList: $e', plugin: 'cloud_firestore');
    }
  }

  Future<void> addToShortList(String groupId) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

    usersCollection.doc(userId).update({
      'ShortList': FieldValue.arrayUnion([groupId])})
        .catchError((e) {
      throw FirebaseException(message: 'Error adding to shortlist: $e', plugin: 'cloud_firestore');
    });
    addToBlacklist(groupId);
  }

  Future<void> addToApplicants(String groupId) async {
    final CollectionReference groupsCollection =
    FirebaseFirestore.instance.collection('Groups');

    final DocumentReference groupDocRef = groupsCollection.doc(groupId);

    groupDocRef.update({
      'Applicants': FieldValue.arrayUnion([userId])
    }).catchError((e) {
      throw FirebaseException(message: 'Error adding to group field "Applicants": $e', plugin: 'cloud_firestore');
    });

    final DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    userDocRef.update({
      'Applications': FieldValue.arrayUnion([groupId])
    }).catchError((e) {
      throw FirebaseException(message: 'Error adding to user field "Applications": $e', plugin: 'cloud_firestore');
    });

    addToBlacklist(groupId);
  }

  void loadNativeAd(){
    if (!kIsWeb){
      _ad = NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110',//AdHelper.nativeAdUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
            onAdLoaded: (ad){
              setState () {
                _isAdLoaded = true;
              }
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              print("Error to load ad ${error.message}, ${error.code}");
            }
        ),
      );

      _ad.load();
    }
  }

  @override
  void initState() {
    loadNativeAd();
    super.initState();
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
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
              if (groupData.isEmpty){
                Navigator.of(context).pushReplacementNamed('/ScrollRefresh');
              }
              final navigator = Navigator.of(context);
              bool loadAd = ((index > 0) & (index % 3 == 0) & adTime);
              adTime = !loadAd;
              return Material(
                color: Colors.transparent,
                child: SafeArea(
                  child: Scaffold(
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                    body: Container(
                      alignment: Alignment.center,
                      child: loadAd
                          ? const Text('Add in CustomAd Widget here') //CustomAd(ad: _ad) // Replace CustomAd with the appropriate widget you want to show as the ad
                          : Gscroller(
                        groupName: groupData[index]['GroupName'],
                        groupPicture: groupData[index]['GroupPicture'],
                        members: groupData[index]['Members'],
                        showFriend: true,
                      ),
                    ),
                    floatingActionButton: loadAd
                        ? FloatingActionButton(
                            heroTag: "AdNext",
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                            onPressed: () {
                              setState(() {
                                adTime = false;
                              });
                            },
                            child: const Icon(LineAwesomeIcons.angle_right, color: Colors.white),
                          )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          heroTag: "Block",
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          onPressed: () {
                            addToBlacklist(groupData[index]['Id'])
                                .then((_) {
                              if (index < groupData.length - 1){
                                setState(() {
                                  index++;
                                });
                              } else{
                                navigator.pushReplacementNamed('/ScrollRefresh');
                              }
                            })
                                .catchError((e) {
                              throw FirebaseException(message: 'Error calling addToBlacklist: $e', plugin: 'cloud_firestore');
                            });
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
                            addToShortList(groupData[index]['Id'])
                                .then((_) {
                              if (index < groupData.length - 1){
                                setState(() {
                                  index++;
                                });
                              }else{
                                navigator.pushReplacementNamed('/ScrollRefresh');
                              }
                            })
                                .catchError((e) {
                              throw FirebaseException(message: 'Error calling addToShortlist: $e', plugin: 'cloud_firestore');
                            });
                          },
                          child: const Icon(LineAwesomeIcons.archive, color: Colors.white),
                        ),
                        FloatingActionButton(
                          heroTag: "Apply",
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          onPressed: () {
                            addToApplicants(groupData[index]['Id'])
                                .then((_) {
                              if (index < groupData.length - 1){
                                setState(() {
                                  index++;
                                });
                              }else{
                                navigator.pushReplacementNamed('/ScrollRefresh');
                              }
                            })
                                .catchError((e) {
                              throw FirebaseException(message: 'Error calling addToApplicants: $e', plugin: 'cloud_firestore');
                            });
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
class CustomAd extends StatelessWidget {
  final NativeAd ad;
  const CustomAd({
    Key? key,
    required this.ad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double height = width; // Calculate the height based on the width

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
              child: AdWidget(ad: ad),
          );
        }
    );
  }
}
