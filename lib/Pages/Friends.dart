import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Friend%20And%20Groups%20Code/FriendFunctions.dart';
import 'package:movein/Scroller%20Code/swipe_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movein/Pages/Scroller.dart';
import '../Auth code/auth.dart';
import '../main.dart';


class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  late List<dynamic> friends;
  late List<dynamic> searchResults;
  late List<dynamic> groupInvites;
  late List<dynamic> groupSearchResults;
  late List<dynamic> blockedGroups;
  late List<dynamic> blockedSearchResults;
  late List<dynamic> friendInvites;
  late List<dynamic> friendSearchResults;
  late List<dynamic> outgoingFriendInvites;
  List<dynamic> outgoingFriendInvitesResults = [];
  late List<dynamic> joined;
  late List<dynamic> joinedResults;
  late List<dynamic> applications;
  late List<dynamic> applicationsResults;
  late List<dynamic> shortList;
  late List<dynamic> shortListResults;
  late bool isLoading;
  late bool isSearchLoading;
  late List<dynamic> fSSearchResults;
  bool loadExtra = false;
  String searchText = "";
  final appsMax = 3;

  int stampToYear(var dateTime) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(dateTime);
    final yearsAgo = difference.inDays ~/ 365;
    return yearsAgo;
  }

  Future<List<List<dynamic>>> fetchFriendsData() async {
    List<Map<String,dynamic>> friends = [];
    List<Map<String,dynamic>> groupInvites = [];
    List<Map<String,dynamic>> blockedGroups = [];
    List<Map<String,dynamic>> friendInvites = [];
    List<Map<String,dynamic>> outgoingFriendInvites = [];
    List<dynamic> allGroups = [];

    try {
      for (String type in ["Joined", "Applications", "ShortList"]) {
        List<Map<String, dynamic>> groups = [];
        List<String> tGroups = [];
        final CollectionReference docGroups =
        FirebaseFirestore.instance.collection("Groups");
        final CollectionReference docUsers =
        FirebaseFirestore.instance.collection("Users");


        DocumentSnapshot docSnapshot = await docUsers.doc(Auth().currentUser()).get();
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

        tGroups = List<String>.from(data?[type] ?? []);

        for (var group in tGroups) {
          if (group.isNotEmpty) {
            DocumentSnapshot groupSnapshot = await docGroups.doc(group).get();
            Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;
            if (groupData != null){
              groups.add({
                "Id": group,
                "GroupName": groupData["GroupName"],
                "GroupPicture": groupData["GroupPicture"],
                "Members": groupData["Members"],
                "avgCleanliness" : groupData["AvgCleanliness"],
                "AvgNoisiness" : groupData["AvgNoisiness"],
                "AvgNightLife" : groupData["AvgNightLife"],
                "AvgBedTime" : groupData["AvgBedTime"],
              });
            }
          }
        }

          allGroups.add(groups);
      }
      final usersSnapshot = await FirebaseFirestore.instance.collection('Users').doc(Auth().currentUser()).get();
      final groupIds = List<String>.from(usersSnapshot.data()?['GroupInvites'] ?? []);
        for (String groupId in groupIds){
          final friendSnapshot = await FirebaseFirestore.instance
              .collection('Groups')
              .doc(groupId)
              .get();
          final groupData = friendSnapshot.data();
          if (groupData != null) {
            groupInvites.add({
              "Id": groupId,
              "GroupName": groupData['GroupName'],
              "GroupPicture": groupData['GroupPicture'],
              "Members": groupData['Members'],
            });
          }
        }
      final blockedIds = List<String>.from(usersSnapshot.data()?['BlockedGroups'] ?? []);
        for (String groupId in blockedIds){
          final friendSnapshot = await FirebaseFirestore.instance
              .collection('Groups')
              .doc(groupId)
              .get();
          final groupData = friendSnapshot.data();
          if (groupData != null) {
            blockedGroups.add({
              "Id": groupId,
              "GroupName": groupData['GroupName'],
              "GroupPicture": groupData['GroupPicture'],
              "Members": groupData['Members'],
            });
          }
        }

      final inviteIds = List<String>.from(usersSnapshot.data()?['FriendInvites'] ?? []);
      final friendsIds = List<String>.from(usersSnapshot.data()?['Friends'] ?? []);
      final outgoingIds = List<String>.from(usersSnapshot.data()?['OutgoingFriendInvites'] ?? []);

        for (String inviteId in inviteIds) {
          final friendSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(inviteId)
              .get();
          final friendData = friendSnapshot.data();

          if (friendData != null) {
            int yearsAgo = stampToYear(friendData['DOB'].toDate());
            friendInvites.add({
              "ForeName": friendData['Forename'],
              "SurName": friendData['Surname'],
              "Age": yearsAgo,
              "Uni": friendData['UniAttended'],
              "Preferences": friendData['Preferences'],
              "Images": friendData['Images'],
              "Bio": friendData['Bio'],
              "Subject": friendData['Subject'],
              "YearOfStudy": friendData['YearOfStudy'],
              "Id": inviteId,
            });
          }
        }

      for (String friendId in friendsIds) {
        final friendSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(friendId)
            .get();
        final friendData = friendSnapshot.data();

        if (friendData != null) {
          int yearsAgo = stampToYear(friendData['DOB'].toDate());
          friends.add({
            "ForeName": friendData['Forename'],
            "SurName": friendData['Surname'],
            "Age": yearsAgo,
            "Uni": friendData['UniAttended'],
            "Preferences": friendData['Preferences'],
            "Images": friendData['Images'],
            "Bio": friendData['Bio'],
            "Subject": friendData['Subject'],
            "YearOfStudy": friendData['YearOfStudy'],
            "Id": friendId,
          });
        }
      }

      for (String outgoingId in outgoingIds) {
        final friendSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(outgoingId)
            .get();
        final friendData = friendSnapshot.data();

        if (friendData != null) {
          int yearsAgo = stampToYear(friendData['DOB'].toDate());
          outgoingFriendInvites.add({
            "ForeName": friendData['Forename'],
            "SurName": friendData['Surname'],
            "Age": yearsAgo,
            "Uni": friendData['UniAttended'],
            "Preferences": friendData['Preferences'],
            "Images": friendData['Images'],
            "Bio": friendData['Bio'],
            "Subject": friendData['Subject'],
            "YearOfStudy": friendData['YearOfStudy'],
            "Id": outgoingId,
          });
        }
      }
    } catch (e) {
      throw FirebaseException(
        message: 'Error fetching friends data: $e',
        plugin: 'cloud_firestore',
      );
    }
    return [friends,friendInvites,groupInvites,outgoingFriendInvites, allGroups, blockedGroups];
  }

  Future<List<Friend>> searchUsers(String searchQuery) async {
    List<Friend> retlist = [];
    List<String> parts = searchQuery.toLowerCase().split(' ');

    final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');

    final QuerySnapshot firstnamequery = await userCollection
        .where('Forename', isEqualTo: parts[0])
        .orderBy('Surname')
        .get();

    final QuerySnapshot lastnamequery = await userCollection
        .where('Surname', isEqualTo: (parts.length > 1) ? '${parts[1]}\uf8ff' : '${parts[0]}\uf8ff')
        .get();

    final QuerySnapshot idquery = await userCollection
        .where(FieldPath.documentId, isEqualTo: '$searchQuery\uf8ff')
        .get();

    for (QuerySnapshot sS in [lastnamequery, idquery, firstnamequery]) {
      List<Friend> searched = sS.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Friend(
          profileImg: data['profileImg'],
          name: '${data['Forename']} ${data['Surname']}',
          id: doc.id,
        );
      }).toList();
      retlist.addAll(searched);
    }

    return retlist;
  }


  void filterSearchResults(String query) {
    setState(() {
      loadExtra = false;
      isSearchLoading = true;
      searchResults = friends
          .where((friend) =>
            friend["Id"].toLowerCase().contains(query.toLowerCase()) ||
            '${friend["ForeName"]} ${friend["SurName"]}'.toLowerCase().contains(query.toLowerCase()))
            .toList();

      groupSearchResults = groupInvites
          .where((group) =>
          group["Id"].toLowerCase().contains(query.toLowerCase()) ||
          group["GroupName"].toLowerCase().contains(query.toLowerCase()))
          .toList();

      blockedSearchResults = blockedGroups
          .where((group) =>
      group["Id"].toLowerCase().contains(query.toLowerCase()) ||
          group["GroupName"].toLowerCase().contains(query.toLowerCase()))
          .toList();

      friendSearchResults = friendInvites
          .where((friend) =>
            friend["Id"].toLowerCase().contains(query.toLowerCase()) ||
            '${friend["ForeName"]} ${friend["SurName"]}'.toLowerCase().contains(query.toLowerCase()))
            .toList();

      outgoingFriendInvitesResults = outgoingFriendInvites
          .where((friend) =>
            friend["Id"].toLowerCase().contains(query.toLowerCase()) ||
            '${friend["ForeName"]} ${friend["SurName"]}'.toLowerCase().contains(query.toLowerCase()))
            .toList();

      joinedResults = joined
          .where((group) =>
          group["GroupName"].toLowerCase().contains(query.toLowerCase()) ||
          group["Id"].toLowerCase().contains(query.toLowerCase()))
          .toList();

      applicationsResults = applications
          .where((group) =>
          group["GroupName"].toLowerCase().contains(query.toLowerCase()) ||
          group["Id"].toLowerCase().contains(query.toLowerCase()))
          .toList();

      shortListResults = shortList
          .where((group) =>
          group["GroupName"].toLowerCase().contains(query.toLowerCase()) ||
          group["Id"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchFriendsData().then((data) {
      setState(() {
        friends = data[0];
        searchResults = data[0];
        friendInvites = data[1];
        friendSearchResults = data[1];
        groupInvites = data[2];
        groupSearchResults = data[2];
        outgoingFriendInvites = data[3];
        outgoingFriendInvitesResults = data[3];
        joined = data[4][0];
        joinedResults = data[4][0];
        applications = data[4][1];
        applicationsResults = data[4][1];
        shortList = data[4][2];
        shortListResults = data[4][2];
        blockedGroups = data[5];
        blockedSearchResults = data[5];
        isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final navigator = Navigator.of(context);
        return Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 40,
                      width: double.maxFinite,
                      child: SearchBar(
                        hintText: "search".tr,
                        onChanged: (value) {
                          searchText = value;
                          filterSearchResults(value);
                        },
                        trailing: [
                          IconButton(
                            onPressed: () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => SendFriendInvite(userId: Auth().currentUser(),),
                              );
                            },
                            icon: const Icon(LineAwesomeIcons.user_plus),
                          ),
                        ]
                      ),
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("your_groups".tr, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.left,),
                          Expanded(child: Container()),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                            ),
                            onPressed: () {
                              if (joined.length + applications.length == appsMax){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('max_groups_title'.tr, style: Theme.of(context).textTheme.bodyMedium,),
                                      content: Text('max_groups_desc'.tr, style: Theme.of(context).textTheme.bodySmall),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); // Close the dialog
                                          },
                                          child: Text('ok'.tr, style: Theme.of(context).textTheme.bodyMedium,),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }else{
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
                                  ),
                                  builder: (BuildContext context) {
                                    return const CreateGroupForm(); // Using the extracted widget here
                                  },
                                );
                              }
                            },
                            child: SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('create_group'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                  Icon(LineAwesomeIcons.plus, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoading ? const Center(child: CircularProgressIndicator())
                          : (joinedResults.isEmpty & applicationsResults.isEmpty & shortListResults.isEmpty) ? Padding(padding: const EdgeInsets.all(10), child: Text('no_groups'.tr, style: Theme.of(context).textTheme.bodyMedium,))
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: joinedResults.length + applicationsResults.length + shortListResults.length + 3,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return joinedResults.isEmpty ? const SizedBox(height: 1,)
                            : Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Text(
                                    "joined".tr,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    "${applications.length + joined.length}/$appsMax",
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ]
                            );
                          } else if (index <= joinedResults.length) {
                            int joinedIndex = index - 1;
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/Messages', arguments: {
                                  'members': joinedResults[joinedIndex]["Members"],
                                  'groupId': joinedResults[joinedIndex]["Id"],
                                  'groupName': joinedResults[joinedIndex]["GroupName"],
                                  'groupPicture' : joinedResults[joinedIndex]["GroupPicture"],
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Image.asset(joinedResults[joinedIndex]["GroupPicture"]),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              joinedResults[joinedIndex]["GroupName"],
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/Messages', arguments: {
                                            'members': joinedResults[joinedIndex]["Members"],
                                            'groupId': joinedResults[joinedIndex]["Id"],
                                            'groupName': joinedResults[joinedIndex]["GroupName"],
                                          });
                                        },
                                        splashRadius: 1,
                                        icon: const Icon(Icons.mail),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (index == joinedResults.length + 1) {
                            return applicationsResults.isEmpty ? const SizedBox(height: 1,)
                                : Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Text(
                                    "applications".tr,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ]
                            );
                          } else if (index <= joinedResults.length + applicationsResults.length + 1) {
                            int applicationIndex = index - joinedResults.length - 2;
                            return GestureDetector(
                              onTap: () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => GroupExpand(
                                    id: applicationsResults[applicationIndex]["Id"],
                                    groupName: applicationsResults[applicationIndex]["GroupName"],
                                    groupPicture: applicationsResults[applicationIndex]["GroupPicture"],
                                    members: applicationsResults[applicationIndex]["Members"].cast<String>().toList(),
                                    avgCleanliness: applicationsResults[applicationIndex]["avgCleanliness"],
                                    avgNoisiness: applicationsResults[applicationIndex]["avgNoisiness"],
                                    avgNightLife: applicationsResults[applicationIndex]["avgNightLife"],
                                    avgBedTime: applicationsResults[applicationIndex]["avgBedTime"],
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Image.asset(applicationsResults[applicationIndex]["GroupPicture"]),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              applicationsResults[applicationIndex]["GroupName"],
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) => ConfirmGroupDel(groupId: applicationsResults[applicationIndex]["Id"], groupType: "Applications", userId: Auth().currentUser(),)
                                          );
                                        },
                                        splashRadius: 1,
                                        icon: const Icon(LineAwesomeIcons.trash),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (index == joinedResults.length + applicationsResults.length + 2) {
                            return shortListResults.isEmpty ? const SizedBox(height: 1,)
                                : Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Text(
                                    "sList".tr,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ]
                            );
                          } else {
                            int shortlistIndex = index - joinedResults.length - applicationsResults.length - 3;
                            return GestureDetector(
                              onTap: () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => GroupExpand(
                                    id: shortListResults[shortlistIndex]["Id"],
                                    groupName: shortListResults[shortlistIndex]["GroupName"],
                                    groupPicture: shortListResults[shortlistIndex]["GroupPicture"],
                                    members: shortListResults[shortlistIndex]["Members"].cast<String>().toList(),
                                    avgCleanliness: shortListResults[shortlistIndex]["avgCleanliness"],
                                    avgNoisiness: shortListResults[shortlistIndex]["avgNoisiness"],
                                    avgNightLife: shortListResults[shortlistIndex]["avgNightLife"],
                                    avgBedTime: shortListResults[shortlistIndex]["avgBedTime"],
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Image.asset(shortListResults[shortlistIndex]["GroupPicture"]),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shortListResults[shortlistIndex]["GroupName"],
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) => ConfirmGroupDel(groupId: shortListResults[shortlistIndex]["Id"], groupType: "ShortList", userId: Auth().currentUser(),)
                                          );
                                        },
                                        splashRadius: 1,
                                        icon: const Icon(LineAwesomeIcons.trash),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),

                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text("your_friends".tr, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : searchResults.isEmpty ? Padding(padding: const EdgeInsets.all(10),child: Text("no_friends".tr, style: Theme.of(context).textTheme.bodyMedium,),)
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => CustomDialog(id: searchResults[index]["Id"], foreName: searchResults[index]["ForeName"], age: searchResults[index]["Age"], uni: searchResults[index]["Uni"], preferences: searchResults[index]["Preferences"], images: searchResults[index]["Images"], bio: searchResults[index]["Bio"], subject: searchResults[index]["Subject"], yearOfStudy: searchResults[index]["YearOfStudy"])
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image.asset(searchResults[index]["Images"][0]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${searchResults[index]["ForeName"]} ${searchResults[index]["SurName"]}",
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                              Text(
                                                searchResults[index]["Id"],
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'invite',
                                              child: Text('Invite to Group', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'remove',
                                              child: Text('Remove Friend', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'invite') {
                                              showDialog<String>(
                                                  context: context,
                                                  builder: (BuildContext context) => GroupInvite(inviteeId: searchResults[index]["Id"], userId: Auth().currentUser(),)
                                              );

                                            } else if (value == 'remove') {
                                              showDialog<String>(
                                                  context: context,
                                                  builder: (BuildContext context) => ConfirmDel(friendId: searchResults[index]["Id"])
                                              );
                                              //Navigator.pushReplacementNamed(context, "/Friends"); //Dirty way of rebuilding app.
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                            },
                          ),
                          if (outgoingFriendInvitesResults.isNotEmpty)
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Text('outGoing_friend_invite'.tr, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                            ),
                          if (outgoingFriendInvitesResults.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: outgoingFriendInvitesResults.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => CustomDialog(id: outgoingFriendInvitesResults[index]["Id"], foreName: outgoingFriendInvitesResults[index]["ForeName"], age: outgoingFriendInvitesResults[index]["Age"], uni: outgoingFriendInvitesResults[index]["Uni"], preferences: outgoingFriendInvitesResults[index]["Preferences"], images: outgoingFriendInvitesResults[index]["Images"], bio: outgoingFriendInvitesResults[index]["Bio"], subject: outgoingFriendInvitesResults[index]["Subject"], yearOfStudy: outgoingFriendInvitesResults[index]["YearOfStudy"])
                                    );
                                    },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image.asset(outgoingFriendInvitesResults[index]["Images"][0]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${outgoingFriendInvitesResults[index]['ForeName']} ${outgoingFriendInvitesResults[index]['SurName']}",
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                              Text(
                                                outgoingFriendInvitesResults[index]["Id"],
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'remove',
                                              child: Text('cancel_invite', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'remove') {
                                              await removeOutFriendInvite(outgoingFriendInvitesResults[index]['Id'], Auth().currentUser(),);
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text("invites".tr, style: Theme.of(context).textTheme.headlineMedium),
                  const Divider(),
                  const SizedBox(height: 15),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text("group_invites".tr, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : groupSearchResults.isEmpty ? Padding(padding: const EdgeInsets.all(10),child: Text("no_group_invites".tr, style: Theme.of(context).textTheme.bodyMedium,),)
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: groupSearchResults.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => GroupExpand(
                                          id: groupSearchResults[index]["Id"],
                                          groupName: groupSearchResults[index]["GroupName"],
                                          groupPicture: groupSearchResults[index]["GroupPicture"],
                                          members: groupSearchResults[index]["Members"].cast<String>().toList(),
                                          avgCleanliness: groupSearchResults[index]["avgCleanliness"],
                                          avgNoisiness: groupSearchResults[index]["avgNoisiness"],
                                          avgNightLife: groupSearchResults[index]["avgNightLife"],
                                          avgBedTime: groupSearchResults[index]["avgBedTime"],
                                      )
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image.asset(groupSearchResults[index]["GroupPicture"]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                groupSearchResults[index]["GroupName"],
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'accept',
                                              child: Text('apply_to_group'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'reject',
                                              child: Text('reject_group'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async{
                                            if (value == 'accept') {
                                              await joinGroup(groupSearchResults[index]["Id"], Auth().currentUser());
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            } else if (value == 'reject') {
                                              await removeGroupInvite(groupSearchResults[index]["Id"], Auth().currentUser(),);
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text("friend_invites".tr, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : friendSearchResults.isEmpty ? Padding(padding: const EdgeInsets.all(10), child: Text("no_friend_invites".tr, style: Theme.of(context).textTheme.bodyMedium,))
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: friendSearchResults.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => CustomDialog(id: friendSearchResults[index]["Id"], foreName: friendSearchResults[index]["ForeName"], age: friendSearchResults[index]["Age"], uni: friendSearchResults[index]["Uni"], preferences: friendSearchResults[index]["Preferences"], images: friendSearchResults[index]["Images"], bio: friendSearchResults[index]["Bio"], subject: friendSearchResults[index]["Subject"], yearOfStudy: friendSearchResults[index]["YearOfStudy"])
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image.asset(friendSearchResults[index]["Images"][0]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${friendSearchResults[index]['ForeName']} ${friendSearchResults[index]['SurName']}",
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'accept',
                                              child: Text('accept_friend'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'reject',
                                              child: Text('reject_friend', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async{
                                            if (value == 'accept') {
                                              await addFriend(friendSearchResults[index]["Id"], Auth().currentUser(),);
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            } else if (value == 'reject') {
                                              await removeFriendInvite(friendSearchResults[index]["Id"], Auth().currentUser(),);
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Blocked Groups".tr, style: Theme.of(context).textTheme.headlineMedium),
                  const Divider(),
                  const SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (App.themeNotifier.value == ThemeMode.dark)? Theme.of(context).primaryColor : Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : blockedSearchResults.isEmpty ? Padding(padding: const EdgeInsets.all(10),child: Text("no-blocked-groups".tr, style: Theme.of(context).textTheme.bodyMedium,),)
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: blockedSearchResults.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => GroupExpand(
                                        id: blockedSearchResults[index]["Id"],
                                        groupName: blockedSearchResults[index]["GroupName"],
                                        groupPicture: blockedSearchResults[index]["GroupPicture"],
                                        members: blockedSearchResults[index]["Members"].cast<String>().toList(),
                                        avgCleanliness: blockedSearchResults[index]["avgCleanliness"],
                                        avgNoisiness: blockedSearchResults[index]["avgNoisiness"],
                                        avgNightLife: blockedSearchResults[index]["avgNightLife"],
                                        avgBedTime: blockedSearchResults[index]["avgBedTime"],
                                      )
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
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
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Image.asset(blockedSearchResults[index]["GroupPicture"]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                blockedSearchResults[index]["GroupName"],
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'unblock',
                                              child: Text('unblock'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'unblock-sList',
                                              child: Text('unblock-sList'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'unblock-apply',
                                              child: Text('unblock-apply'.tr, style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async{
                                            if (value == 'unblock') {
                                              await joinGroup(blockedSearchResults[index]["Id"], Auth().currentUser());
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            } else if(value == 'unblock-sList'){
                                              await unblock(blockedSearchResults[index]["Id"], value, Auth().currentUser());
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            } else if(value == 'unblock-apply'){
                                              await unblock(blockedSearchResults[index]["Id"], value, Auth().currentUser());
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            }
                                          },
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

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
}

class Friend {
  final String profileImg;
  final String name;
  final String id;

  const Friend({
    required this.profileImg,
    required this.name,
    required this.id,
  });
}

Future<void> unblock(String groupId, String value, String currentUser) async {
  try {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .update({
      'BlockedGroups': FieldValue.arrayRemove([groupId])
    });
  } catch (e) {
    throw FirebaseException(
        message: 'Error removing from BlockedGroups": $e',
        plugin: 'cloud_firestore',
    );
  }
  if(value == 'unblock-sList'){
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .update({
      'ShortList': FieldValue.arrayUnion([groupId])
    });
  } else{
    addToApplicants(groupId);
  }
}
