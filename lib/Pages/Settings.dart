import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/UserPreferences.dart';
import 'package:movein/navbar.dart';

import '../Themes/lMode.dart';

class SettingsScaffold extends StatefulWidget {
  const SettingsScaffold({Key? key}) : super(key: key);

  @override
  State<SettingsScaffold> createState() => _SettingsScaffoldState();
}

class _SettingsScaffoldState extends State<SettingsScaffold> {
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).canvasColor,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: Icon(LineAwesomeIcons.angle_left, color: Theme.of(context).primaryColor),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                PopupMenuButton(
                  icon: Icon(LineAwesomeIcons.vertical_ellipsis, color: Theme.of(context).primaryColor,),
                  color: Colors.grey[200],
                  itemBuilder: (context)=>[
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text('About'),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text('FAQs'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('TBC'),
                    )
                  ],
                  onSelected: (item)=>chosenItem(context, item),
                )
              ],
            ),
            body: 
              SettingsPage()
            ,
            bottomNavigationBar: CustomNavbar(
              onItemSelected: (route) {
                navigator.pushReplacementNamed(route);
              },
            ),

          );
        }
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          const SizedBox(height:30),
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
              const SizedBox(width: 10),
              Text("settings".tr, style: Theme.of(context).textTheme.headlineLarge)
            ],
          ),
          const Divider(height: 20, thickness: 1),
          const SizedBox(height: 10),
          buildChangePassword(context, 'Change Password'),
          //buildChangeEmail(context, 'Change Email'),
          buildChangeLanguage(context, 'language'.tr),
          buildReviewAds(context, 'premium'.tr),
          buildAccountOption(context, 'privacy'.tr),
          buildAccountOption(context, 't&c'.tr),
        ],
      ),
    );
  }
}


// Template for making a settings button
GestureDetector buildAccountOption(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Option'),
              Text('Option')
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            )
          ],
        );
      });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey)
        ],
      ),
    ),
  );
}

// For Change password button
GestureDetector buildChangePassword(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      showDialog(context: context, builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(LineAwesomeIcons.angle_left, color: Colors.white),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text('change-password'.tr, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'password'.tr
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password'
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {print('The password has changed');},
                    child: const Text('Change Password'),
                  )
                ],
              ),
            ),
          )
        );
      });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey)
        ],
      ),
    ),
  );
}

GestureDetector buildChangeEmail(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      showDialog(context: context, builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(LineAwesomeIcons.angle_left, color: Colors.white),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  const Text('Change Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 20),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email'
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {print('The email has changed');},
                    child: const Text('Change Email'),
                  )
                ],
              ),
            ),
          )
        );
      });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey)
        ],
      ),
    ),
  );
}

GestureDetector buildChangeLanguage(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height:5),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(LineAwesomeIcons.angle_left, color: Theme.of(context).primaryColor),
                        color: Colors.grey[500],
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                        child: Text('language'.tr, style: Theme.of(context).textTheme.headlineSmall)
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioLanguage(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey)
        ],
      ),
    ),
  );
}

GestureDetector buildReviewAds(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      showDialog(context: context, builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(LineAwesomeIcons.angle_left, color: Colors.white),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  const Text('Advertisements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 20),
                  const Text('Information about how ads work here'),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(onPressed: () => {print('Takes them to unime website to update adveritsement')}, child: const Text('Upgrade Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)),
                  )
                ],
              ),
            ),
          )
        );
      });
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey)
        ],
      ),
    ),
  );
}

chosenItem(BuildContext context, item) {
  switch(item) {
    case 0: print('This will link to the about section on the UniMe Website');
    break;
    case 1: print('FAQs section of unime website loads');
    break;
    case 2: print('no idea yet');
    break;
  }
}

class RadioLanguage extends StatefulWidget {
  const RadioLanguage({super.key});

  @override
  State<RadioLanguage> createState() => _RadioLanguageState();
}

enum SingingCharacter { english, french, hindi, mandarin, spanish, }

class _RadioLanguageState extends State<RadioLanguage> {
  String? current;
  SingingCharacter? _character;
  @override
  void initState() {
    super.initState();
    current = UserPreferences.getLocale();
    _character = _getSingingCharacterFromLocale(current);
  }

  void _updateLocaleAndRebuild(String languageCode) async {
    await UserPreferences.setLocale(languageCode);
    Get.updateLocale(Locale(languageCode));
    setState(() {
      current = languageCode;
      _character = _getSingingCharacterFromLocale(current);
    });
  }

  SingingCharacter? _getSingingCharacterFromLocale(String? languageCode) {
    if (languageCode == null) return null;
    switch (languageCode) {
      case 'en':
        return SingingCharacter.english;
      case 'fr':
        return SingingCharacter.french;
      case 'es':
        return SingingCharacter.spanish;
      case 'zh':
        return SingingCharacter.mandarin;
      case 'hi':
        return SingingCharacter.hindi;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('English'),
          leading: Radio<SingingCharacter>(
            activeColor: LAppTheme.lightTheme.primaryColor,
            groupValue: _character,
            value: SingingCharacter.english,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
                _updateLocaleAndRebuild("en");
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Français'),
          leading: Radio<SingingCharacter>(
            activeColor: LAppTheme.lightTheme.primaryColor,
            groupValue: _character,
            value: SingingCharacter.french,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
                _updateLocaleAndRebuild("fr");
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Español'),
          leading: Radio<SingingCharacter>(
            activeColor: LAppTheme.lightTheme.primaryColor,
            groupValue: _character,
            value: SingingCharacter.spanish,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
                _updateLocaleAndRebuild("es");
              });
            },
          ),
        ),
        ListTile(
          title: const Text('普通话'),
          leading: Radio<SingingCharacter>(
            activeColor: LAppTheme.lightTheme.primaryColor,
            groupValue: _character,
            value: SingingCharacter.mandarin,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
                _updateLocaleAndRebuild("zh");
              });
            },
          ),
        ),
        ListTile(
          title: const Text('हिंदी'),
          leading: Radio<SingingCharacter>(
            activeColor: LAppTheme.lightTheme.primaryColor,
            groupValue: _character,
            value: SingingCharacter.hindi,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
                _updateLocaleAndRebuild("hi");
              });
            },
          ),
        )
      ],
    );
  }
}