import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class GroupInvite extends StatelessWidget {
  final String inviteeId;
  const GroupInvite({
    Key? key,
    required this.inviteeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String,Map<String,dynamic>> groups = {"tess1": {"members":["1","2","3","4"], "id": "lElVetvnmcnyxSmWhjLb"},"tes2":{"members":["1","2","3","4"], "id": "lElVetvnmcnyxSmWhjLb"},"tes3":{"members":["1","2","3","4"], "id": "lElVetvnmcnyxSmWhjLb"},"tes4":{"members":["1","2","3","4"], "id": "lElVetvnmcnyxSmWhjLb"},"tes5":{"members":["1","2","3","4"], "id": "lElVetvnmcnyxSmWhjLb"}};
    final List<String> keys = groups.keys.toList();
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
                    itemCount: groups.length,
                    itemBuilder: (context, index){

                      return ListTile(
                        title: Text(keys[index], style: Theme.of(context).textTheme.bodyMedium),
                        subtitle: Text(groups[keys[index]]?["members"]!.join(', '), style: Theme.of(context).textTheme.bodySmall),
                        onTap: (){
                          inviteFriendToGroup(inviteeId, groups[keys[index]]?["id"]);
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
            Text("Are you sure you want to delete friend?", style: Theme.of(context).textTheme.bodyLarge),
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
                          Navigator.of(context).pop();
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
    final DocumentReference groupRef =
    FirebaseFirestore.instance.collection('Groups').doc(groupId);

    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot =
    await groupRef.get() as DocumentSnapshot<Map<String, dynamic>>;
    final List<String> members =
    List<String>.from(groupSnapshot.data()!['Members']);

    if (!members.contains(friendId)) {
      await groupRef.update({'Invitees': FieldValue.arrayUnion([friendId])});
    }
  } catch (e) {
    throw FirebaseException(message: 'Error Inviting friend: $e', plugin: 'cloud_firestore');
  }
}