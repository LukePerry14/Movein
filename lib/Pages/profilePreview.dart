import 'package:flutter/material.dart';


class PreviewCard extends StatefulWidget {
  final String foreName;
  final String profileImg;

  const PreviewCard(
    {
      Key? key,
      required this.foreName,
      required this.profileImg,
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
          borderRadius: BorderRadius.circular(10.0),
        ),
           )

      );

      
    }


  }


