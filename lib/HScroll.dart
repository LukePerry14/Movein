import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movein/swipe_card.dart';
import 'package:movein/profile-data.dart';

class Gscroller extends StatefulWidget {
  final String groupName;
  final dynamic members;
  final String groupPicture;
  final double avgNoisiness;
  final double avgCleanliness;
  final double avgNightLife;
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
    required this.avgBedTime,

    this.showFriend = false,
  }) : super(key: key);

  @override
  State<Gscroller> createState() => _GscrollerState();
}

class _GscrollerState extends State<Gscroller> {
  late Future<List<CardProfile>> loadProfilesFuture;
  late List<CardProfile> profiles;



  Future<List<CardProfile>> loadProfiles() async {
    List<CardProfile> loadedProfiles = [];

    for (String id in widget.members) {
      try {
        final cardProfile = await CardProfile.fetchCardProfile(id);
        if (cardProfile != null) {
          loadedProfiles.add(cardProfile);
        }
        else{
        }
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
    return Expanded(
      child: FutureBuilder<List<CardProfile>>(
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
            itemCount: profiles.length + 3,
            itemBuilder: (context, index) {
              if (index == 0){
                return CircleAvatar(
                  radius: 75, // Adjust the size as needed
                  backgroundColor: Colors.transparent, // Set the background color to transparent
                  child: ClipOval(
                    child: Image(
                      image: AssetImage(widget.groupPicture),
                      fit: BoxFit.cover, // Adjust the fit as needed
                    ),
                  ),
                );
              }

              else if(index == 1){
                return ExpansionTile(
                  title: Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.5 - 68,),
                      Text(
                        widget.groupName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ]
                  ),
                  children: [
                    const SizedBox(height: 20), // Add space between the title and the children
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "${profiles.length} Members",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 10), // Add space between the children
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Average BedTime: $formattedTime",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 10), // Add space between the children
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Cleanliness is of ${widget.avgCleanliness}/5 importance",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 10), // Add space between the children
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Noisiness is of ${widget.avgNoisiness}/5 importance",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 10), // Add space between the children
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "NightLife is of ${widget.avgNightLife}/5 importance",
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
      ),
    );
  }
}
