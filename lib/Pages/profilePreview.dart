import 'package:flutter/material.dart';
import 'package:movein/Scroller Code/swipe_card.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:movein/Pages/Sendbird.dart';
import 'package:movein/Pages/Messages.dart' as mb;
import 'package:sendbird_sdk/sendbird_sdk.dart' ;
import 'package:page_transition/page_transition.dart';
class PreviewCard extends StatefulWidget {
  final String foreName;
  final ChatUser user;

  const PreviewCard(
    {
      Key? key,
      required this.foreName,
      required this.user,
    }
  ): super(key:key);

    @override
  State<PreviewCard> createState() => _PreviewCardState();
}
  class _PreviewCardState extends State<PreviewCard>
  {
    @override
    Widget build(BuildContext context)
    {
      
      return Dialog 
      (
          insetPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder
          (
            borderRadius: BorderRadius.circular(20.0)
          ),
           child: Container(
            
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        width: MediaQuery.of(context).size.width * 0.50,
        height: MediaQuery.of(context).size.height * 0.50,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        // changed from stack to column
        
        
        
          
            
          child: Stack (
          children: 
          [ 
            
            Align(
              alignment: Alignment.topCenter,
              child:Text(widget.user.firstName!)),
            Positioned(
              top: 0,
              right:0,
              child: IconButton
              (
                                splashRadius: 20,
                icon: const Icon(LineAwesomeIcons.times_circle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
    
              
              ),
          
      // diplay profile picture 
          Stack(
            
            
          children: [ 
            Align(
            alignment: Alignment.center,
           child:SizedBox
            (
              //width:double.maxFinite,
              
              child: Container (
                width:200,
                height:200,
                padding:EdgeInsets.fromLTRB(10,20,10,20),
              decoration: BoxDecoration
              
              (
                border:Border.all(width:2),
                
                shape: BoxShape.circle,
                
                image:  DecorationImage(
                  image: widget.user.profileImage != "" ? NetworkImage(widget.user.profileImage!) :  AssetImage('assets/Images/reversed.jpg') as ImageProvider,
                  fit: BoxFit.fill
                )
              ),
              ),
            ),
            )
          ]
          ),
          
            
            
            
          
            
          Positioned(
            bottom:0,
            left:0,  
              child:IconButton(
                
                onPressed: () async 
                {
                  final groupChannel = await ConnectSendbird().returnChannel(widget.user.id);
                }

                            
              //{
              /*showDialog<String>(
                                        /context: context,
                                        builder: (BuildContext context) =>
                                        // RETRIEVE USER INFO!!
                                            CustomDialog(
                                              id: widget.user.id,
                                              foreName: widget.user.f
                                              age: memberDetails[index]['Age'],
                                              uni: memberDetails[index]['Uni'],
                                              preferences: memberDetails[index]
                                              ['Preferences'],
                                              images: memberDetails[index]['Images'],
                                              bio: memberDetails[index]['Bio'],
                                              subject: memberDetails[index]['Subject'],
                                              yearOfStudy: memberDetails[index]
                                              ['YearOfStudy'],
                                            ),
                                      );*/

              //}
              
              , icon: Icon(Icons.info))
              
              
            
          ),
          Positioned(
          bottom: 0,
          right: 0,
          child:IconButton(
            onPressed:
              () async 
                {
                  ChatUser current = asDashChatUser(SendbirdSdk().currentUser!);
                  final groupChannel = await ConnectSendbird().returnChannel(widget.user.id + current.id);
                  var usersIds = [current.id,widget.user.id];
                  usersIds.sort();
                  Navigator.push(context, PageTransition
                  (
                    curve:Curves.linear,
                    type: PageTransitionType.topToBottom,
                    child: const mb.Messages(),
                    settings: RouteSettings(
                      arguments: 
                      {
                        'channel':groupChannel,
                        'members': [current,widget.user],
                        'groupId': usersIds[0] + usersIds[1],
                        'groupName': widget.user.firstName
                      }
                    )
                  )
                  );

                }
          

            
            , 
            icon: Icon(Icons.chat)),
          
          ), 
          
          ]
          

        ),
        


           
           )

      );

      
    }

 ChatUser asDashChatUser(User user)
  {
   return ChatUser(
    
        firstName: user.nickname,
        id: user.userId,
        profileImage: user.profileUrl,

   );
  }
  }


