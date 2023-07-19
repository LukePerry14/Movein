import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/navbar.dart';
import 'package:movein/FriendFunctions.dart';
import 'package:movein/swipe_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final String userId = 'iKxLSxcDqlT6vtHe71Bp';
  late List<dynamic> friends;
  late List<dynamic> searchResults;
  late List<dynamic> groupInvites;
  late List<dynamic> groupSearchResults;
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


        DocumentSnapshot docSnapshot = await docUsers.doc(userId).get();
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

        tGroups = List<String>.from(data?[type] ?? []);

        for (var group in tGroups) {
          if (group is String && group.isNotEmpty) {
            DocumentSnapshot groupSnapshot = await docGroups.doc(group).get();
            Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;
            if (groupData != null){
              groups.add({
                "Id": group,
                "GroupName": groupData["GroupName"],
                "GroupPicture": groupData["GroupPicture"],
                "Members": groupData["Members"],
              });
            }
          }
        }

          allGroups.add(groups);
      }
      final usersSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      final groupIds = List<String>.from(usersSnapshot.data()?['GroupInvites'] ?? []);

      if (!groupIds.contains("")){
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
    return [friends,friendInvites,groupInvites,outgoingFriendInvites, allGroups];
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

  void searchMore() async {
    setState(() {
      loadExtra = true;
      isSearchLoading = true;
    });

    List<Friend> results = await searchUsers(searchText);

    setState(() {
      fSSearchResults = results;
      isSearchLoading = false;
    });
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
                        hintText: "Search",
                        onChanged: (value) {
                          searchText = value;
                          filterSearchResults(value);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                          children: [
                            Text("My Groups", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,),
                            const SizedBox(width: 15),
                            isLoading? const Text("")
                                : Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Applied: ${applications.length + joined.length}/$appsMax",
                                  style: Theme.of(context).textTheme.bodyLarge,
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
                        color: Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoading ? const Center(child: CircularProgressIndicator())
                          : (joinedResults.isEmpty & applicationsResults.isEmpty & shortListResults.isEmpty) ? Text("No Groups", style: Theme.of(context).textTheme.bodyMedium,)
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
                                    "Joined",
                                    style: Theme.of(context).textTheme.headlineSmall,
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
                                    "Applications",
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
                                            builder: (BuildContext context) => ConfirmGroupDel(groupId: applicationsResults[applicationIndex]["Id"], groupType: "Applications")
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
                                    "ShortList",
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
                                              builder: (BuildContext context) => ConfirmGroupDel(groupId: shortListResults[shortlistIndex]["Id"], groupType: "ShortList")
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
                  ////////////////////////////////////////////////////////////////////
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text("Your Friends", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : searchResults.isEmpty ? Text("No Friends", style: Theme.of(context).textTheme.bodyMedium,)
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
                                                  builder: (BuildContext context) => GroupInvite(inviteeId: searchResults[index]["Id"])
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
                                child: Text("OutGoing Friend Invites", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
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
                                              child: Text('Cancel invite', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'remove') {
                                              await removeOutFriendInvite(outgoingFriendInvitesResults[index]['Id']);
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
                  Text("Invites", style: Theme.of(context).textTheme.headlineMedium),
                  const Divider(),
                  const SizedBox(height: 15),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text("Group Invites", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : groupSearchResults.isEmpty ? Text("No Group Invites", style: Theme.of(context).textTheme.bodyMedium,)
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: groupSearchResults.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => GroupExpand(id: groupSearchResults[index]["Id"], groupName: groupSearchResults[index]["GroupName"], groupPicture: groupSearchResults[index]["GroupPicture"], members: groupSearchResults[index]["Members"].cast<String>().toList())
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
                                              child: Text('Apply to group', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'reject',
                                              child: Text('Reject group', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async{
                                            if (value == 'accept') {
                                              await joinGroup(groupSearchResults[index]["Id"]);
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            } else if (value == 'reject') {
                                              await removeGroupInvite(groupSearchResults[index]["Id"]);
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
                      child: Text("Friend Invites", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          isLoading ? const Center(child: CircularProgressIndicator())
                              : friendSearchResults.isEmpty ? Text("No Friend Invites", style: Theme.of(context).textTheme.bodyMedium,)
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
                                              child: Text('Accept Friend', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'reject',
                                              child: Text('Reject Friend', style: Theme.of(context).textTheme.bodyMedium),
                                            ),
                                          ],
                                          onSelected: (value) async{
                                            if (value == 'accept') {
                                              await addFriend(friendSearchResults[index]["Id"]);
                                              Navigator.of(context).pushReplacementNamed("/Friends");
                                            } else if (value == 'reject') {
                                              await removeFriendInvite(friendSearchResults[index]["Id"]);
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