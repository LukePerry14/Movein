import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/FriendFunctions.dart';
import 'package:movein/swipe_card.dart';
import 'package:movein/GroupFunctions.dart';

class GroupOptions extends StatefulWidget {
  const GroupOptions({Key? key}) : super(key: key);

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {
  var data = {};
  late String groupId;
  late Future<List<dynamic>> _myFuture;

  Future<List<dynamic>> getUsers(groupId) async {
    List<Map<String, dynamic>> memberDetails = [];
    List<Map<String, dynamic>> applicants = [];
    List<String> voteKicks = [];
    Map<String, List<int>> kickVals = {};
    Map<String, List<int>> appVals = {};
    var groupName = "";
    var groupPicture = "";


    final CollectionReference docUsers = FirebaseFirestore.instance.collection("Users");

    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance.collection("Groups").doc(groupId).get();

      Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;

      if (groupData != null) {
        groupName = groupData['GroupName'];
        groupPicture = groupData['GroupPicture'];

        var tempKickVals = groupData["KickVals"];
        for (var key in tempKickVals.keys) {
          int agree = 0;
          int disagree = 0;
          var innerMap = tempKickVals[key];

          innerMap.forEach((innerKey, innerValue) {
            if (innerValue == 1) {
              agree += 1;
            } else {
              disagree += 1;
            }
          });

          kickVals[key] = [agree, disagree];
        }


        var tempAppVals = groupData["AppVals"];
        for (var key in tempAppVals.keys) {
          int agree = 0;
          int disagree = 0;
          var innerMap = tempAppVals[key];

          innerMap.forEach((innerKey, innerValue) {
            if (innerValue == 1) {
              agree += 1;
            } else {
              disagree += 1;
            }
          });

          appVals[key] = [agree, disagree];
        }

        var applicantIds = groupData["Applicants"];
        for (var aId in applicantIds) {
          if (!(aId == "")) {
            DocumentSnapshot docSnapshot = await docUsers.doc(aId).get();
            Map<String, dynamic>? data = docSnapshot.data() as Map<
                String,
                dynamic>?;

            final dateTime = data?['DOB'].toDate();
            final currentDate = DateTime.now();
            final difference = currentDate.difference(dateTime);
            final yearsAgo = difference.inDays ~/ 365;
            applicants.add({
              "ForeName": data?['Forename'],
              "SurName": data?['Surname'],
              "Age": yearsAgo,
              "Uni": data?['UniAttended'],
              "Preferences": data?['Preferences'],
              "Images": data?['Images'],
              "Bio": data?['Bio'],
              "Subject": data?['Subject'],
              "YearOfStudy": data?['YearOfStudy'],
              "Id": aId,
            });
          }
        }

        var members = groupData['Members'];
        var kickIds = groupData["Kicks"];
        for (String id in members) {
          try {
            DocumentSnapshot docSnapshot = await docUsers.doc(id).get();
            Map<String, dynamic>? data = docSnapshot.data() as Map<
                String,
                dynamic>?;

            final dateTime = data?['DOB'].toDate();
            final currentDate = DateTime.now();
            final difference = currentDate.difference(dateTime);
            final yearsAgo = difference.inDays ~/ 365;

            if (kickIds.contains(id)) {
              voteKicks.add(id);
            }

            memberDetails.add({
              "ForeName": data?['Forename'],
              "SurName": data?['Surname'],
              "Age": yearsAgo,
              "Uni": data?['UniAttended'],
              "Preferences": data?['Preferences'],
              "Images": data?['Images'],
              "Bio": data?['Bio'],
              "Subject": data?['Subject'],
              "YearOfStudy": data?['YearOfStudy'],
              "Id": id,
            });
          } catch (e) {
            throw FirebaseException(
              message: 'Error fetching member data in GroupOptions: $e',
              plugin: 'cloud_firestore',
            );
          }
        }
      }
    } catch (e) {
      throw FirebaseException(
        message: 'Error fetching group data in GroupOptions: $e',
        plugin: 'cloud_firestore',
      );
    }

    return [memberDetails, applicants, voteKicks, kickVals, appVals, groupName, groupPicture];
  }

  void _refreshData() {
    setState(() {
      _myFuture = getUsers(groupId); // Recreate the Future to trigger the FutureBuilder.
    });
  }
  
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    data = ModalRoute.of(context)?.settings.arguments as Map;
    groupId = data['groupId'];
    _myFuture = getUsers(groupId);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _myFuture,
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
          List data = snapshot.data!;
          List<Map<String, dynamic>> memberDetails = data[0] as List<Map<String, dynamic>>;
          List<Map<String, dynamic>> applicants = data[1] as List<Map<String, dynamic>>;
          var kicks = data[2];
          var kickVals = data[3];
          var appVals = data[4];
          var groupName = data[5];
          var groupPicture = data[6];


          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Theme
                  .of(context)
                  .canvasColor,
              leading: IconButton(
                icon: const Icon(LineAwesomeIcons.angle_left),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    // Group picture
                    children: [
                      GestureDetector(
                        onTap: () {
                          _refreshData();
                        },
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image(image: AssetImage(groupPicture)),
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
                  GestureDetector(
                    onTap: () async {
                      await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => EditGroupName(name: groupName, groupId: groupId),
                      );
                      _refreshData();
                    },
                    child: Text(
                      groupName,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Container(
                    color: Theme.of(context).primaryColor,
                    height: 1.0,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const SizedBox(width: 13),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                        Text("Members", style: Theme
                            .of(context)
                            .textTheme
                            .headlineSmall),
                      ),
                    ],
                  ),
                  // Group Members builder
                  LayoutBuilder(
                    //Members constructor
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: memberDetails.length,
                            itemBuilder: (context, index) {
                              bool isVoteKick = kicks.contains(
                                  memberDetails[index]['Id']);
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        CustomDialog(
                                          id: memberDetails[index]['Id'],
                                          foreName: memberDetails[index]['ForeName'],
                                          age: memberDetails[index]['Age'],
                                          uni: memberDetails[index]['Uni'],
                                          preferences: memberDetails[index]['Preferences'],
                                          images: memberDetails[index]['Images'],
                                          bio: memberDetails[index]['Bio'],
                                          subject: memberDetails[index]['Subject'],
                                          yearOfStudy: memberDetails[index]['YearOfStudy'],
                                        ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                100),
                                            child: Image(
                                                image: AssetImage(memberDetails[index]["Images"][0])),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              "${memberDetails[index]["ForeName"]} ${memberDetails[index]["SurName"]}",
                                              style: isVoteKick
                                                  ? GoogleFonts.sourceCodePro(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                              )
                                                  : Theme.of(context).textTheme.headlineSmall,
                                            ),
                                            Text(
                                              "${memberDetails[index]["Id"]}",
                                              style: isVoteKick
                                                  ? GoogleFonts.sourceCodePro(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.0,
                                              )
                                                  : Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        Expanded(child: Container()),
                                        if (isVoteKick)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "KickVote",
                                                  style: GoogleFonts
                                                      .sourceCodePro(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Agree: ${kickVals[memberDetails[index]["Id"]][0]}",
                                                      style: GoogleFonts.sourceCodePro(
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10.0,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    SizedBox(
                                                      width: 2,
                                                      height: 13,
                                                      child: Container(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      "Disagree: ${kickVals[memberDetails[index]["Id"]][1]}",
                                                      style: GoogleFonts.sourceCodePro(
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) =>
                                          [
                                            PopupMenuItem<String>(
                                              value: 'add',
                                              child: Text(
                                                'Add friend',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ),
                                            if (isVoteKick)
                                              const PopupMenuDivider(height: 5),
                                            if (isVoteKick)
                                              PopupMenuItem(
                                                value: 'agree',
                                                child: Text(
                                                  'Agree vote-kick',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                            if (isVoteKick)
                                              PopupMenuItem(
                                                value: 'disagree',
                                                child: Text(
                                                  'Disagree vote-kick',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                            if (!isVoteKick)
                                              PopupMenuItem<String>(
                                                value: 'kick',
                                                child: Text(
                                                  'Start Vote-kick',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'add') {
                                              sendFriendInvite(memberDetails[index]["Id"]);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Theme.of(context).primaryColor,
                                                  content: const Text('Friend invite sent'),
                                                ),
                                              );
                                            } else if (value == 'kick') {
                                              await kickUser(memberDetails[index]["Id"], groupId);
                                              _refreshData();
                                            } else if (value == 'agree') {
                                              await updateKickVote(groupId, true, memberDetails[index]["Id"], memberDetails.length);
                                              _refreshData();
                                            } else if (value == 'disagree') {
                                              await updateKickVote(groupId, false, memberDetails[index]["Id"], memberDetails.length);
                                              _refreshData();
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                          splashRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const SizedBox(width: 13),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Applications", style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),
                  LayoutBuilder(
                    // applications Section
                    builder: (context, constraints) {
                      bool hasApps = applicants.isEmpty;
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: hasApps
                              ? SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Empty", style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: applicants.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        CustomDialog(
                                          id: applicants[index]['Id'],
                                          foreName: applicants[index]['ForeName'],
                                          age: applicants[index]['Age'],
                                          uni: applicants[index]['Uni'],
                                          preferences: applicants[index]['Preferences'],
                                          images: applicants[index]['Images'],
                                          bio: applicants[index]['Bio'],
                                          subject: applicants[index]['Subject'],
                                          yearOfStudy: applicants[index]['YearOfStudy'],
                                        ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                100),
                                            child: Image(image: AssetImage(applicants[index]["Images"][0])),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${applicants[index]["ForeName"]} ${applicants[index]["SurName"]}",
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            ),
                                            Text(
                                              applicants[index]["Id"],
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        Expanded(child: Container()),
                                        Row(
                                          children: [
                                            Text(
                                              "Agree: ${appVals[applicants[index]["Id"]][0]}",
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                            const SizedBox(width: 3),
                                            SizedBox(
                                              width: 2,
                                              height: 18,
                                              child: Container(
                                                  color: Colors.black87
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              "Disagree: ${appVals[applicants[index]["Id"]][1]}",
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) =>
                                          [
                                            PopupMenuItem(
                                              value: 'accept',
                                              child: Text(
                                                'Vote accept',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'decline',
                                              child: Text(
                                                'Vote decline',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'accept') {
                                              await updateApplicationVote(groupId, true, applicants[index]["Id"], memberDetails.length);
                                              _refreshData();
                                            } else if (value == 'decline') {
                                              await updateApplicationVote(groupId, false, applicants[index]["Id"], memberDetails.length);
                                              _refreshData();
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                          splashRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  //Configuration buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0.0, 10.0, 0.0),
                    child: Column(
                      children: [
                        ListTile(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () async {
                            await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => GroupExpand(id: groupId, groupName: groupName, groupPicture: groupPicture, members: memberDetails.map((item) => item["Id"] as String).toList())
                            );
                          },
                          title: Text(
                            "Preview Group",
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium,
                          ),
                        ),
                        ListTile(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () async {
                            await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => EditGroupName(name: groupName, groupId: groupId),
                            );
                            _refreshData();
                          },
                          title: Text(
                            "Edit Group Name",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        ListTile(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () async {
                            await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => ConfirmLeave(groupId: groupId, memCount: memberDetails.length,),
                            );
                          },
                          title: Text(
                            "Leave Group",
                            style: GoogleFonts.roboto(
                                color: Colors.red, fontSize: 16.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}