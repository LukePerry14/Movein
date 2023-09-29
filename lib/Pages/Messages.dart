import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
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
  // groupChannel = (data["channel"]);
  // groupChannel = (data["channel"]);
  // getPrevMessages();
  //getMessages(groupChannel!);
  // SendbirdSdk().addChannelEventHandler(groupChannel.channelUrl, this);
  //groupChannel = ConnectSendbird().returnChannel("testUrl");
  //}

  late final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('Groups')
      .doc(data['groupId'])
      .collection('Messages')
      .orderBy('sent', descending: false)
      .snapshots();

  TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            color: Colors.grey[500],
            icon:
                Icon(Icons.more_vert, color: LAppTheme.lightTheme.primaryColor),
            //Icon not showing
            onPressed: () {
              if (data["channel"].customType == "DM") {
              } else {
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
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      late Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      var sentText = "";
                      if (data['sent'] != null) {
                        // var userDoc = await FirebaseFirestore.instance
                        //     .collection('Users')
                        //     .doc(data['sentBy'])
                        //     .get();

                        // print((userDoc.data() as Map<String, dynamic>)['ForeName']);

                        late DateTime sent =
                            DateTime.fromMillisecondsSinceEpoch(
                                data['sent']?.seconds * 1000);

                        // sentText =
                        //     "${data['sentBy']} • ${sent.hour}:${sent.minute < 10 ? "0" : ""}${sent.minute}";

                        sentText =
                            "${sent.hour}:${sent.minute < 10 ? "0" : ""}${sent.minute}";
                      }

                      return Container(
                        padding: EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                            alignment: (Auth().currentUser() != data['sentBy']
                                ? Alignment.topLeft
                                : Alignment.topRight),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: (Auth().currentUser() != data['sentBy']
                                      ? Colors.grey.shade200
                                      : Colors.blue[200]),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  data['text'],
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                sentText,
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
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                // First child is enter comment text input
                Expanded(
                  child: TextFormField(
                    autocorrect: false,
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: "Message",
                      labelStyle:
                          TextStyle(fontSize: 20.0, color: Colors.black),
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: Colors.purpleAccent)),
                    ),
                  ),
                ),
                // Second child is button
                IconButton(
                  icon: const Icon(Icons.send),
                  iconSize: 20.0,
                  onPressed: () {
                    print(textController.text);
                    FirebaseFirestore.instance
                        .collection('Groups')
                        .doc(data['groupId'])
                        .collection('Messages')
                        .add({
                      "text": textController.text,
                      'sent': FieldValue.serverTimestamp(),
                      'sentBy': Auth().currentUser()
                    });
                    textController.clear();
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                  },
                )
              ])),
        ],
      ),

      // Stack(
      //   children: [
      //     StreamBuilder<QuerySnapshot>(
      //       stream: _usersStream,
      //       builder: (BuildContext context,
      //           AsyncSnapshot<QuerySnapshot> snapshot) {
      //         if (snapshot.hasError) {
      //           return const Text('Something went wrong');
      //         }

      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return const Text("Loading");
      //         }

      //         return ListView(
      //           children: snapshot.data!.docs
      //               .map((DocumentSnapshot document) {
      //                 Map<String, dynamic> data =
      //                     document.data()! as Map<String, dynamic>;
      //                 return ListTile(
      //                   title: Text(data['text']),
      //                   // subtitle: Text(data['company']),
      //                 );
      //               })
      //               .toList()
      //               .cast(),
      //         );
      //       },
      //     ),
      //     TextField(
      //       decoration: const InputDecoration(
      //         border: OutlineInputBorder(),
      //         hintText: 'Message',
      //       ),
      //       controller: textController,
      //     ),
      //     ElevatedButton(
      //         onPressed: () {
      //           print(textController.text);
      //           FirebaseFirestore.instance
      //               .collection('Groups')
      //               .doc(data['groupId'])
      //               .collection('Messages')
      //               .add({"text": textController.text});
      //         },
      //         child: const Text('Send')),
      //   ],
      // )
    );
  }
}

// class MessageView extends StatefulWidget {
//   @override
//   _MessageViewState createState() => _MessageViewState();
// }

// class _MessageViewState extends State<MessageView> {
//   final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
//       .collection('Groups')
//       .doc(data['groupId'])
//       .collection('Messages')
//       .snapshots();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _usersStream,
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Text('Something went wrong');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Text("Loading");
//         }

//         return ListView(
//           children: snapshot.data!.docs
//               .map((DocumentSnapshot document) {
//                 Map<String, dynamic> data =
//                     document.data()! as Map<String, dynamic>;
//                 return ListTile(
//                   title: Text(data['text']),
//                   // subtitle: Text(data['company']),
//                 );
//               })
//               .toList()
//               .cast(),
//         );
//       },
//     );
//   }
// }



    // removed safe!!
    // body: SafeArea(
// add own code here--------------------------------------------------------------------------------
//           child: DashChat(
//             messageOptions: MessageOptions(
//               showCurrentUserAvatar: false,
//               onPressAvatar: (ChatUser user) {
//                 if (data["channel"].customType == "DM") {
//                 } else {
//                   showDialog<String>(
//                       context: context,
//                       builder: (BuildContext context) =>
//                           PreviewCard(foreName: 'placeholder', user: user));
//                 }
//               },
//             ),
//             currentUser: user,
//             onSend: (ChatMessage messagew) async {
//               //ConnectSendbird().connect("33BDBE40-0D0C-4529-BA3B-74C0916D2682", Auth().currentUser(),'test');

//               GroupChannel groupChannel = data['channel'];

//               try {
//                 /*groupChannel.sendUserMessage(
//                           sbChat.UserMessageCreateParams(
//                             message: messagew.text,
//                           )

// */
//                 //),
//                 //handler: (UserMessage message, sbChat.SendbirdException? e)  {if (e!=null){}else{}}

//                 final params = UserMessageParams(message: messagew.text)
//                     //..data = 'DATA'
//                     //..customType = 'custom'

//                     ;
//                 UserMessage sentMessage = groupChannel.sendUserMessage(params);

//                 setState(() {
//                   _messages.add(sentMessage);
//                 });

//                 // Use message to display the message before it is sent to the server.
//               } catch (e) {
//                 // Handle error.
//                 print('errror');
//               }

//               /*setState((){
//                   _messages.add(sentMessage);*/
//               // }
//               // );
//             },
//             messages: asDashChatMessages(_messages),
//           ),
    //  ));
  // }
// }

// class Messages extends StatefulWidget {
//   //final GroupChannel groupchannel;
//   ChatUser asDashChatUser(User user) {
//     return ChatUser(
//       firstName: user.nickname,
//       id: user.userId,
//       profileImage: user.profileUrl,
//     );
//   }

//   const Messages({Key? key}) : super(key: key);

//   @override
//   State<Messages> createState() => _MessagesState();
// }

// class _MessagesState extends State<Messages> with ChannelEventHandler {
//   /*Future <GroupChannel> retrieveChannel() async
//     {
//       return groupChannel = await ConnectSendbird().returnChannel("testurl");
//     }*/
//   var groupChannel;
//   Map data = {};

//   //GroupChannel groupChannel = await ConnectSendbird().returnChannel('testUrl');
//   //final groupChannel = retrieveChannel();
//   List<BaseMessage> _messages = [];

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     data = ModalRoute.of(context)?.settings.arguments as Map;
//     groupChannel = (data["channel"]);
//     groupChannel = (data["channel"]);
//     getPrevMessages();
//     //getMessages(groupChannel!);
//     SendbirdSdk().addChannelEventHandler(groupChannel.channelUrl, this);
//     //groupChannel = ConnectSendbird().returnChannel("testUrl");
//   }

//   @override
//   void initState() {
//     super.initState();
//     //data = ModalRoute.of(context)?.settings.arguments as Map;
//     //groupChannel = (data["channel"]);
//     //groupChannel = await ConnectSendbird().returnChannel("testUrl");
//     //groupChannel = (data["channel"]);
//     if (groupChannel != null) {
//       getPrevMessages();
//       //getMessages(groupChannel);
//       //SendbirdSdk().addChannelEventHandler(groupChannel!.channelUrl, this);
//     }
//   }

//   @override
//   void dispose() {
//     SendbirdSdk().removeChannelEventHandler(groupChannel!.channelUrl);
//     super.dispose();
//   }

//   @override
//   onMessageReceived(channel, message) {
//     setState(() {
//       _messages.add(message);
//     });
//   }

//   Future<void> readMessages(GroupChannel channel) async {
//     @override
//     onReadReceiptUpdated(GroupChannel channel) {
//       // TODO: implement onReadReceiptUpdated
//       super.onReadReceiptUpdated(channel);
//     }
//   }

//   Future<void> getMessages(GroupChannel channel) async {
//     try {
//       //sbc.SendbirdChat.markAsRead(channelUrls: );
//       List<BaseMessage> messages = await channel.getMessagesByTimestamp(
//           DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
//       setState(() {
//         _messages = messages;
//       });
//     } catch (e) {
//       print('group_channel_view.dart: getMessages: ERROR: $e');
//     }
//   }

//   Future<void> getPrevMessages() async {
//     try {
//       final query = PreviousMessageListQuery(
//         channelType: ChannelType.group,
//         channelUrl: data["groupId"],
//       )..limit = 50;
//       final messages = await query.loadNext();
//       setState(() {
//         _messages = messages;
//       });
//     } catch (e) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     ChatUser user = asDashChatUser(SendbirdSdk().currentUser!);

//     return Builder(builder: (context) {
//       final navigator = Navigator.of(context);

//       return Scaffold(
//           appBar: AppBar(
//             title: Text('${data['groupName']}',
//                 style: Theme.of(context).textTheme.headlineSmall),
//             centerTitle: true,
//             elevation: 0,
//             backgroundColor: Theme.of(context).canvasColor,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(1.0),
//               child: Container(
//                 color: LAppTheme.lightTheme.primaryColor,
//                 height: 1.0,
//               ),
//             ),
//             leading: IconButton(
//               icon: Icon(
//                 LineAwesomeIcons.angle_up,
//                 color: LAppTheme.lightTheme.primaryColor,
//               ),
//               color: Colors.grey[500],
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             actions: [
//               IconButton(
//                 color: Colors.grey[500],
//                 icon: Icon(Icons.more_vert,
//                     color: LAppTheme.lightTheme.primaryColor),
//                 //Icon not showing
//                 onPressed: () {
//                   if (data["channel"].customType == "DM") {
//                   } else {
//                     Navigator.push(
//                       context,
//                       PageTransition(
//                           curve: Curves.linear,
//                           type: PageTransitionType.topToBottom,
//                           child: const GroupOptions(),
//                           settings: RouteSettings(arguments: {
//                             'members': data["members"],
//                             'groupId': data["groupId"],
//                             'groupName': data["groupName"],
//                             'groupPicture': data["groupPicture"],
//                           })),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//           // removed safe!!
//           body: SafeArea(
// // add own code here--------------------------------------------------------------------------------
//             child: DashChat(
//               messageOptions: MessageOptions(
//                 showCurrentUserAvatar: false,
//                 onPressAvatar: (ChatUser user) {
//                   if (data["channel"].customType == "DM") {
//                   } else {
//                     showDialog<String>(
//                         context: context,
//                         builder: (BuildContext context) =>
//                             PreviewCard(foreName: 'placeholder', user: user));
//                   }
//                 },
//               ),
//               currentUser: user,
//               onSend: (ChatMessage messagew) async {
//                 //ConnectSendbird().connect("33BDBE40-0D0C-4529-BA3B-74C0916D2682", Auth().currentUser(),'test');

//                 GroupChannel groupChannel = data['channel'];

//                 try {
//                   /*groupChannel.sendUserMessage(
//                           sbChat.UserMessageCreateParams(
//                             message: messagew.text,
//                           )

// */
//                   //),
//                   //handler: (UserMessage message, sbChat.SendbirdException? e)  {if (e!=null){}else{}}

//                   final params = UserMessageParams(message: messagew.text)
//                       //..data = 'DATA'
//                       //..customType = 'custom'

//                       ;
//                   UserMessage sentMessage =
//                       groupChannel.sendUserMessage(params);

//                   setState(() {
//                     _messages.add(sentMessage);
//                   });

//                   // Use message to display the message before it is sent to the server.
//                 } catch (e) {
//                   // Handle error.
//                   print('errror');
//                 }

//                 /*setState((){
//                   _messages.add(sentMessage);*/
//                 // }
//                 // );
//               },
//               messages: asDashChatMessages(_messages),
//             ),
//           ));

// // --------------------------------------------------------------------------------------------------
//     });
//   }

// // retrieves user sendbird account
//   ChatUser asDashChatUser(User user) {
//     return ChatUser(
//       firstName: user.nickname,
//       id: user.userId,
//       profileImage: user.profileUrl,
//     );
//   }

//   // retrieves messages
//   List<ChatMessage> asDashChatMessages(List<BaseMessage> messages) {
//     List<ChatMessage> result = [];
//     if (messages != null) {
//       messages.forEach((message) {
//         User user = message.sender!;
//         if (user == null) {
//           return;
//         }
//         result.insert(
//           0,
//           ChatMessage(
//             user: asDashChatUser(user),
//             createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
//             text: message.message,
//             customProperties: {'messageId': message.messageId},
//           ),
//         );
//       });
//     }
//     return result;
//   }

//   Future<BaseMessage> findMessage(int id) async {
//     GroupChannel groupChannel = data['channel'];
//     try {
//       final params = MessageRetrievalParams(
//           channelType: ChannelType.group,
//           channelUrl: groupChannel.channelUrl,
//           messageId: id);
//       //await??
//       final message = BaseMessage.getMessage(params);
//       return message;
//     } catch (e) {
//       throw (e);
//     }
//   }
// }
