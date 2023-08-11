import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../Themes/lMode.dart';


class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Map data = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    data = ModalRoute.of(context)?.settings.arguments as Map;
  }

  @override
  Widget build(BuildContext context) {

    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            appBar: AppBar(
              title: Text('${data['groupName']}', style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Theme.of(context).canvasColor,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: LAppTheme.lightTheme.primaryColor,
                  height: 1.0,
                ),
              ),
              leading: IconButton(
                icon: Icon(LineAwesomeIcons.angle_left, color: LAppTheme.lightTheme.primaryColor,),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  color: Colors.grey[500],
                  icon: Icon(Icons.more_vert, color: LAppTheme.lightTheme.primaryColor),
                  //Icon not showing
                  onPressed: () {
                    Navigator.pushNamed(context, '/GroupOptions', arguments: {
                      'members': data['members'],
                      'groupId': data['groupId'],
                      'groupName': data['groupName'],
                      'groupPicture' : data['groupPicture'],
                    });
                  },
                ),
              ],
            ),
            body: const SafeArea(
              child: Text("example")
            ),
          );

        }
    );
  }
}