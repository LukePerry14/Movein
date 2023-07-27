import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String userId = "iKxLSxcDqlT6vtHe71Bp";

Future<void> updateGroupName(String newName, String groupId) async {
  try {
    final collectionRef = FirebaseFirestore.instance.collection('Groups');
    final documentRef = collectionRef.doc(groupId);

    await documentRef.update({
      'GroupName': newName,
    });

  } catch (e) {
    throw FirebaseException(
      message: 'Error updating group Name: $e',
      plugin: 'cloud_firestore',
    );
  }
}

Future<void> removeFromGroupAndUser(String groupId) async {
  try {
    // Access the "Groups" collection and remove the userId from the "Members" array
    final groupsCollectionRef = FirebaseFirestore.instance.collection('Groups');
    final groupDocRef = groupsCollectionRef.doc(groupId);
    await groupDocRef.update({
      'Members': FieldValue.arrayRemove([userId]),
    });


    final usersCollectionRef = FirebaseFirestore.instance.collection('Users');
    final userDocRef = usersCollectionRef.doc(userId);
    await userDocRef.update({
      'Joined': FieldValue.arrayRemove([groupId]),
    });


  } catch (e) {
    throw FirebaseException(
      message: 'Error leaving group: $e',
      plugin: 'cloud_firestore',
    );
  }
}

class EditGroupName extends StatefulWidget {
  final String name;
  final String groupId;
  const EditGroupName({
    Key? key,
    required this.name,
    required this.groupId,
  }) : super(key: key);

  @override
  State<EditGroupName> createState() => _EditGroupNameState();
}

class _EditGroupNameState extends State<EditGroupName> {
  late final TextEditingController _textEditingController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.name);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: formKey,
                onChanged: () {
                  setState(() {
                    _isButtonEnabled = formKey.currentState?.validate() ?? false;
                  });
                },
                child: TextFormField(
                  controller: _textEditingController,
                  maxLength: 15,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Change Group name',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Group name must exist';
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
                        final String newName = _textEditingController.text;
                        updateGroupName(newName, widget.groupId).then((value) => Navigator.of(context).pop());
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


class ConfirmLeave extends StatelessWidget {
  final String groupId;
  const ConfirmLeave({
    Key? key,
    required this.groupId,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text("Are you sure you want to leave?", style: Theme.of(context).textTheme.bodyLarge,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text("This will remove you from the group and make you unable to contact any members you aren't already friends with. You will still be able to rejoin the group.", style: Theme.of(context).textTheme.bodySmall,),
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
                      onPressed: () {
                        removeFromGroupAndUser(groupId).then((_) {
                          Navigator.of(context).pushReplacementNamed('/Groups');
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
