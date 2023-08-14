import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/Scroller%20Code/HScroll.dart';
import 'dart:io';
//import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


Future<List<Map<String, dynamic>>> getUserJoinedGroups(userId) async {
  try {
    final usersCollectionRef = FirebaseFirestore.instance.collection('Users');
    final userDocRef = usersCollectionRef.doc(userId);

    final userSnapshot = await userDocRef.get();
    final joinedGroups = userSnapshot.data()?['Joined'] as List<dynamic>;

    final groupsCollectionRef = FirebaseFirestore.instance.collection('Groups');
    final groupsSnapshot = await groupsCollectionRef.get();

    final List<Map<String, dynamic>> result = [];
    for (var groupDoc in groupsSnapshot.docs) {
      if (joinedGroups.contains(groupDoc.id)) {
        final groupData = groupDoc.data();
        final groupName = groupData['GroupName'] as String;
        final memberIds = groupData['Members'] as List<dynamic>;
        final documentId = groupDoc.id;

        final List<String> memberForeNames = [];
        for (var memberId in memberIds) {
          final memberDoc = await usersCollectionRef.doc(memberId).get();
          final memberForeName = memberDoc.data()?['Forename'] as String;
          memberForeNames.add(memberForeName);
        }

        result.add({
          'GroupName': groupName,
          'Members': memberForeNames,
          'Id': documentId,
        });
      }
    }

    return result;
  }  catch (e) {
    throw FirebaseException(
      message: 'Error getting groups for invite: $e',
      plugin: 'cloud_firestore',
    );
  }
}

class GroupInvite extends StatelessWidget {
  final String inviteeId;
  final String userId;
  const GroupInvite({
    Key? key,
    required this.inviteeId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getUserJoinedGroups(userId),
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
          List<dynamic> data = snapshot.data!;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Theme.of(context).canvasColor,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      splashRadius: 5,
                      icon: const Icon(LineAwesomeIcons.times_circle),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Column(
                    children: [
                      Text("Invite to group:", style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: SizedBox(
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(data[index]['GroupName'], style: Theme.of(context).textTheme.bodyMedium),
                                subtitle: Text(
                                    data[index]?["Members"]!.join(', '),
                                    style: Theme.of(context).textTheme.bodySmall),
                                onTap: () {
                                  inviteFriendToGroup(inviteeId, data[index]?["Id"], userId);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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

class ConfirmDel extends StatelessWidget {
  final String friendId;
  const ConfirmDel({
    Key? key,
    required this.friendId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      backgroundColor: Theme.of(context).canvasColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.3,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Are you sure you want to delete friend?", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel", style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        removeFriend(friendId).then((_){
                          Navigator.of(context).pushReplacementNamed('/Friends');
                        });

                      },
                      child: Text("Confirm", style: Theme.of(context).textTheme.bodyMedium)
                  ),
                ),

              ],
            )
          ],
        ),
      ),

    );
  }
}

Future<void> removeFriend(String friendId) async{
  const userId = "iKxLSxcDqlT6vtHe71Bp";
  final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);

  try {
    final userDoc = await userRef.get();
    if (userDoc.exists) {
      final List<dynamic>? friends = userDoc.data()?['Friends'];

      if (friends != null && friends.contains(friendId)) {
        friends.remove(friendId);
        await userRef.update({'Friends': friends});
      }
    }
  } catch (e) {
    throw FirebaseException(message: 'Error removing friend: $e', plugin: 'cloud_firestore');
  }
}

Future<void> inviteFriendToGroup(String friendId, String groupId, userId) async {
  try {
    final DocumentReference groupRef = FirebaseFirestore.instance.collection('Groups').doc(groupId);
    final DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(friendId);

    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await groupRef.get() as DocumentSnapshot<Map<String, dynamic>>;
    final List<String> members = List<String>.from(groupSnapshot.data()!['Members']);

    if (!members.contains(friendId)) {
      await userRef.update({'GroupInvites': FieldValue.arrayUnion([groupId])});
    }

    // Update Kicks field in the group's document
    await groupRef.update({
      'Applicants': FieldValue.arrayUnion([friendId]),
    });
    //final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await FirebaseFirestore.instance.collection('Groups').doc(groupId).get();
    final Map<String, dynamic>? appVals = groupSnapshot.data()?['AppVals'];

    if (appVals != null) {
      // Update the KickVals field with the new key-value pair
      appVals[friendId] = {userId: 1};
      await groupRef.update({'AppVals': appVals});
    }

  } catch (e) {
    throw FirebaseException(message: 'Error Inviting friend: $e', plugin: 'cloud_firestore');
  }
}

class GroupExpand extends StatelessWidget {
  final String id;
  final String groupName;
  final String groupPicture;
  final dynamic members;
  final double avgCleanliness;
  final double avgNoisiness;
  final double avgNightLife;
  final Timestamp avgBedTime;

  const GroupExpand({
    Key? key,
    required this.id,
    required this.groupName,
    required this.groupPicture,
    required this.members,
    required this.avgCleanliness,
    required this.avgNoisiness,
    required this.avgNightLife,
    required this.avgBedTime,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        //padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Gscroller(groupName: groupName, groupPicture: groupPicture, members: members, avgCleanliness: avgCleanliness, avgNoisiness: avgNoisiness, avgNightLife: avgNightLife, avgBedTime: avgBedTime,)
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(LineAwesomeIcons.times_circle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ),
          ],
        ),
      ),
    );
  }
}

Future<void> joinGroup(String groupId, String userId) async {
  try {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
    final DocumentReference userDoc = usersCollection.doc(userId);

    // Update user's "Applications" and remove from "GroupInvites"
    await userDoc.update({
      'Applications': FieldValue.arrayUnion([groupId]),
      'GroupInvites': FieldValue.arrayRemove([groupId]),
      'Joined' : FieldValue.arrayUnion([groupId]),
    });

    final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('Groups');
    final DocumentReference groupDoc = groupsCollection.doc(groupId);

    // Get the group document to access the average fields
    final DocumentSnapshot groupSnapshot = await groupDoc.get();

    // Get the group size from the 'Members' array field
    final List<dynamic> members = groupSnapshot.get('Members');
    int groupSize = members.length;

    // Calculate the new average values
    double avgCleanliness = groupSnapshot.get('AvgCleanliness');
    double avgNightLife = groupSnapshot.get('AvgNightLife');
    double avgNoisiness = groupSnapshot.get('AvgNoisiness');
    DateTime avgBedTime = groupSnapshot.get('AvgBedTime').toDate();

    // Get the user document of the current user
    final DocumentSnapshot userSnapshot = await userDoc.get();

    // Get the 'Preferences' map field from the user document
    final Map<String, dynamic> prefs = userSnapshot.get('Preferences');

    // Get the corresponding fields from the user document
    double userCleanliness = prefs['Cleanliness'];
    double userNightLife = prefs['NightLife'];
    double userNoisiness = prefs['Noisiness'];
    DateTime userBedTime = prefs['BedTime'].toDate();

    // Calculate the new average values after adding the user to the group
    avgCleanliness = (avgCleanliness * groupSize + userCleanliness) / (groupSize + 1);
    avgNightLife = (avgNightLife * groupSize + userNightLife) / (groupSize + 1);
    avgNoisiness = (avgNoisiness * groupSize + userNoisiness) / (groupSize + 1);

    // Calculate the new average bed time after adding the user to the group
    int totalBedTimeInMilliseconds = avgBedTime.millisecondsSinceEpoch * groupSize;
    totalBedTimeInMilliseconds += userBedTime.millisecondsSinceEpoch;
    avgBedTime = DateTime.fromMillisecondsSinceEpoch(totalBedTimeInMilliseconds ~/ (groupSize + 1));

    // Convert the average bedtime back to a Timestamp format
    final Timestamp avgBedTimeTimestamp = Timestamp.fromDate(avgBedTime);

    // Update the group document with the new average values and add the user to the 'Members' array
    await groupDoc.update({
      'AvgCleanliness': avgCleanliness,
      'AvgNightLife': avgNightLife,
      'AvgNoisiness': avgNoisiness,
      'AvgBedTime': avgBedTimeTimestamp,
      'Members': FieldValue.arrayUnion([userId]),
    });
  } catch (e) {
    throw FirebaseException(
      message: 'Error joining group: $e',
      plugin: 'cloud_firestore',
    );
  }
}


Future<void> removeGroupInvite(String groupId, userId) async {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final DocumentReference userDoc = usersCollection.doc(userId);

  // Remove groupId from GroupInvites field
  await userDoc.update({
    'GroupInvites': FieldValue.arrayRemove([groupId]),
  });
}

Future<void> addFriend(String inviteId, userId) async {
  // Access the "Users" collection
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  // Perform array union on the "Friends" field of inviteId document
  await usersCollection
      .doc(inviteId)
      .update({'Friends': FieldValue.arrayUnion([userId])});

  // Perform array union on the "Friends" field of userId document
  await usersCollection
      .doc(userId)
      .update({'Friends': FieldValue.arrayUnion([inviteId])});

  removeFriendInvite(inviteId, userId);
}

Future<void> removeFriendInvite(String inviteId, userId) async {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  try {
    // Remove inviteId from FriendInvites field in the user's document
    await usersCollection
        .doc(userId)
        .update({'FriendInvites': FieldValue.arrayRemove([inviteId])});

    // Remove userId from OutgoingFriendInvites field in the invitee's document
    await usersCollection
        .doc(inviteId)
        .update({'OutgoingFriendInvites': FieldValue.arrayRemove([userId])});

    // Success!
  } catch (e) {
    // Error occurred
    throw FirebaseException(
        message: 'Error removing friend invite: $e',
        plugin: 'cloud_firestore');
  }
}

Future<void> removeOutFriendInvite(String inviteId, userId) async {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Users');

  try {
    // Remove inviteId from FriendInvites field in the user's document
    await usersCollection
        .doc(inviteId)
        .update({'FriendInvites': FieldValue.arrayRemove([userId])});

    // Remove userId from OutgoingFriendInvites field in the invitee's document
    await usersCollection
        .doc(userId)
        .update({'OutgoingFriendInvites': FieldValue.arrayRemove([inviteId])});

    // Success!
  } catch (e) {
    // Error occurred
    throw FirebaseException(
        message: 'Error removing friend invite: $e',
        plugin: 'cloud_firestore');
  }
}

Future<void> sendFriendInvite(String invitee, userId) async {
  try {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

    // Get the user document of the invitee
    DocumentSnapshot inviteeSnapshot = await usersCollection.doc(invitee).get();

    // Check if the invitee document exists
    if (inviteeSnapshot.exists) {
      DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();
      List<dynamic> friendList = userSnapshot.get('Friends');
      if (!friendList.contains(invitee)) {
        await usersCollection.doc(invitee).update({
          'FriendInvites': FieldValue.arrayUnion([userId])
        });

        // Update OutgoingFriendInvites field in the user's document
        await usersCollection.doc(userId).update({
          'OutgoingFriendInvites': FieldValue.arrayUnion([invitee])
        });
      }
    }
  } catch (e) {
    // Error occurred
    throw FirebaseException(message: 'Error sending friend invite: $e', plugin: 'cloud_firestore');
  }
}

class ConfirmGroupDel extends StatelessWidget {
  final String groupId;
  final String groupType;
  final String userId;
  const ConfirmGroupDel({
    Key? key,
    required this.groupId,
    required this.groupType,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.3,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("If you remove the group you can not undo this action without reapplying", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel", style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        removeGroupFromUser(groupType, groupId, userId).then((_){
                          Navigator.of(context).pushReplacementNamed('/Friends');
                        });

                      },
                      child: Text("Confirm", style: Theme.of(context).textTheme.bodyMedium)
                  ),
                ),

              ],
            )
          ],
        ),
      ),

    );
  }
}

Future<void> removeGroupFromUser(String groupType, String groupId, userId) async {
  try {
    final DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final DocumentReference groupRef = FirebaseFirestore.instance.collection('Groups').doc(groupId);

    await userRef.update({
      groupType: FieldValue.arrayRemove([groupId]),
    });

    if (groupType == "Applications") {
      final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await groupRef.get() as DocumentSnapshot<Map<String, dynamic>>;
      final appVals = groupSnapshot.data()?['AppVals'];

      if (appVals != null && appVals.containsKey(userId)) {
        appVals.remove(userId); // Remove the key-value pair from the map

        await groupRef.update({
          'BlackList': FieldValue.arrayRemove([userId]),
          'Applicants': FieldValue.arrayRemove([userId]),
          'AppVals': appVals, // Update the AppVals map without the removed key
        });
      }
    }
  } catch (e) {
    throw FirebaseException(
      message: 'Error removing group from user: $e',
      plugin: 'cloud_firestore',
    );
  }
}


class CreateGroupForm extends StatefulWidget {
  const CreateGroupForm({Key? key}) : super(key: key);

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  final TextEditingController _groupNameController = TextEditingController(text: "GroupName");
  File? _selectedImage;
  final String userId = "iKxLSxcDqlT6vtHe71Bp";


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String groupName = _groupNameController.text;

      // const String dummyUrl = 'https://example.com/upload';
      // final Uri uri = Uri.parse(dummyUrl);
      //
      // final request = http.MultipartRequest('POST', uri)
      //   ..files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      //
      // final response = await request.send();
      // final groupPicture = await response.stream.bytesToString();

      final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('Groups');
      final DocumentReference userDocument = FirebaseFirestore.instance.collection('Users').doc(userId);
      final DocumentSnapshot userSnapshot = await userDocument.get();
      final Map<String,dynamic> prefs = userSnapshot.get('Preferences');
      List<String> allowedUnis = [userSnapshot.get('UniAttended')];
      Map<String, dynamic> appVals = {};
      List<String> applicants = [];
      var avgBedTime = prefs['Lights Out'];
      int avgCleanliness = prefs['Cleanliness'];
      int avgNightLife = prefs['NightLife'];
      int avgNoisiness = prefs['Noisiness'];
      List<String> blackList = [userId];
      List<String> invitees = [];
      Map<String, dynamic> kickVals = {};
      List<String> kicks = [];
      List<String> members = [userId];

      final newGroupDocument = await groupsCollection.add({
        'AllowedUnis': allowedUnis,
        'AppVals': appVals,
        'Applicants': applicants,
        'AvgBedTime': avgBedTime,
        'AvgCleanliness': avgCleanliness,
        'AvgNightLife': avgNightLife,
        'AvgNoisiness': avgNoisiness,
        'BlackList': blackList,
        'GroupName': groupName,
        'GroupPicture': "assets/Pictures/ph.png",
        'Invitees': invitees,
        'KickVals': kickVals,
        'Kicks': kicks,
        'Members': members,
      });
      await userDocument.update({
        'Joined': FieldValue.arrayUnion([newGroupDocument.id]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            height: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20), // Sets the radius for the left corner
                  right: Radius.circular(20), // Sets the radius for the right corner
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(width: MediaQuery.of(context).size.width,child: Text("Create Group", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.start,),),
          Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            onChanged: () {
              setState(() {
                _isButtonEnabled = _formKey.currentState?.validate() ?? false;
              });
            },
            child: Column(
              children: [
                TextFormField(
                  controller: _groupNameController,
                  maxLength: 15,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Change Groupname',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Group name must exist';
                    }
                    return null;
                  },
                  onTap: () {
                    // Select the whole text when tapped
                    _groupNameController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _groupNameController.text.length,
                    );
                  },
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isButtonEnabled
                ? () async {
              if (_formKey.currentState?.validate() ?? false) {
                await _submitForm().then((value) => Navigator.of(context).pushReplacementNamed('/Friends'));
              }
            }
                : null,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class SendFriendInvite extends StatefulWidget {
  final String userId;
  const SendFriendInvite({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SendFriendInvite> createState() => _SendFriendInviteState();
}

class _SendFriendInviteState extends State<SendFriendInvite> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }
  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.3,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Add friend by ID", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            Text("You can find this in the profile section", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),

            Form(
              autovalidateMode: AutovalidateMode.always,
              key: formKey,
              onChanged: () {
                setState(() {
                  _isButtonEnabled = formKey.currentState?.validate() ?? false;
                });
              },
              child: TextFormField(
                controller: _textEditingController,
                maxLength: 20,
                autocorrect: false,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter Friend Id',
                ),
                validator: (value) {
                  if (value?.length != 28) {
                  return 'Friend Id must have exactly 28 characters';
                  }
                  return null;
                },
                onTap: () {
                  // Select the whole text when tapped
                  _textEditingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _textEditingController.text.length,
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel", style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ?  () {
                      if (formKey.currentState!.validate()) {
                        final String inviteeId = _textEditingController.text;
                        sendFriendInvite(inviteeId, widget.userId).then((value) => Navigator.of(context).pushReplacementNamed('/Friends'));
                      }
                    } : null,
                    child: Text("Confirm", style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
