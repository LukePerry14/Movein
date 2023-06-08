import 'package:flutter/material.dart';
import 'package:movein/swipe_card.dart';
import 'dart:convert';
import 'package:movein/profile-data.dart';
import 'package:flutter/services.dart';

class Gscroller extends StatefulWidget {
  const Gscroller({Key? key}) : super(key: key);

  @override
  State<Gscroller> createState() => _GscrollerState();
}

class _GscrollerState extends State<Gscroller> {

  int Stack_pos = 0;
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

  void shortListGroup() {
    // do some magic
    increaseStackCounter();
  }

  void rejectGroup() {
    // do some other magic
    increaseStackCounter();
  }

  void increaseStackCounter() {
    setState(() {
      Stack_pos = (Stack_pos + 1)%5;
    });
  }


  _GscrollerState() {
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: profiles.length + 1,
        itemBuilder: (context, index){
          if(index < profiles.length){
            return SwipeCard(id: profiles[index].id, userName: profiles[index].userName, userAge: profiles[index].userAge, userDescription: profiles[index].userDescription, profileImageSrc: profiles[index].profileImageSrc);
          }else{
            return const SizedBox(
              height: 70.0,
            );
          }

        },
      ),
    );
  }
}
