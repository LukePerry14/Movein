import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:movein/profile-data.dart';
import 'package:movein/swipe_card.dart';

class GroupOptions extends StatefulWidget {
  const GroupOptions({Key? key}) : super(key: key);

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {
  var data = {};

  Future<List<dynamic>> getUsers(idList, groupId) async {
    List<Map<String,dynamic>> memberDetails = [];
    List<Map<String,dynamic>> applicants = [];
    List<String> voteKicks = [];
    String groupPic = "";

    final CollectionReference docUsers = FirebaseFirestore.instance.collection("Users");

    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance.collection("Groups").doc(groupId).get();
      Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;

      if (groupData != null) {
        var applicantIds = groupData["Applicants"];
        var kickIds = groupData["Kicks"];
        var groupPic = groupData["GroupPicture"];

        for (var aId in applicantIds){
          if (!(aId == "")){
            DocumentSnapshot docSnapshot = await docUsers.doc(aId).get();
            Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

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

        for (String id in idList) {
          try {
            DocumentSnapshot docSnapshot = await docUsers.doc(id).get();
            Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

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

    return [memberDetails, applicants, voteKicks, groupPic];
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map;
    var members = data['members'];
    var groupId = data['groupId'];
    var groupName = data['groupName'];
    return FutureBuilder<List<dynamic>>(
      future: getUsers(members, groupId),
        builder: (context, snapshot){
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
          } else{
            List data = snapshot.data!;
            List<Map<String,dynamic>> memberDetails = data[0] as List<Map<String,dynamic>>;
            List<Map<String,dynamic>> applicants = data[1] as List<Map<String,dynamic>>;
            var kicks = data[2];
            var groupPic = data[3];

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
                              child: Image(image: AssetImage(groupPic)),
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
                        //gNameChange();
                      },
                      child: Text(groupName, style: Theme.of(context).textTheme.headlineSmall),

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
                                  bool isVoteKick = kicks.contains(memberDetails[index]['Id']);
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) => CustomDialog(
                                              id: memberDetails[index]['Id'],
                                              foreName: memberDetails[index]['ForeName'],
                                              age: memberDetails[index]['Age'],
                                              uni: memberDetails[index]['Uni'],
                                              preferences: memberDetails[index]['Preferences'],
                                              images: memberDetails[index]['Images'],
                                              bio: memberDetails[index]['Bio'],
                                              subject: memberDetails[index]['Subject'],
                                              yearOfStudy: memberDetails[index]['YearOfStudy']
                                          )
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
                                                  style: isVoteKick ? GoogleFonts.sourceCodePro(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12.0) : Theme.of(context).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                            Expanded(child: Container()),
                                            if (isVoteKick)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  "KickVote",
                                                  style: GoogleFonts.sourceCodePro(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),
                                                ),
                                              ),
                                            IconButton(
                                                onPressed: () {
                                                  // open sub-menu
                                                },
                                                icon: const Icon(Icons.more_vert)
                                            )
                                          ],
                                        ),
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
                          bool hasApps = applicants.isEmpty;
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: hasApps ?
                              SizedBox(
                                width: double.maxFinite,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                      child: Text("Empty", style: Theme.of(context).textTheme.bodyLarge)
                                  )
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
                                            builder: (BuildContext context) => CustomDialog(
                                                id: applicants[index]['Id'],
                                                foreName: applicants[index]['ForeName'],
                                                age: applicants[index]['Age'],
                                                uni: applicants[index]['Uni'],
                                                preferences: applicants[index]['Preferences'],
                                                images: applicants[index]['Images'],
                                                bio: applicants[index]['Bio'],
                                                subject: applicants[index]['Subject'],
                                                yearOfStudy: applicants[index]['YearOfStudy']
                                            )
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
                                                width: 50, height: 50,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(100),
                                                  child: Image(image: AssetImage(applicants[index]["Images"][0])),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("${applicants[index]["Forename"]} ${applicants[index]["SurName"]}", style: Theme.of(context).textTheme.headlineSmall,),
                                                  Text(applicants[index]["Id"], style: Theme.of(context).textTheme.bodySmall,)
                                                ],
                                              ),
                                              Expanded(child: Container()),
                                              IconButton(
                                                  onPressed: () {
                                                    // open sub-menu
                                                  },
                                                  icon: const Icon(Icons.more_vert)
                                              )
                                            ],

                                          ),
                                        ),
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
                              //gNameChange();
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
    }
    );
  }
}