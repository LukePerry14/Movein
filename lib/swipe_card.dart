import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {
  final String id;
  final String foreName;
  final int age;
  final String uni;
  final Map<String,dynamic> preferences;
  final String bio;
  final String subject;
  final int yearOfStudy;
  final List<String> images;

  const SwipeCard({
    Key? key,
    required this.id,
    required this.foreName,
    required this.age,
    required this.uni,
    required this.preferences,
    required this.images,
    required this.bio,
    required this.subject,
    required this.yearOfStudy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = width; // Calculate the height based on the width

        return GestureDetector(
          onTap: () {
            _showImageScreen(context);
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 67, 67, 67),
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                )
              ],
              image: const DecorationImage(
                image: AssetImage("assets/Pictures/ph.png"), //replace with images[0] when we figure out image storage
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                    child: Row(
                      children: [
                        Text(
                          "$foreName  $age",
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
                      bio,
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
          ),
        );
      },
    );
  }

  void _showImageScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Images'),
          ),
          body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              return Image.asset(images[index]);
            },
          ),
        );
      },
    ));
  }
}
