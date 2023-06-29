import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/profile-data.dart';

class GroupOptions extends StatefulWidget {
  const GroupOptions({Key? key}) : super(key: key);

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {
  Map data = {};

  void gNameChange(){

  }

  Future<List<List<dynamic>>> getUsers(idList, groupId) async {
    List<Map<String,dynamic>> memberDetails = [];
    List<Map<String,dynamic>> applicants = [];
    List<String> voteKicks = [];

    final CollectionReference docUsers = FirebaseFirestore.instance.collection("Users");

    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance.collection("Groups").doc(groupId).get();
      Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;

      if (groupData != null) {
        List<String> applicantIds = List<String>.from(groupData["Applicants"]);
        List<String> kickIds = List<String>.from(groupData["Kicks"]);

        for (String aId in applicantIds){
          DocumentSnapshot docSnapshot = await docUsers.doc(aId).get();
          Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
          applicants.add({
            "ForeName": data?['Forename'],
            "SurName": data?['Surname'],
            "Id": aId,
            "Images": data?['Images'],
          });
        }

        for (String id in idList) {
          try {
            DocumentSnapshot docSnapshot = await docUsers.doc(id).get();
            Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

            if (kickIds.contains(id)) {
              voteKicks.add(id);
            }

            memberDetails.add({
              "ForeName": data?['Forename'],
              "SurName": data?['Surname'],
              "Id": id,
              "Images": data?['Images'],
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

    return [memberDetails, applicants, voteKicks];
  }

  @override
  Widget build(BuildContext context) {

    data = ModalRoute.of(context)?.settings.arguments as Map;
    List<String> members = data['members'] as List<String>;
    String groupId = data['groupId'] as String;



    return FutureBuilder<List<List<dynamic>>>(
      future: getUsers(members, groupId),
      builder: (BuildContext context, AsyncSnapshot<List<List<dynamic>>> snapshot) {
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
          var memberDetails = snapshot.data?[0]?? [];
          var applicants = snapshot.data?[1] ?? [];
          var voteKicks = snapshot.data?[2] ?? [];



          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Theme.of(context).canvasColor,
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

                  Stack( // Group picture
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("testing");
                        },
                        child: SizedBox(
                          width: 100, height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const Image(image: AssetImage("assets/Pictures/ph.png")),
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
                    onTap: () {
                      gNameChange();
                    },
                    child: Text("${data['groupName']}", style: Theme.of(context).textTheme.headlineSmall),

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
                        child: Text("Members", style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),


                  // Group Members builder
                  LayoutBuilder( //Members constructor
                      builder: (context, constraints) {

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: memberDetails.length,
                              itemBuilder: (context, index) {
                                bool isVoteKick = voteKicks.contains(memberDetails[index]["Id"]);
                                return GestureDetector(
                                  onTap: () {
                                    // Open sub-menu for profile related activities
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: const Image(image: AssetImage("assets/Pictures/ph.png")),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${memberDetails[index]["ForeName"]} ${memberDetails[index]["SurName"]}",
                                              style: isVoteKick ? GoogleFonts.sourceCodePro(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0) : Theme.of(context).textTheme.headlineSmall,
                                            ),
                                            Text(
                                              "${memberDetails[index]["Id"]}",
                                              style: isVoteKick ? GoogleFonts.sourceCodePro(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0) : Theme.of(context).textTheme.headlineSmall,
                                            ),
                                          ],
                                        ),
                                        if (isVoteKick)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              "KickVote",
                                              style: GoogleFonts.sourceCodePro(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          ),
                        );
                      }
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

                  LayoutBuilder( // applications Section
                      builder: (context, constraints) {

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: applicants.length,
                                itemBuilder: (context, index) {
                                  bool hasPFP = applicants[index]["Images"][0] != "";
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50, height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image(image: hasPFP ? AssetImage(applicants[index]["Images"][0]) : const AssetImage("assets/Pictures/ph.png")),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${applicants[index]["Forename"]} ${applicants[index]["SurName"]}", style: Theme.of(context).textTheme.headlineSmall,),
                                            Text(applicants[index]["Id"], style: Theme.of(context).textTheme.bodySmall,)
                                          ],
                                        )
                                      ],

                                    ),
                                  );
                                }
                            ),
                          ),
                        );
                      }
                  ),

                  const SizedBox(width: 20),

                  //Configuration buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0.0, 10.0, 0.0),

                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            gNameChange();
                          },
                          title: Text("Edit Group Name", style: Theme.of(context).textTheme.bodyMedium,),
                        ),

                        ListTile(
                          onTap: () {
                            // edit leave group
                          },
                          title: Text("Leave Group", style: GoogleFonts.roboto(color: Colors.red, fontSize: 16.5)),
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

