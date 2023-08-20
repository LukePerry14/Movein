import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart' ;


import 'package:movein/Pages/Sendbird.dart';
import '../Themes/lMode.dart';
import '../Auth code/auth.dart';




class Messages extends StatefulWidget {
  //final GroupChannel groupchannel;
  
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> with ChannelEventHandler {


  
    /*Future <GroupChannel> retrieveChannel() async
    {
      return groupChannel = await ConnectSendbird().returnChannel("testurl");
    }*/
    var groupChannel;
    Map data = {};
    
    
    //GroupChannel groupChannel = await ConnectSendbird().returnChannel('testUrl');
  //final groupChannel = retrieveChannel();
  List<BaseMessage> _messages = [];

   
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    data = ModalRoute.of(context)?.settings.arguments as Map;
    groupChannel = (data["channel"]);
    groupChannel = (data["channel"]);
    getMessages(groupChannel!);
    SendbirdSdk().addChannelEventHandler(groupChannel.channelUrl, this);
    //groupChannel = ConnectSendbird().returnChannel("testUrl");
  }
  
    @override
  void initState() {
    super.initState();
    //data = ModalRoute.of(context)?.settings.arguments as Map;
    //groupChannel = (data["channel"]);
    //groupChannel = await ConnectSendbird().returnChannel("testUrl");
    //groupChannel = (data["channel"]);
    if (groupChannel != null)
    {
      getMessages(groupChannel);
      //SendbirdSdk().addChannelEventHandler(groupChannel!.channelUrl, this);
    }
  }

 

 


  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler(groupChannel!.channelUrl);
    super.dispose();
  }

  @override
  onMessageReceived(channel, message) {
    setState(() {
      _messages.add(message);
    });
  }

Future<void> getMessages(GroupChannel channel) async {
    try {
      List<BaseMessage> messages = await channel.getMessagesByTimestamp(
          DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
      ChatUser user = asDashChatUser(SendbirdSdk().currentUser!);

    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            appBar: AppBar(
              title: Text('${data['groupName']}', style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall),
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
                icon: Icon(LineAwesomeIcons.angle_left, color: LAppTheme.lightTheme.primaryColor,),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  color: Colors.grey[500],
                  icon: Icon(Icons.more_vert, color: LAppTheme.lightTheme.primaryColor),
                  //Icon not showing
                  onPressed: () {
                    Navigator.pushNamed(context, '/GroupOptions', arguments: {
                      'members': data['members'],
                      'groupId': data['groupId'],
                      'groupName': data['groupName'],
                      'groupPicture' : data['groupPicture'],
                    });
                  },
                ),
              ],
            ),
            // removed safe!!
            body:  SafeArea(
              
// add own code here--------------------------------------------------------------------------------
              child: DashChat
              (
                messageOptions: const MessageOptions
                (
                      showCurrentUserAvatar: false,
                ),
                currentUser: user,
                onSend: (ChatMessage messagew) async
                { 
                //ConnectSendbird().connect("33BDBE40-0D0C-4529-BA3B-74C0916D2682", Auth().currentUser(),'test');

                  GroupChannel groupChannel = data['channel'];
                  
                  try
                  { 
                

                    /*groupChannel.sendUserMessage(
                          sbChat.UserMessageCreateParams(
                            message: messagew.text,
                          )

*/
                            //),
                            //handler: (UserMessage message, sbChat.SendbirdException? e)  {if (e!=null){}else{}}

                    
                   
                    final params = UserMessageParams(message:messagew.text)
                    //..data = 'DATA'
                    ..customType = 'custom'
                    

                    ;
                    UserMessage sentMessage = groupChannel.sendUserMessage(params);

                        setState(() {
                          _messages.add(sentMessage);
                        });
                        
  // Use message to display the message before it is sent to the server.
} catch (e) {
  // Handle error.
  print('errror');
                  }
                
                   
                  
                    /*setState((){
                  _messages.add(sentMessage);*/
               // }
                 // );
                },
                messages: asDashChatMessages(_messages),
              
              


            ),
            )
                
          );
          
// --------------------------------------------------------------------------------------------------
        }
    );
  }

// retrieves user sendbird account
  ChatUser asDashChatUser(User user)
  {
   return ChatUser(
    
        firstName: user.nickname,
        id: user.userId,
        profileImage: user.profileUrl,

   );
  }
  
  // retrieves messages
 List<ChatMessage> asDashChatMessages(List<BaseMessage> messages)
  {
    List<ChatMessage> result = [];
    if (messages != null){
    messages.forEach((message)
    {
      User user = message.sender!;
      if (user == null)
      {
        return;
      }
      result.insert(0,
        ChatMessage
        (
          user: asDashChatUser(user),
           createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
           text: message.message,
           
           
           
           
           ),
           );

    });
  }
  return result;
    }

   


}

