import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movein/swipe_card.dart';
import 'package:movein/profile-data.dart';

class Gscroller extends StatefulWidget {
  final String groupName;
  final dynamic members;
  final String groupPicture;
  final bool showFriend;

  const Gscroller({
    Key? key,
    required this.groupName,
    required this.members,
    required this.groupPicture,
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
                return Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.groupName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "${profiles.length} Members",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ]
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
