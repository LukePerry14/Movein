import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/navbar.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
              const Text("Settings", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22))
            ],
          ),
          const Divider(height: 20, thickness: 1),
          const SizedBox(height: 10),
          buildAccountOption(context, 'Change Password'),
          buildAccountOption(context, 'Change Email'),
          buildAccountOption(context, 'Language'),
          buildAccountOption(context, 'Premium'),
          buildAccountOption(context, 'Privacy and Security'),
          buildAccountOption(context, 'Terms and Conditions'),
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