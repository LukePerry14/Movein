import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Themes/lMode.dart';
import '../Auth code/auth.dart';
import 'GroupOptions.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Map data = {};
  var groupId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    data = ModalRoute.of(context)?.settings.arguments as Map;
  }

  Stream<List<dynamic>> getMessagesStream(String groupId) async* {
    final streamController = StreamController<List<dynamic>>();

    final subscription = FirebaseFirestore.instance
        .collection((data["dmId"] != null)? 'DirectMessages':'Groups')
        .doc(groupId)
        .collection('Messages')
        .orderBy('sent', descending: true)
        .snapshots()
        .listen((event) async {
      try {
        var messages = [];
        var messageData;
        var sentBy;
        for (var doc in event.docs) {
          messageData = doc.data();
          // print(messageData['sentBy'].get());
          sentBy = await messageData['sentBy'].get();
          messageData['sentByUid'] = messageData['sentBy'].id;
          messageData['sentBy'] = await sentBy.data() as Map<String, dynamic>;

          DateTime sent;
          if (messageData['sent'] == null) {
            sent = DateTime.now();
          } else {
            sent = DateTime.fromMillisecondsSinceEpoch(
                messageData['sent'].seconds * 1000);
          }
          messageData['subheading'] =
              "${messageData["sentBy"]['ForeName']} ${messageData["sentBy"]['SurName']} ◦ ${sent.hour}:${sent.minute < 10 ? "0" : ""}${sent.minute}";
          // print(messageData['sent'].seconds * 1000);

          // messageData['sent'] =
          //     "${sent.hour}:${sent.minute < 10 ? "0" : ""}${sent.minute}";

          messages.add(messageData);
        }
        streamController.add(messages);
      } catch (e) {
        // Handle errors and emit an error state if needed.
        print(e);
        streamController.addError(e);
        print(e);
      }
    });

    // Add a cancel callback to close the stream when no longer needed.
    // You can call this when you dispose of your widget or no longer need the stream.
    streamController.onCancel = () {
      subscription.cancel();
    };

    yield* streamController.stream;
  }

  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool dmFlag = (data["dmId"] != null);
    return Scaffold(
      appBar: AppBar(
        title: Text('${data['groupName']}',
            style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: LAppTheme.lightTheme.primaryColor,
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            LineAwesomeIcons.angle_up,
            color: LAppTheme.lightTheme.primaryColor,
          ),
          color: Colors.grey[500],
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (!dmFlag)
          IconButton(
            color: Colors.grey[500],
            icon:
                Icon(Icons.more_vert, color: LAppTheme.lightTheme.primaryColor),
            //Icon not showing
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.topToBottom,
                    child: const GroupOptions(),
                    settings: RouteSettings(arguments: {
                      'members': data["members"],
                      'groupId': data["groupId"],
                      'groupName': data["groupName"],
                      'groupPicture': data["groupPicture"],
                    })),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<List<dynamic>>(
            stream: getMessagesStream(dmFlag? data["dmId"]: data['groupId']),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              if (snapshot.data == null) {
                return const Text("Error.");
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                reverse: true,
                shrinkWrap: true,
                children: snapshot.data!
                    .map((data) {
                      // if (data['sent'] == null) {
                      //   return const Text('hi');
                      // }

                      // print(data);

                      var sentText = "";

                      // DateTime sent = DateTime.fromMillisecondsSinceEpoch(
                      //     data['sent'].seconds * 1000);

                      // sentText =
                      //     "${data['sentBy']['ForeName']} ${data['sentBy']['SurName']} • ${sent.hour}:${sent.minute < 10 ? "0" : ""}${sent.minute}";

                      return Container(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                            alignment:
                                (Auth().currentUser() != data['sentByUid']
                                    ? Alignment.topLeft
                                    : Alignment.topRight),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      (Auth().currentUser() != data['sentByUid']
                                          ? Colors.grey.shade200
                                          : LAppTheme.lightTheme.primaryColor),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  data['text'],
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                data['subheading'],
                                textAlign: TextAlign.right,
                              )
                            ])),
                      );
                    })
                    .toList()
                    .cast(),
              );
            },
          )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[600]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // First child is enter comment text input
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      autocorrect: false,
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: "message".tr,
                        labelStyle:
                            TextStyle(fontSize: 20.0, color: Colors.grey[400]),
                        fillColor: Colors.blue,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.purpleAccent),
                        ),
                      ),
                    ),
                  ),
                ),
                // Second child is button
                IconButton(
                  icon: const Icon(Icons.send),
                  iconSize: 20.0,
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection('Groups')
                        .doc(data['groupId'])
                        .collection('Messages')
                        .add({
                      "text": textController.text,
                      'sent': FieldValue.serverTimestamp(),
                      'sentBy': FirebaseFirestore.instance
                          .collection('Users')
                          .doc(Auth().currentUser())
                    });
                    textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
