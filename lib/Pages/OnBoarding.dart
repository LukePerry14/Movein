import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Welcome to MoveIn!",
              body: "Let's find you a house",
              image: buildImage("assets/Pictures/ph.png"),
              decoration: getPageDecoration(context),
            ),
            PageViewModel(
              title: "Using the group finder",
              body: "To see the basic info about a group, simply tap on the group name.",
              image: buildImage("assets/Pictures/ph.png"),
              decoration: getPageDecoration(context),
            ),
            PageViewModel(
                title: "Looking at individuals",
                body: "You can scroll through each group member on the main screen, and get an expanded look at their profile with a tap",
                image: buildImage("assets/Pictures/ph.png"),
                decoration: getPageDecoration(context),
            ),
            PageViewModel(
                title: "Interacting with the group",
                body: "for each group you can: \n 1. Remove them from your feed \n 2. Skip to the next group \n 3. Add them to a shortlist to check out later \n 4. Apply directly to the group (to a max of 3)",
                image: buildImage("assets/Pictures/ph.png"),
                decoration: PageDecoration(
                  pageColor: Theme.of(context).canvasColor,
                  imageFlex: 7,
                  bodyFlex: 4,
                ),
            ),
            PageViewModel(
                title: "Simple as that",
                body: "Happy Hunting!",
                image: buildImage("assets/Pictures/ph.png"),
                decoration: getPageDecoration(context),
            ),
          ],

          done: Text("Got it", style: Theme.of(context).textTheme.bodyMedium),
          onDone: () => goToHome(context),
          showSkipButton: true,
          skip: Text('Skip', style: Theme.of(context).textTheme.bodyMedium),
          onSkip: () => goToHome(context),
          next: const Icon(LineAwesomeIcons.arrow_right, color: Colors.black87),
          dotsDecorator: getDotDecoration(context),
        )
    );
  }

  Widget buildImage(String path) =>
      Center(child: Image.asset(path, width: 350));

  void goToHome(context) => Navigator.of(context).pushReplacementNamed('/Scroller');

  PageDecoration getPageDecoration(context) => PageDecoration(
    titleTextStyle: Theme.of(context).textTheme.headlineSmall ?? GoogleFonts.lexend(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20.0),
    bodyTextStyle: Theme.of(context).textTheme.bodyMedium ?? GoogleFonts.redHatDisplay(color: Colors.black87, fontSize: 16.5),
    imagePadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
    titlePadding: const EdgeInsets.all(4),
    bodyPadding: const EdgeInsets.all(8).copyWith(bottom: 0),
    pageColor: Theme.of(context).canvasColor,
    imageFlex: 10,
    bodyFlex: 3,
    footerFlex: 3,
      );

  DotsDecorator getDotDecoration(context) => DotsDecorator(
    color: Colors.grey,
    activeColor: Theme.of(context).primaryColor,
    size: const Size(8, 8),
    activeSize: const Size(18, 12), // Decrease the size a bit
    spacing: const EdgeInsets.symmetric(horizontal: 4), // Add some horizontal spacing between dots
    activeShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Adjust the border radius
    ),
  );

}