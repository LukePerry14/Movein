import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
//import 'package:money_converter/Currency.dart';
import 'package:movein/Themes/lMode.dart';
//import 'package:money_converter/money_converter.dart';

import '../UserPreferences.dart';

class Premium extends StatefulWidget {
  const Premium({Key? key}) : super(key: key);

  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  int _selectedIndex = 0;
  String current = UserPreferences.getLocale();
  String currency = "£";
  List<double> prices = [1.99, 7.99, 18.99];
  List<double> weeklyPrices = [1.99, 1.84, 1.46];
  List<int> periodLength = [1,1,3];
  List<String> periodName = ["week".tr, "month".tr, "months".tr];

  // @override
  // void initState() {
  //   if (current != "en"){
  //     currencyConverter(current);
  //   }
  //   super.initState();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          SizedBox(
              height: double.maxFinite,
              width: double.maxFinite,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: const [0.2, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: const GradientRotation(pi / 4),
                    colors: [
                      Theme.of(context).canvasColor,   // Start with white
                      LAppTheme.lightTheme.primaryColor,  // Transition to orange
                    ],
                  ),
                ),
              ) // Replace with your actual content
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height:70),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: -60,
                            left: MediaQuery.of(context).size.width * 0.025,
                            child: SizedBox(height: MediaQuery.of(context).size.width * 0.88, width: MediaQuery.of(context).size.width * 0.88, child: const Image(image: AssetImage("assets/Pictures/gradient.png")))
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).size.width * 0.52,
                          right: MediaQuery.of(context).size.width * 0.06,
                          child: Text(
                            "prem".tr,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFFFD700),
                                    ],
                                    stops: [0.3,0.7]
                                ).createShader(
                                  Rect.fromLTWH(0, 0, 200, 70),
                                ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -75,
                          left: 0,
                          right: 0,
                          child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: SizedBox(width: MediaQuery.of(context).size.width, child: Text("prem_desc".tr, style: Theme.of(context).textTheme.headlineLarge,))
                          ),
                        ),
                      ],
                    ),
                ),
                const SizedBox(height: 60),
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text("prem_desc2".tr, style: GoogleFonts.redHatDisplay(color: Colors.grey[600], fontSize: 14))
                ),
                const SizedBox(height:40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Text("select_plan".tr, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 5,
                                left: 7,
                                child: Text(
                                  "${"weekly-cost".tr} $currency${weeklyPrices[index]}",
                                  style: LAppTheme.darkTheme.textTheme.bodyMedium,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "${periodLength[index]} ${periodName[index]} - $currency${prices[index]}",
                                  style: LAppTheme.darkTheme.textTheme.headlineMedium,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Visibility(
                                  visible: (index == _selectedIndex),
                                  child: const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Icon(
                                      LineAwesomeIcons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Add the glowing effect layer
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: (index == _selectedIndex)? 2: 0.5,
                                    ),
                                    boxShadow: [
                                      (index == _selectedIndex)?
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.11), // Adjust opacity
                                        spreadRadius: 5, // Adjust spread radius
                                        blurRadius: 10, // Adjust blur radius
                                        offset: const Offset(0, 0),
                                      ) : const BoxShadow(
                                        color: Colors.transparent // Adjust opacity
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height:35),
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text("conf_desc".tr, style: GoogleFonts.redHatDisplay(color: Colors.grey[600], fontSize: 10))
                ),
                //const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    // Add your onPressed action here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(25.0), // Semi-circular left side
                        right: Radius.circular(25.0), // Semi-circular right side
                      ),
                    ),
                      backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.white.withOpacity(0.8), width: 0.5),// Set the background color to transparent
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomCenter,
                          colors: [
                            LAppTheme.lightTheme.primaryColor
                                .withAlpha(150),
                            LAppTheme.lightTheme.primaryColor
                                .withAlpha(200),
                            LAppTheme.lightTheme.primaryColor,
                            LAppTheme.lightTheme.primaryColor,
                          ],
                          stops:  const [
                            0.1,
                            0.3,
                            0.9,
                            1.0
                          ]),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(25.0), // Semi-circular left side
                        right: Radius.circular(25.0), // Semi-circular right side
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${"confirm".tr} - $currency${prices[_selectedIndex].toString()}",
                        style: LAppTheme.darkTheme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height:30),
              ]
            ),
          ),
          Positioned(
            top: 15,
              left: 15,
              child: IconButton(
                icon: const Icon(LineAwesomeIcons.angle_down),
                onPressed: () {
                  Navigator.pop(context);
                  },
                color: Theme.of(context).primaryColor,
              )
          ),
        ],
      ),
      );
  }
  //
  // void currencyConverter(String currency) async{
  //   late String nCurrency;
  //   late List<dynamic> vals;
  //   switch (currency){
  //     case 'fr' :
  //       nCurrency = "€";
  //       vals = await valueChanges(Currency(Currency.EUR));
  //       break;
  //     case 'es' :
  //       nCurrency = "€";
  //       vals = await valueChanges(Currency(Currency.EUR));
  //       break;
  //     case 'zh' :
  //       nCurrency = "¥";
  //       vals = await valueChanges(Currency(Currency.CNY));
  //       break;
  //     case 'hi' :
  //       nCurrency = "₹";
  //       vals = await valueChanges(Currency(Currency.INR));
  //       break;
  //   }
  //
  //   setState(() {
  //     currency = nCurrency;
  //     prices = vals[0];
  //     weeklyPrices = vals[1];
  //   });
  // }
  // Future<List<dynamic>> valueChanges(Currency cur) async{
  //   late double? conversion;
  //   late List<double> nPrices;
  //   late List<double> nWeeklyPrices;
  //   conversion = await MoneyConverter.convert(Currency(Currency.GBP, amount: 1), cur);
  //   print(conversion);
  //   nPrices = prices.map((double value) {
  //     return (value * conversion!).toStringAsFixed(2);
  //   }).map(double.parse).toList();
  //
  //   nWeeklyPrices = prices.map((double value) {
  //     return (value * conversion!).toStringAsFixed(2);
  //   }).map(double.parse).toList();
  //
  //   return [nPrices, nWeeklyPrices];
  // }
}


