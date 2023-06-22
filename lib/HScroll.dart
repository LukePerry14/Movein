import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movein/swipe_card.dart';
import 'package:movein/profile-data.dart';

class Gscroller extends StatefulWidget {
  final String groupName;
  final List<String> members;

  const Gscroller({
    Key? key,
    required this.groupName,
    required this.members,
  }) : super(key: key);

  @override
  State<Gscroller> createState() => _GscrollerState();
}

class _GscrollerState extends State<Gscroller> {
  late Future<List<CardProfile>> loadProfilesFuture;
  late List<CardProfile> profiles;

  @override
  void initState() {
    super.initState();
    loadProfilesFuture = loadProfiles();
  }

  Future<List<CardProfile>> loadProfiles() async {
    List<CardProfile> loadedProfiles = [];

    for (String id in widget.members) {
      try {
        final cardProfile = await CardProfile.fetchCardProfile(id);
        if (cardProfile != null) {
          loadedProfiles.add(cardProfile);
        }
        else{
          print("here");
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
        future: loadProfilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting for data
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Show an error message if data retrieval fails
          }

          profiles = snapshot.data ?? []; // Assign the fetched data to the profiles list

          return ListView.builder(
            itemCount: profiles.length + 2,
            itemBuilder: (context, index) {
              if(index == 0){
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.groupName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
              } else if (index < profiles.length+1) {
                return SwipeCard(
                  id: profiles[index-1].id,
                  foreName: profiles[index-1].foreName,
                  age: profiles[index-1].age,
                  uni: profiles[index-1].uni,
                  preferences: profiles[index-1].preferences,
                  images: profiles[index-1].images,
                  bio: profiles[index-1].bio,
                  subject: profiles[index-1].subject,
                  yearOfStudy: profiles[index-1].yearOfStudy,
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
