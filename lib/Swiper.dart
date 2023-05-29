import 'package:flutter/material.dart';
import 'package:movein/swipe_card.dart';
import 'dart:convert';
import 'package:movein/profile-data.dart';
import 'package:flutter/services.dart';

class Swiper extends StatefulWidget {
  const Swiper({Key? key}) : super(key: key);

  @override
  State<Swiper> createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {

  int Stack_pos = 0;
  double Swipe_Threshhold = 250.0;

  List<Profile> profiles = <Profile>[];

  loadJsonData() async {
    String jsonData = await rootBundle.loadString('assets/JSON/profiles.json');
    setState(() {
      profiles = json
          .decode(jsonData)
          .map<Profile>((dataPoint) => Profile.fromJson(dataPoint))
          .toList();
    });
  }

  void evaluateSwipe(dx) {
    if (dx > Swipe_Threshhold) {
      saveGroup();
    } else if (dx < -Swipe_Threshhold) {
      blockGroup();
    }

  }

  void saveGroup() {
    // do some magic
    increaseStackCounter();
  }

  void blockGroup() {
    // do some other magic
    increaseStackCounter();
  }

  void increaseStackCounter() {
    setState(() {
      Stack_pos = (Stack_pos + 1)%5;
    });
  }


  _SwiperState() {
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => Draggable(
          onDragEnd: (details) => evaluateSwipe(details.offset.dx),
          feedback: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: SwipeCard(
              id: profiles[Stack_pos].id,
              userName: profiles[Stack_pos].userName,
              userAge: profiles[Stack_pos].userAge,
              userDescription: profiles[Stack_pos].userDescription,
              profileImageSrc: profiles[Stack_pos].profileImageSrc,
            ),
          ),
          childWhenDragging: SwipeCard(
            id: profiles[Stack_pos + 1].id,
            userName: profiles[Stack_pos + 1].userName,
            userAge: profiles[Stack_pos + 1].userAge,
            userDescription: profiles[Stack_pos + 1].userDescription,
            profileImageSrc: profiles[Stack_pos + 1].profileImageSrc,
          ),
          child: SwipeCard(
            id: profiles[Stack_pos].id,
            userName: profiles[Stack_pos].userName,
            userAge: profiles[Stack_pos].userAge,
            userDescription: profiles[Stack_pos].userDescription,
            profileImageSrc: profiles[Stack_pos].profileImageSrc,
          ),
        ),
      ),
    );
  }
}
