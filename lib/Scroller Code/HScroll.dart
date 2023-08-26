import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:movein/Scroller%20Code/swipe_card.dart';
import 'package:movein/Scroller%20Code/profile-data.dart';
import '../Themes/lMode.dart';

class Gscroller extends StatefulWidget {
  final String groupName;
  final dynamic members;
  final String groupPicture;
  final double avgNoisiness;
  final double avgCleanliness;
  final double avgNightLife;
  final double avgYearOfStudy;
  final Timestamp avgBedTime;
  final bool showFriend;

  const Gscroller({
    Key? key,
    required this.groupName,
    required this.members,
    required this.groupPicture,
    required this.avgNoisiness,
    required this.avgCleanliness,
    required this.avgNightLife,
    required this.avgYearOfStudy,
    required this.avgBedTime,

    this.showFriend = false,
  }) : super(key: key);

  @override
  State<Gscroller> createState() => _GscrollerState();
}

class _GscrollerState extends State<Gscroller> {
  late Future<List<CardProfile>> loadProfilesFuture;
  late List<CardProfile> profiles;
  bool _isExpanded = false;



  Future<List<CardProfile>> loadProfiles() async {
    List<CardProfile> loadedProfiles = [];

    for (String id in widget.members) {
      try {
        final cardProfile = await CardProfile.fetchCardProfile(id);
        loadedProfiles.add(cardProfile);
      } catch (e) {
        throw FirebaseException(
            message: 'Error creating cardProfile: $e',
            plugin: 'cloud_firestore');
      }
    }

    return loadedProfiles;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CardProfile>>(
      future: loadProfiles(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show an error message if data retrieval fails
        }

        profiles = snapshot.data ?? []; // Assign the fetched data to the profiles list
        DateTime? dateTime;
        String formattedTime = '';
        dateTime = widget.avgBedTime.toDate();
        DateFormat timeFormat = DateFormat.jm();
        formattedTime = timeFormat.format(dateTime);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profiles.length + 3,
          itemBuilder: (context, index) {
            if (index == 0){
              return Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    widget.groupName,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height:5),
                  CircleAvatar(
                    radius: 75, // Adjust the size as needed
                    backgroundColor: Colors.transparent, // Set the background color to transparent
                    child: ClipOval(
                      child: Image(
                        image: AssetImage(widget.groupPicture),
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),
                  ),
                ]
              );
            }

            else if(index == 1){
              return ExpansionTile(
                trailing: null,
                backgroundColor: _isExpanded ? Colors.grey : Colors.grey.withOpacity(0.27), // Set background color to grey when expanded
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isExpanded = expanded;
                  });
                },
                title: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text("...", style: GoogleFonts.lexend(color:  LAppTheme.lightTheme.primaryColor, fontWeight: FontWeight.normal, fontSize: 26))
                    ]
                ),
                children: [
                  const SizedBox(height: 20), // Add space between the title and the children
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${profiles.length} ${"mems".tr}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 10), // Add space between the children
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${"asleep".tr} $formattedTime",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 10), // Add space between the children
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${"clean".tr}: ${widget.avgCleanliness}/5",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 10), // Add space between the children
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${"noise".tr}: ${widget.avgNoisiness}/5",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 10), // Add space between the children
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${"nightlife".tr}: ${widget.avgNightLife}/5",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 10), // Add space between the children
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${"yearofstudy".tr}: ${widget.avgYearOfStudy}/7",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 20), // Add space between the last child and the bottom of the tile
                ],
              );
            } else if (index < profiles.length+2) {
              return SwipeCard(
                id: profiles[index-2].id,
                foreName: profiles[index-2].foreName,
                age: profiles[index-2].age,
                uni: profiles[index-2].uni,
                preferences: profiles[index-2].preferences,
                images: profiles[index-2].images,
                bio: profiles[index-2].bio,
                subject: profiles[index-2].subject,
                yearOfStudy: profiles[index-2].yearOfStudy,
                showFriend: widget.showFriend,
              );
            } else {
              return const SizedBox(
                height: 70.0,
              );
            }
          },
        );
      },
    );
  }
}