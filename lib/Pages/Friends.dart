import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/FriendFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final String UserId = 'iKxLSxcDqlT6vtHe71Bp';
  late List<Friend> friends;
  late List<Friend> searchResults;
  late bool isLoading;
  late bool isSearchLoading;
  late List<Friend> FSSearchResults;
  bool loadExtra = false;
  String searchText = "";


  Future<List<Friend>> fetchFriends() async {
    List<Friend> friends = [];

    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(UserId)
          .get();
      final friendsIds = List<String>.from(
          usersSnapshot.data()?['Friends'] ?? []);

      for (String friendId in friendsIds) {
        final friendSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(friendId)
            .get();
        final friendData = friendSnapshot.data();

        if (friendData != null) {
          final profileImg = friendData['Images'][0];
          final foreName = friendData['Forename'];
          final surName = friendData['Surname'];
          final id = friendId;

          final friend = Friend(
            profileImg: profileImg,
            name: '$foreName $surName',
            id: id,
          );

          friends.add(friend);
        }
      }
    } catch (e) {
      throw FirebaseException(
        message: 'Error fetching friends data: $e',
        plugin: 'cloud_firestore',
      );
    }


    return friends;
  }

  Future<List<Friend>> searchUsers(String searchQuery) async {
    List<Friend> retlist = [];
    List<String> parts = searchQuery.toLowerCase().split(' ');

    final CollectionReference UserCollection = FirebaseFirestore.instance.collection('Users');

    final QuerySnapshot firstnamequery = await UserCollection
        .where('Forename', isEqualTo: parts[0])
        .orderBy('Surname')
        .get();

    final QuerySnapshot lastnamequery = await UserCollection
        .where('Surname', isEqualTo: (parts.length > 1) ? '${parts[1]}\uf8ff' : '${parts[0]}\uf8ff')
        .get();

    final QuerySnapshot idquery = await UserCollection
        .where(FieldPath.documentId, isEqualTo: '$searchQuery\uf8ff')
        .get();

    for (QuerySnapshot SS in [lastnamequery, idquery, firstnamequery]) {
      List<Friend> searched = SS.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Friend(
          profileImg: data['profileImg'],
          name: '${data['Forename']} ${data['Surname']}',
          id: doc.id,
        );
      }).toList();
      retlist.addAll(searched);
    }

    return retlist;
  }

  void searchMore() async {
    setState(() {
      loadExtra = true;
      isSearchLoading = true;
    });

    List<Friend> results = await searchUsers(searchText);

    setState(() {
      FSSearchResults = results;
      isSearchLoading = false;
    });
  }


  void filterSearchResults(String query) {
    setState(() {
      loadExtra = false;
      isSearchLoading = true;
      searchResults = friends
          .where((item) =>
      item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchFriends().then((data) {
      setState(() {
        friends = data;
        searchResults = data;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showExtraSearch = searchText.isNotEmpty;
    return Builder(
      builder: (context) {
        final navigator = Navigator.of(context);

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 40,
                  width: double.maxFinite,
                  child: SearchBar(
                    hintText: "Search",
                    onChanged: (value) {
                      searchText = value;
                      filterSearchResults(value);
                    },
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Light grey background color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                            child: Text("Your Friends", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.left,)
                        ),
                        const SizedBox(height: 10),
                        isLoading ? const Center(child: CircularProgressIndicator())
                            : friends.isEmpty ? Text("Consider Adding Some Friends, you can bring them with you into any groups you find", style: Theme.of(context).textTheme.bodyMedium,)
                            : ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final friend = searchResults[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: Image.asset(friend.profileImg),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            friend.name,
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          Text(
                                            friend.id,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'invite',
                                          child: Text('Invite to Group', style: Theme.of(context).textTheme.bodyMedium),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'remove',
                                          child: Text('Remove Friend', style: Theme.of(context).textTheme.bodyMedium),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'invite') {
                                          var groups = ["pretend","groups"];
                                          if(groups.isNotEmpty){
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => GroupInvite(inviteeId: friend.id)
                                            );
                                          }
                                        } else if (value == 'remove') {
                                          showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) => ConfirmDel(friendId: friend.id)
                                          );
                                          Navigator.pushReplacementNamed(context, "/Friends"); //Dirty way of rebuilding app.
                                        }
                                      },
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                              ),
                            );

                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showExtraSearch)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      searchMore();
                    });
                  },
                  child: Text(
                    "Search more",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (loadExtra)
                      isSearchLoading ? const Center(child: CircularProgressIndicator()): Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Light grey background color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Text(
                                  "Search Results",
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FSSearchResults.isEmpty
                                  ? Text(
                                "No Results",
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                itemCount: FSSearchResults.length,
                                itemBuilder: (context, index) {
                                  final friend = FSSearchResults[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: Image.asset(friend.profileImg),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                friend.name,
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                              Text(
                                                friend.id,
                                                style: Theme.of(context).textTheme.bodySmall,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
            ],
          ),
          bottomNavigationBar: CustomNavbar(
            onItemSelected: (route) {
              navigator.pushReplacementNamed(route);
            },
          ),
        );
      },
    );
  }
}

class Friend {
  final String profileImg;
  final String name;
  final String id;

  const Friend({
    required this.profileImg,
    required this.name,
    required this.id,
  });
}