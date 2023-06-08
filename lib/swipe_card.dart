import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {
  final String id;
  final String userName;
  final int userAge;
  final String userDescription;
  final String profileImageSrc;

  const SwipeCard({
    Key? key,
    required this.id,
    required this.userName,
    required this.userAge,
    required this.userDescription,
    required this.profileImageSrc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = width; // Calculate the height based on the width

        return Container(
          margin: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                color: const Color.fromARGB(255, 67, 67, 67),
                spreadRadius: 0,
                blurRadius: 6,
                offset: Offset(0, 4),
              )
            ],
            image: DecorationImage(
              image: AssetImage(profileImageSrc),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                  child: Row(
                    children: [
                      Text(
                        "$userName  $userAge",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                  child: Text(
                    userDescription,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
