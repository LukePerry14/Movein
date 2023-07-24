// ignore: duplicate_ignore
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:movein/navbar.dart';

// These will be imported in from firebase
var universityNames = [
  'Durham',
  'Birmingham',
  'Bristol',
  'Manchester'
];

// This can remain local as it won't change
// ignore: non_constant_identifier_names
var YOS = [
  'Foundation Year',
  'Year 1',
  'Year 2',
  'Year 3',
  'Postgraduate'
];

var gender = [

  'Male',
  'Female',
  'Non-binary',
  'Transgender',
  'Prefer not to say'
];

var subject = [
  'Computer Science',
  'Maths',
  'English'
];

// These values will be imported from firebase and set for the user
String dropdownValue = universityNames[0];
String dropdownValue2 = YOS[0];
String genderValue = gender[0];
String subjectValue = subject[0];

class profileInformation extends StatefulWidget {
  const profileInformation({Key? key}) : super(key: key);

  @override
  State<profileInformation> createState() => _profileInformation();
}

class _profileInformation extends State<profileInformation> {
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          final navigator = Navigator.of(context);

          return Scaffold(
            appBar: AppBar( //maybe replace with a sliverappbar to improve polish
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
              actions: [
                PopupMenuButton(itemBuilder: (context)=>[
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
                ],onSelected: (item)=>chosenItem(context, item), color: Colors.white,
                )
              ],
            ),
            body: profileInformationPage(),
            // add body here
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

class profileInformationPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profileInformationPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        child: ListView(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 50
                ),
                const SizedBox(width: 10),
                const Text("Profile Information", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),)
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'John',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black
                )
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Smith',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black
                )
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(child: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
            ),
            const SizedBox(height: 15,),
            ElevatedButton(onPressed: _DateOfBirthPicker, child: const Text('Select your Date of Birth')),
            const SizedBox(height: 15),
            Center(
              child: Text(
                _selectedDate != null ? _selectedDate.toString() : 'No date selected', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
            ),
            const Center(child: genderDropdown()),
            const Divider(height: 20, thickness: 1),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(child: Text('University', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
            ),
            const Center(
              child: universityDropdown()
            ),
            const SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(child: Text('Year Of Study', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),),
            ),
            const Center(
              child: yearOfStudyDropdown(),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
            ),
            const Center(
              child: subjectDropdown(),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Edit Profile'),
            )
          ],
        ),
      ),
    );
  }
  // For Date Picker
  // ignore: non_constant_identifier_names
  void _DateOfBirthPicker() {
  showDatePicker(
    context: context, 
    initialDate: DateTime.now(), 
    firstDate: DateTime(1980), 
    lastDate: DateTime.now()).then(
      (choseDate) => {
        if (choseDate == null) {
          print('No date chosen')
        } else 
        setState(() {
          _selectedDate = choseDate;
        })
      });
  }
}

// UNIVERSITY DROPDOWN

class universityDropdown extends StatefulWidget {
  const universityDropdown({Key? key}) : super(key: key);

  @override
  State<universityDropdown> createState() => _universityDropdownMenu();
}

class _universityDropdownMenu extends State<universityDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownButton(
        value: dropdownValue,
        icon: const Icon(Icons.keyboard_arrow_down),
        items: universityNames.map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items),
          );
        }).toList(),
        onChanged: (String? newUniversityName) {
          setState(() {
            dropdownValue = newUniversityName!;
          });
        },
      ),
    );
  }
}

// YEAR OF STUDY DROPDOWN

class yearOfStudyDropdown extends StatefulWidget {
  const yearOfStudyDropdown({Key? key}) : super(key: key);
  @override
  State<yearOfStudyDropdown> createState() => _yearOfStudyDropdownMenu();
}

class _yearOfStudyDropdownMenu extends State<yearOfStudyDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownButton(
        value: dropdownValue2,
        icon: const Icon(Icons.keyboard_arrow_down),
        items: YOS.map((String year) {
          return DropdownMenuItem(
            value: year,
            child: Text(year),
          );
        }).toList(),
        onChanged: (String? newYOS) {
          setState(() {
            dropdownValue2 = newYOS!;
          });
        }
      ),
    );
  }
}

// GENDER DROPDOWN

class genderDropdown extends StatefulWidget {
  const genderDropdown({Key? key}) : super(key: key);
  @override
  State<genderDropdown> createState() => _genderDropdownMenu();
}

class _genderDropdownMenu extends State<genderDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: genderValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: gender.map((String selectedGender) {
        return DropdownMenuItem(
          value: selectedGender,
          child: Text(selectedGender),
        );
      }).toList(),
      onChanged: (String? newGender) {
        setState(() {
          genderValue = newGender!;
        });
      },
    );
  }
}

class subjectDropdown extends StatefulWidget {
  const subjectDropdown({Key? key}) : super(key: key);
  @override
  State<subjectDropdown> createState() => _subjectDropdownMenu();
}

class _subjectDropdownMenu extends State<subjectDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: subjectValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: subject.map((String selecetdSubject) {
        return DropdownMenuItem(
          value: selecetdSubject,
          child: Text(selecetdSubject),
        );
      }).toList(),
    onChanged: (String? newSubject) {
      setState(() {
        subjectValue = newSubject!;
      });
    },
    );
  }
}

void _submit() {
  // firebased editting code goes here
}