import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Scroller%20Code/HScroll.dart';
import 'package:movein/Ad%20code/ad_helper.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../Auth code/auth.dart';

class Scroller extends StatefulWidget {
  const Scroller({Key? key}) : super(key: key);

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  bool refresh = true;
  int index = 0;
  late NativeAd _ad;
  bool _isAdLoaded = false;
  bool _adTime = true;
  final double _adAspectRatioMedium = (370.0 / 355.0);

  Future<List<Map<String, dynamic>>> getGroups() async {
    List<Map<String, dynamic>> groups = [];
    final CollectionReference docGroups =
        FirebaseFirestore.instance.collection("Groups");

    try {
      QuerySnapshot querySnapshot =
          await docGroups.where('AllowedUnis', arrayContains: 'Durham').get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (docSnapshot.exists && !data?["BlackList"].contains(Auth().currentUser())) {
          //change this line to use the stored userId

          Map<String, dynamic> groupData = {
            'Id': docSnapshot.id,
            'GroupName': data!['GroupName'].toString(),
            'GroupPicture': data['GroupPicture'].toString(),
            'Members': List<String>.from(
                data['Members'].map((member) => member.toString())),
            'AvgCleanliness' : (data['AvgCleanliness'] as num).toDouble(),
            'AvgNoisiness' : (data['AvgNoisiness'] as num).toDouble(),
            'AvgNightLife' : (data['AvgNightLife'] as num).toDouble(),
            'AvgBedTime' : data['AvgBedTime']
          };
          groups.add(groupData);
        }
      }
    } catch (e) {
      throw FirebaseException(
          message: 'Error fetching data: $e', plugin: 'cloud_firestore');
    }

    return groups;
  }

  // @override
  // void initState() {
  //   _loadAd();
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   _ad.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Map<String, dynamic>> groupData = snapshot.data ?? [];

          return Builder(
            builder: (context) {
              final navigator = Navigator.of(context);
              bool loadAd = ((index > 0) & (index % 3 == 0) & _adTime);
              return Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: Container(
                  alignment: Alignment.center,
                  child: (groupData.isEmpty)
                      ? const NoGroups()
                      : loadAd ? Container()
                  //         ? Stack(
                  //   children: [
                  //     SizedBox(
                  //         height: MediaQuery.of(context).size.width,
                  //         width: MediaQuery.of(context).size.width),
                  //     if (_isAdLoaded)
                  //       SizedBox(
                  //           height: MediaQuery.of(context).size.width,
                  //           width: MediaQuery.of(context).size.width,
                  //           child: AdWidget(ad: _ad)),
                  //   ],
                  // )
                          : Gscroller(
                              groupName: groupData[index]['GroupName'],
                              groupPicture: groupData[index]
                                  ['GroupPicture'],
                              members: groupData[index]['Members'],
                              avgBedTime: groupData[index]['AvgBedTime'],
                              avgNoisiness: groupData[index]['AvgNoisiness'],
                              avgCleanliness: groupData[index]['AvgCleanliness'],
                              avgNightLife: groupData[index]['AvgNightLife'],
                              showFriend: true,
                            ),
                ),
                floatingActionButton: Visibility(
                  visible: groupData.isNotEmpty,
                  child: loadAd
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              heroTag: "Block",
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              onPressed: () {
                                _adTime = true;
                                addToBlacklist(groupData[index]['Id'])
                                    .then((_) {
                                  if (index < groupData.length - 1) {
                                    setState(() {
                                      index++;
                                    });
                                  } else {
                                    navigator.pushReplacementNamed('/ScrollRefresh');
                                  }
                                }).catchError((e) {
                                  throw FirebaseException(
                                    message:
                                        'Error calling addToBlacklist: $e',
                                    plugin: 'cloud_firestore',
                                  );
                                });
                              },
                              child: Column(
                                children: [
                                  const SizedBox(height: 9),
                                  const Icon(LineAwesomeIcons.times, color: Colors.white),
                                  Text("block".tr, style: GoogleFonts.redHatDisplay(color: Colors.white, fontSize: 8),)
                                ]
                              ),
                            ),
                            FloatingActionButton(
                              heroTag: "Next",
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              onPressed: () {
                                _adTime = true;
                                if (index < groupData.length - 1) {
                                  setState(() {
                                    index++;
                                  });
                                } else {
                                  navigator.pushReplacementNamed('/ScrollRefresh');
                                }
                              },
                              child: Column(
                                  children: [
                                    const SizedBox(height: 9),
                                    const Icon(LineAwesomeIcons.angle_right, color: Colors.white),
                                    Text("next".tr, style: GoogleFonts.redHatDisplay(color: Colors.white, fontSize: 8),)
                                  ]
                              ),
                            ),
                            FloatingActionButton(
                              heroTag: "Shortlist",
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              onPressed: () {
                                _adTime = true;
                                addToShortList(groupData[index]['Id'])
                                    .then((_) {
                                  if (index < groupData.length - 1) {
                                    setState(() {
                                      index++;
                                    });
                                  } else {
                                    navigator.pushReplacementNamed(
                                        '/ScrollRefresh');
                                  }
                                }).catchError((e) {
                                  throw FirebaseException(
                                    message:
                                        'Error calling addToShortlist: $e',
                                    plugin: 'cloud_firestore',
                                  );
                                });
                              },
                              child: Column(
                                  children: [
                                    const SizedBox(height: 9),
                                    const Icon(LineAwesomeIcons.archive, color: Colors.white),
                                    Text("sList".tr, style: GoogleFonts.redHatDisplay(color: Colors.white, fontSize: 8),)
                                  ]
                              ),
                            ),
                            FloatingActionButton(
                              heroTag: "Apply",
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              onPressed: () {
                                _adTime = true;
                                addToApplicants(groupData[index]['Id'])
                                    .then((_) {
                                  if (index < groupData.length - 1) {
                                    setState(() {
                                      index++;
                                    });
                                  } else {
                                    navigator.pushReplacementNamed(
                                        '/ScrollRefresh');
                                  }
                                }).catchError((e) {
                                  throw FirebaseException(
                                    message:
                                        'Error calling addToApplicants: $e',
                                    plugin: 'cloud_firestore',
                                  );
                                });
                              },
                              child: Column(
                                  children: [
                                    const SizedBox(height: 9),
                                    const Icon(LineAwesomeIcons.check, color: Colors.white),
                                    Text("apply".tr, style: GoogleFonts.redHatDisplay(color: Colors.white, fontSize: 8),)
                                  ]
                              ),
                            ),
                          ],
                        ),
                ),
                bottomNavigationBar: CustomNavbar(
                  onItemSelected: (route) {
                    navigator.pushReplacementNamed(route);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
  void _loadAd() {
    setState(() {
      _isAdLoaded = false;
    });

    _ad = NativeAd(
        adUnitId: AdHelper.nativeAdUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            // ignore: avoid_print
            print('$NativeAd loaded.');
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            print('$NativeAd failedToLoad: $error');
            _ad.dispose();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {
            _adTime = false;
            _ad.dispose();
          },
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: const Color(0xfffffbed),
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
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
    });
  }
}

class NoGroups extends StatelessWidget {
  const NoGroups({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(
                LineAwesomeIcons.exclamation_circle,
                color: Theme.of(context).primaryColor,
                fill: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
                "You've seen to have run out of groups for now, Consider making your own or refresh to try and have another look",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 25),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/Scroller');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Future<void> addToBlacklist(String groupId) async {
  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection('Groups');
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('Users');

  try {
    // Access the group document
    DocumentSnapshot groupSnapshot = await groupCollection.doc(groupId).get();

    if (groupSnapshot.exists) {
      // Perform array union on BlackList field within the group document
      await groupCollection.doc(groupId).update({
        'BlackList': FieldValue.arrayUnion([Auth().currentUser()])
      });

      // Access the user document
      DocumentSnapshot userSnapshot = await userCollection.doc(Auth().currentUser()).get();
      if (userSnapshot.exists) {
        // Perform array union on BlockedGroups field within the user document
        await userCollection.doc(Auth().currentUser()).update({
          'BlockedGroups': FieldValue.arrayUnion([groupId])
        });
      } else {
        throw FirebaseException(
            message: 'Error: User Does not exist', plugin: 'cloud_firestore');
      }
    } else {
      throw FirebaseException(
          message: 'Error: Group Does not exist', plugin: 'cloud_firestore');
    }
  } catch (e) {
    throw FirebaseException(
        message: 'Error adding to BlackList: $e', plugin: 'cloud_firestore');
  }
}

Future<void> addToShortList(String groupId) async {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  usersCollection.doc(Auth().currentUser()).update({
    'ShortList': FieldValue.arrayUnion([groupId])
  }).catchError((e) {
    throw FirebaseException(
        message: 'Error adding to shortlist: $e', plugin: 'cloud_firestore');
  });
  addToBlacklist(groupId);
}

Future<void> addToApplicants(String groupId) async {
  final CollectionReference groupsCollection =
  FirebaseFirestore.instance.collection('Groups');

  final DocumentReference groupDocRef = groupsCollection.doc(groupId);

  groupDocRef.update({
    'Applicants': FieldValue.arrayUnion([Auth().currentUser()]),
    'AppVals.${Auth().currentUser()}': {},
  }).catchError((e) {
    throw FirebaseException(
        message: 'Error adding to group field "Applicants": $e',
        plugin: 'cloud_firestore');
  });

  final DocumentReference userDocRef =
  FirebaseFirestore.instance.collection('Users').doc(Auth().currentUser());

  userDocRef.update({
    'Applications': FieldValue.arrayUnion([groupId])
  }).catchError((e) {
    throw FirebaseException(
        message: 'Error adding to user field "Applications": $e',
        plugin: 'cloud_firestore');
  });

  addToBlacklist(groupId);
}