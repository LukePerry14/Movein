import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:azstore/azstore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import '../Ad code/ad_helper.dart';
import '../Auth code/auth.dart';
import '../Themes/lMode.dart';
import '../main.dart';

const rootImagePath = 'https://movein.blob.core.windows.net/moveinimages/';

Future<File?> pickImage() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    return File(image.path);
  } else {
    print('No image selected.');
    return null;
  }
}

Future<void> _uploadImageToAzure(File imageFile) async {
  Uint8List bytes = imageFile.readAsBytesSync();
  var x = AzureStorage.parse(
      'DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net');
  try {
    var uuid = const Uuid();
    String imageName = uuid.v1();
    await x.putBlob('/moveinimages/$imageName.jpg',
        contentType: 'image/jpg', bodyBytes: bytes);
  } catch (e) {
    print('Exception: $e');
  }
}

// For returning the string name for firebase upload
Future<String?> _uploadImageToAzure2(File imageFile) async {
  Uint8List bytes = imageFile.readAsBytesSync();
  var x = AzureStorage.parse(
      'DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net');
  try {
    var uuid = const Uuid();
    String imageName = uuid.v1();
    await x.putBlob('/moveinimages/$imageName.jpg', contentType: 'image/jpg', bodyBytes: bytes);
    return '$imageName.jpg';
  } catch (e) {
    return ('Exception: $e');
  }
}

Future<void> _deleteProfileImageFromAzure(String fileString) async {
  var x = AzureStorage.parse(
    'DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net'
    );
  try {
    await x.deleteBlob('/moveinimages/$fileString');
  } catch (e) {
    print('Exception: $e');
  }
}

Future<void> updateImage(imageArray) async {
  try {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(Auth().currentUser())
        .update({
      'Images': imageArray
    });
  } catch (e) {
    throw FirebaseException(
      message: 'Error saving user data: $e',
      plugin: 'cloud_firestore',
    );
  }
}

// ignore: camel_case_types
class accountImages extends StatefulWidget {
  const accountImages({super.key});

  @override
  State<accountImages> createState() => _accountImages();
}

class _accountImages extends State<accountImages> {
  @override
  File? _profileImage;
  File? accountPicture1;
  File? accountPicture2;
  String? profilePictureString;
  String? accountPicture1String;
  String? accountPicture2String;
  String? image1url;
  String? image2url;
  var defaultProfilePicture = Image.asset('assets/Pictures/turt.png');

  Future<List<String>> getNameAndPic() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(Auth().currentUser())
          .get();

      String foreName = userDoc.get("ForeName");
      String surname = userDoc.get("SurName");
      String profPic = userDoc.get("Images")[0];
      String picture1 = userDoc.get("Images")[1];
      String picture2 = userDoc.get("Images")[2];
      String fullName = "$foreName $surname";

      return [fullName, profPic, picture1, picture2];
    } catch (e) {
      throw FirebaseException(
          message: 'Error retrieving name or profile picture: $e',
          plugin: 'cloud_firestore');
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getNameAndPic(),
      builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var data = snapshot.data;
            // Other images for the user
            var image1 = data![2];
            var image2 = data[3];

            List<String?> imageArray = [];

            imageArray.add(data[1]);
            imageArray.add(data[2]);
            imageArray.add(data[3]);

            // network paths to user's images
            var image1path = '$rootImagePath$image1';
            var image2path = '$rootImagePath$image2';

            if (image1 == null) {
              image1path = '';
            }

            if (image2 == null) {
              image2path = '';
            }
            

            return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(LineAwesomeIcons.angle_left, color: Theme.of(context).primaryColor,),
                      color: Colors.grey[500],
                      onPressed: (() {
                        Navigator.pop(context);
                      })
                    ),
                  ),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: Theme.of(context).primaryColor,
                                size: 50,
                              ),
                              const SizedBox(width: 10),
                              Text("Account Images".tr, style: Theme.of(context).textTheme.headlineLarge,)
                            ],
                          ),
                          const Divider(height: 20, thickness: 1),
                          const SizedBox(height: 10,),
                          const SizedBox(height: 10,),
                          Container(
                            height: 400,
                            width: 550,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(40)),
                              image: DecorationImage(
                                image: image1path == '' ? const NetworkImage('https://movein.blob.core.windows.net/moveinimages/noimagefound.png') : NetworkImage(image1path)
                              )
                            ),
                          ),
                          const SizedBox(height: 10,),
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedImage = await pickImage();
                                if (pickedImage != null) {
                                  accountPicture1String = await _uploadImageToAzure2(pickedImage);
                                  imageArray[1] = accountPicture1String;
                                  updateImage(imageArray);
                                  _deleteProfileImageFromAzure(image1);
                                  setState(() {
                                    image1path = '$rootImagePath$accountPicture1String';
                                  });
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(Icons.edit),
                              ),
                            ),
                          ), 
                          const SizedBox(height: 40,),
                          const SizedBox(height: 10,),
                          Container(
                            height: 400,
                            width: 550,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(40)),
                              image: DecorationImage(
                                image: image2path == '' ? const NetworkImage('https://movein.blob.core.windows.net/moveinimages/noimagefound.png') : NetworkImage(image2path)
                              )
                            ),
                          ), 
                          const SizedBox(height: 10,),
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedImage = await pickImage();
                                if (pickedImage != null) {
                                  accountPicture2String = await _uploadImageToAzure2(pickedImage);
                                  imageArray[2] = accountPicture2String;
                                  updateImage(imageArray);
                                  _deleteProfileImageFromAzure(image2);
                                  setState(() {
                                    image2path = '$rootImagePath$accountPicture2String';
                                  });
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        }
      },
    );
  }
}