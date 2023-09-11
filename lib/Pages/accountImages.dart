import 'dart:async';
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
    await x.deleteBlob('/moveinimages/$fileString.jpg');
  } catch (e) {
    print('Exception: $e');
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

            // network paths to user's images
            var image1path = '$rootImagePath$image1';
            var image2path = '$rootImagePath$image2';

            return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    centerTitle: true,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(LineAwesomeIcons.angle_left, color: Colors.white,),
                      color: Colors.grey[500],
                      onPressed: (() {
                        Navigator.pop(context);
                      })
                    ),
                  ),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
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
                          Row(
                            children: [
                              Text('Image 1'.tr, style: Theme.of(context).textTheme.headlineMedium,),
                            ],
                          ),
                          Container(
                            height: 300,
                            width: 550,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: accountPicture1 == null ? Image.network(image1path) : defaultProfilePicture
                          ),
                          const SizedBox(height: 10,),
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedImage = await pickImage();
                                if (pickedImage != null) {
                                  // Firebase edit needs to occur here
                                  accountPicture1String = _uploadImageToAzure2(pickedImage) as String?;
                                  _deleteProfileImageFromAzure(image1url!);
                                  // to be added to Images[1]
                                  setState(() {
                                    accountPicture1 = pickedImage;
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
                          Row(
                            children: [
                              Text('Image 2'.tr, style: Theme.of(context).textTheme.headlineMedium,),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Container(
                            height: 300,
                            width: 550,
                            decoration: const BoxDecoration(shape:  BoxShape.circle),
                            child: accountPicture2 == null? Image.network(image2path) : defaultProfilePicture
                          ), 
                          const SizedBox(height: 10,),
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedImage = await pickImage();
                                if (pickedImage != null) {
                                  // Firebase edit needs to occur here
                                  accountPicture1String =  _uploadImageToAzure2(pickedImage) as String?;
                                  _deleteProfileImageFromAzure(image2url!);
                                  // To be added to Images[2]
                                  setState(() {
                                    accountPicture2 = pickedImage;
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