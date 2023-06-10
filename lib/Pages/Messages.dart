import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Map data = {};
  @override
  Widget build(BuildContext context) {

    //retrieves data from previous page to display relevant groupName
    data = ModalRoute.of(context)?.settings.arguments as Map;

    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            appBar: AppBar( //maybe replace with a sliverappbar to improve polish
              title: Text('${data['groupName']}', style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall),
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LineAwesomeIcons.angle_left),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  color: Colors.grey[500],
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  //Icon not showing
                  onPressed: () {
                    // Handle settings button press
                  },
                ),
              ],
            ),
            body: const SafeArea(
              child: Text('example Messages'),
            ),
          );

        }
    );
  }
}
