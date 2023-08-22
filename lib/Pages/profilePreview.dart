import 'package:flutter/material.dart';
import 'package:movein/Scroller Code/swipe_card.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

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
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        width: MediaQuery.of(context).size.width * 0.50,
        height: MediaQuery.of(context).size.height * 0.50,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        // changed from stack to column
        child: Stack
        (
          
          children: 
          [ 
            SizedBox
            (
              width:double.maxFinite,
              child: Container (
                padding:EdgeInsets.fromLTRB(10,0,10,0),
              decoration: BoxDecoration
              
              (
                border:Border.all(width:5),
                
                shape: BoxShape.circle,
                
                image:  DecorationImage(
                  image: NetworkImage(widget.user.profileImage!)
                )
              ),
              )
            ),
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
            
          Row(
            children: 
            [
              IconButton(onPressed: (){}, icon: Icon(Icons.info)),
              IconButton(onPressed:(){}, icon: Icon(Icons.chat)),
            ],
          )
          
          ],

        ),
        


           )

      );

      
    }


  }


