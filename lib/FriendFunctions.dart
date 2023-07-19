import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/HScroll.dart';

const String userId = "iKxLSxcDqlT6vtHe71Bp";

Future<List<Map<String, dynamic>>> getUserJoinedGroups() async {
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
  const GroupInvite({
    Key? key,
    required this.inviteeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getUserJoinedGroups(),
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
                                  inviteFriendToGroup(inviteeId, data[index]?["Id"]);
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

Future<void> inviteFriendToGroup(String friendId, String groupId) async {
  try {
    final DocumentReference groupRef = FirebaseFirestore.instance.collection('Groups').doc(groupId);
    final DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(friendId);

    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await groupRef.get() as DocumentSnapshot<Map<String, dynamic>>;
    final List<String> members = List<String>.from(groupSnapshot.data()!['Members']);

    if (!members.contains(friendId)) {
      await userRef.update({'GroupInvites': FieldValue.arrayUnion([groupId])});
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

  const GroupExpand({
    Key? key,
    required this.id,
    required this.groupName,
    required this.groupPicture,
    required this.members,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        height: MediaQuery.of(context).size.height * 0.98,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height,
              child: Gscroller(groupName: groupName, groupPicture: groupPicture, members: members)
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

Future<void> joinGroup(String groupId) async {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final DocumentReference userDoc = usersCollection.doc(userId);

  // Update user's "Applications" and remove from "GroupInvites"
  await userDoc.update({
    'Applications': FieldValue.arrayUnion([groupId]),
    'GroupInvites': FieldValue.arrayRemove([groupId]),
  });

  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('Groups');
  final DocumentReference groupDoc = groupsCollection.doc(groupId);

  // Update group's "Applicants"
  await groupDoc.update({
    'Applicants': FieldValue.arrayUnion([userId]),
  });
}

Future<void> removeGroupInvite(String groupId) async {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final DocumentReference userDoc = usersCollection.doc(userId);

  // Remove groupId from GroupInvites field
  await userDoc.update({
    'GroupInvites': FieldValue.arrayRemove([groupId]),
  });
}

Future<void> addFriend(String inviteId) async {
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

  removeFriendInvite(inviteId);
}

Future<void> removeFriendInvite(String inviteId) async {
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

Future<void> removeOutFriendInvite(String inviteId) async {
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

Future<void> sendFriendInvite(String invitee) async {

  try {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

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

    // Success!
  } catch (e) {
    // Error occurred
    throw FirebaseException(message: 'Error sending friend invite: $e', plugin: 'cloud_firestore');
  }
}

Future<void> kickUser(String kickId, String groupId) async {
  try {
    final CollectionReference groupsCollection =
    FirebaseFirestore.instance.collection('Groups');

    // Access the group's document
    final DocumentReference groupDocRef = groupsCollection.doc(groupId);

    // Update Kicks field in the group's document
    await groupDocRef.update({
      'Kicks': FieldValue.arrayUnion([kickId]),
    });
    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await FirebaseFirestore.instance.collection('Groups').doc(groupId).get();
    final Map<String, dynamic>? kickVals = groupSnapshot.data()?['KickVals'];

    if (kickVals != null) {
      // Update the KickVals field with the new key-value pair
      kickVals[kickId] = {userId: 1};
      await groupDocRef.update({'KickVals': kickVals});
    }

  } catch (e) {
    throw FirebaseException(
      message: 'Error kicking user: $e',
      plugin: 'cloud_firestore',
    );
  }
}

Future<void> isKickVotesThresholdReached(
    String groupId, String kickId, int groupSize) async {
  try {
    final DocumentReference groupRef =
    FirebaseFirestore.instance.collection('Groups').doc(groupId);

    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await FirebaseFirestore.instance.collection('Groups').doc(groupId).get();


    final Map<String, dynamic>? kickVals = groupSnapshot.data()?['KickVals'];

    if (kickVals != null && kickVals.containsKey(kickId)) {
      final Map<String, dynamic>? kickVotes =
      kickVals[kickId] as Map<String, dynamic>?;

      if (kickVotes != null) {
        int posSum = 0;
        int negSum = 0;
        kickVotes.forEach((key, value) {
          if (value is int) {
            if (value > 0) {
              posSum += value;
            } else {
              negSum += value;
            }
          }
        });

        if ((posSum > groupSize / 2) | (negSum.abs() >= groupSize / 2)) {
          if (posSum > groupSize / 2) {
            await groupRef.update({
              'Members': FieldValue.arrayRemove([kickId])
            });
          }
          // Remove kickId from 'Kicks' array field
          await groupRef.update({
            'Kicks': FieldValue.arrayRemove([kickId])
          });

          // Remove key-value pair with key kickId from 'KickVals' map field
          kickVals.remove(kickId);
          await groupRef.update({'KickVals': kickVals});
          // Remove kickId from 'Kicks' array field
        }
      }
    }
  } catch (e) {
    // Error occurred
    throw FirebaseException(
      message: 'Error checking kick votes threshold: $e',
      plugin: 'cloud_firestore',
    );
  }
}

Future<void> updateKickVote(String groupId, bool agree, String kickId, int groupSize) async {
  try {
    final DocumentReference groupRef = FirebaseFirestore.instance.collection('Groups').doc(groupId);


    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await FirebaseFirestore.instance.collection('Groups').doc(groupId).get();

    final kickVals = groupSnapshot.data()?['KickVals'];


    if (kickVals != null && kickVals.containsKey(kickId)) {
      final Map<String, dynamic>? kickVotes = kickVals[kickId] as Map<String, dynamic>?;

      if (kickVotes != null) {
          int vote = agree ? 1 : -1;
          kickVotes[userId] = vote;

        await groupRef.update({'KickVals.$kickId': kickVotes});
      }
    }
    await isKickVotesThresholdReached(groupId,kickId,groupSize);
  } catch (e) {
    throw FirebaseException(
      message: 'Error updating kick vote: $e',
      plugin: 'cloud_firestore',
    );
  }
}







