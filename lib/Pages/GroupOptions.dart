import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/profile-data.dart';

class GroupOptions extends StatefulWidget {
  const GroupOptions({Key? key}) : super(key: key);

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {
  Map data = {};

  void gNameChange(){

  }
  @override
  Widget build(BuildContext context) {

    data = ModalRoute.of(context)?.settings.arguments as Map;
    var names = [];
    var ids = [];
    data['members'].forEach((k,v) {
      ids.add(k);
      names.add(v);
    });

    //Example Data

    List<Profile> applicants = [
      Profile(id: '8591', userName: 'Greg', userAge: 21, userDescription: 'likes long wanks', profileImageSrc: 'assets/Pictures/ph.png'),
      Profile(id: '8591', userName: 'Greg', userAge: 21, userDescription: 'likes long wanks', profileImageSrc: 'assets/Pictures/ph.png'),
      Profile(id: '8591', userName: 'Greg', userAge: 21, userDescription: 'likes long wanks', profileImageSrc: 'assets/Pictures/ph.png'),
    ];

    List<Profile> kicks = [
      Profile(id: '8591', userName: 'Greg', userAge: 21, userDescription: 'likes long wanks', profileImageSrc: 'assets/Pictures/ph.png'),
      Profile(id: '8591', userName: 'Greg', userAge: 21, userDescription: 'likes long wanks', profileImageSrc: 'assets/Pictures/ph.png'),
      Profile(id: '8591', userName: 'Greg', userAge: 21, userDescription: 'likes long wanks', profileImageSrc: 'assets/Pictures/ph.png'),
    ];


    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,

        leading: IconButton(
          icon: const Icon(LineAwesomeIcons.angle_left),
          color: Colors.grey[500],
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
            body: SingleChildScrollView(
              child: Column(
                children: [

                  Stack( // Group picture
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("testing");
                        },
                        child: SizedBox(
                          width: 100, height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const Image(image: AssetImage("assets/Pictures/ph.png")),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(LineAwesomeIcons.pen_nib,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  GestureDetector(
                    onTap: () {
                      gNameChange();
                    },
                    child: Text("${data['groupName']}", style: Theme.of(context).textTheme.headlineSmall),

                  ),

                  const SizedBox(height: 30.0),

                  Container(
                      color: Theme.of(context).primaryColor,
                      height: 1.0,
                  ),

                  const SizedBox(height: 20.0),

                  Row(
                    children: [
                      const SizedBox(width: 13),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Members", style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),


                  // Group Members builder
                  LayoutBuilder( //Members constructor
                    builder: (context, constraints) {

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: names.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    //open sub-menu for profile related activities
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50, height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: const Image(image: AssetImage("assets/Pictures/ph.png")),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${names[index]}", style: Theme.of(context).textTheme.headlineSmall,),
                                            Text("${ids[index]}", style: Theme.of(context).textTheme.bodySmall,)
                                          ],
                                        )
                                      ],

                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      );
                    }
                  ),

                  const SizedBox(height: 20.0),

                  Row(
                    children: [
                      const SizedBox(width: 13),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Votes", style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),

                  // Votes Builder
                  LayoutBuilder( // Voting Section
                      builder: (context, constraints) {

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: applicants.length + kicks.length + 2,
                                itemBuilder: (context, index) {
                                  if (index == 0){
                                    return Text("Applications", style: Theme.of(context).textTheme.bodyLarge);
                                  }
                                  else if (index < applicants.length+1){
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50, height: 50,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: Image(image: AssetImage(applicants[index-1].profileImageSrc)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(applicants[index-1].userName, style: Theme.of(context).textTheme.headlineSmall,),
                                              Text(applicants[index-1].id, style: Theme.of(context).textTheme.bodySmall,)
                                            ],
                                          )
                                        ],

                                      ),
                                    );
                                  }
                                  else if (index == applicants.length+1){
                                    return Text("Kicks", style: Theme.of(context).textTheme.bodyLarge);
                                  }
                                  else{
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50, height: 50,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: Image(image: AssetImage(kicks[index-applicants.length-2].profileImageSrc)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(kicks[index-applicants.length-2].userName, style: Theme.of(context).textTheme.headlineSmall,),
                                              Text(kicks[index-applicants.length-2].id, style: Theme.of(context).textTheme.bodySmall,)
                                            ],
                                          )
                                        ],

                                      ),
                                    );
                                  }
                                }
                            ),
                          ),
                        );
                      }
                  ),

                  const SizedBox(width: 20),

                  //Configuration buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0.0, 10.0, 0.0),

                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          gNameChange();
                        },
                        title: Text("Edit Group Name", style: Theme.of(context).textTheme.bodyMedium,),
                      ),

                      ListTile(
                        onTap: () {
                          // edit leave group
                        },
                        title: Text("Leave Group", style: GoogleFonts.roboto(color: Colors.red, fontSize: 16.5)),
                      ),
                    ],

                  ),
                  ),



                ],
              ),
            ),

          );
        }
  }

