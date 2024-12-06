import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const double minItn = 1.000;
const double maxItn = 10.300;

const List<Widget> modeIcons = <Widget>[
  Icon(Icons.person, size: 30),
  Icon(Icons.group, size: 30),
];

const List<Widget> successIcons = <Widget>[
  Icon(Icons.emoji_events, color: Color.fromARGB(255, 183, 156, 2), size: 30),
  Icon(Icons.dangerous, color: Colors.red, size: 30),
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'ITN Calculator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<bool> selectedMode = <bool>[true, false];
  final List<bool> selectedSuccess = <bool>[true, false];
  var itnUser = 0.0;
  var itnPartner = 0.0;
  var itnOpponent1 = 0.0;
  var itnOpponent2 = 0.0;
  var itnChangeOfUser = double.nan;

  bool calculateItnChange(bool userWon) {
    if (itnUser < minItn ||
        itnUser > maxItn ||
        itnOpponent1 < minItn ||
        itnOpponent1 > maxItn) {
      itnChangeOfUser = double.nan;
      return false;
    }

    // Single mode calculation
    if (selectedMode[0]) {
      var x = userWon ? itnOpponent1 - itnUser : itnUser - itnOpponent1;
      itnChangeOfUser = 0.250 / (1.000 + 2.595 * exp(3.500 * x));

      // TODO: Simplify
      if (!userWon && itnUser + itnChangeOfUser > maxItn) {
        itnChangeOfUser = maxItn - itnUser;
      } else if (userWon && itnUser - itnChangeOfUser < minItn) {
        itnChangeOfUser = itnUser - minItn;
      }

      notifyListeners();
      return true;
    }

    // Double mode calculation
    else if (selectedMode[1]) {
      if (itnPartner < minItn ||
          itnPartner > maxItn ||
          itnOpponent2 < minItn ||
          itnOpponent2 > maxItn) {
        itnChangeOfUser = double.nan;
        return false;
      }

      var userDoubleItn = (itnUser + itnPartner) / 2;
      var opponentDoubleItn = (itnOpponent1 + itnOpponent2) / 2;

      var x = userWon
          ? opponentDoubleItn - userDoubleItn
          : userDoubleItn - opponentDoubleItn;
      itnChangeOfUser = (0.250 / (1.000 + 2.595 * exp(3.500 * x))) * 0.25;

      // TODO: Simplify
      if (!userWon && itnUser + itnChangeOfUser > maxItn) {
        itnChangeOfUser = maxItn - itnUser;
      } else if (userWon && itnUser - itnChangeOfUser < minItn) {
        itnChangeOfUser = itnUser - minItn;
      }

      notifyListeners();
      return true;
    }

    itnChangeOfUser = double.nan;
    return false;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = WelcomeHomePage();
      case 1:
        page = ITNCalculatorPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
                appState.calculateItnChange(appState.selectedSuccess[0]);
              });
            },
            indicatorColor: Theme.of(context).colorScheme.inversePrimary,
            selectedIndex: selectedIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.calculate_rounded),
                icon: Icon(Icons.calculate_outlined),
                label: 'ITN Calculator',
              ),
            ]),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/home.jpg'), fit: BoxFit.cover),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Center(
                child: ListView(shrinkWrap: true, children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [page],
                  ),
                ]),
              ),
            )),
      );
    });
  }
}

class WelcomeHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: ColoredBox(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Welcome to ITN Calculator',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30.0,
                      ),
                    ),
                  )))
        ],
      ),
    );
  }
}

class ITNCalculatorPage extends StatefulWidget {
  @override
  State<ITNCalculatorPage> createState() => _ITNCalculatorPageState();
}

class _ITNCalculatorPageState extends State<ITNCalculatorPage> {
  final TextEditingController itnUserController = TextEditingController();
  final TextEditingController itnPartnerController = TextEditingController();
  final TextEditingController itnOpponent1Controller = TextEditingController();
  final TextEditingController itnOpponent2Controller = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free resources
    itnUserController.dispose();
    itnPartnerController.dispose();
    itnOpponent1Controller.dispose();
    itnOpponent2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
      child: ColoredBox(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                'ITN Calculator',
                style: TextStyle(color: Colors.black, fontSize: 35.0),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < appState.selectedMode.length; i++) {
                          appState.selectedMode[i] = i == index;
                        }

                        // Clear the TextEditingControllers
                        itnUserController.clear();
                        itnPartnerController.clear();
                        itnOpponent1Controller.clear();
                        itnOpponent2Controller.clear();

                        // Reset the appState values
                        appState.itnUser = 0.0;
                        appState.itnPartner = 0.0;
                        appState.itnOpponent1 = 0.0;
                        appState.itnOpponent2 = 0.0;
                        appState.itnChangeOfUser = double.nan;

                        appState
                            .calculateItnChange(appState.selectedSuccess[0]);
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    selectedColor: Colors.black,
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    color: Theme.of(context).colorScheme.secondary,
                    borderWidth: 2,
                    isSelected: appState.selectedMode,
                    children: modeIcons,
                  ),
                  SizedBox(width: 60),
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0;
                            i < appState.selectedSuccess.length;
                            i++) {
                          appState.selectedSuccess[i] = i == index;
                        }

                        appState
                            .calculateItnChange(appState.selectedSuccess[0]);
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    borderWidth: 2,
                    isSelected: appState.selectedSuccess,
                    children: successIcons,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: getItnTextField(appState, itnUserController,
                    'Your ITN', (value) => appState.itnUser = value),
              ),
              if (appState.selectedMode[1]) ...[
                SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: getItnTextField(
                        appState,
                        itnPartnerController,
                        'ITN of your partner',
                        (value) => appState.itnPartner = value))
              ],
              SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: getItnTextField(
                      appState,
                      itnOpponent1Controller,
                      'ITN of your opponent',
                      (value) => appState.itnOpponent1 = value)),
              if (appState.selectedMode[1]) ...[
                SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: getItnTextField(
                        appState,
                        itnOpponent2Controller,
                        'ITN of your opponent',
                        (value) => appState.itnOpponent2 = value))
              ],
              SizedBox(height: 20),
              Text(
                  style: TextStyle(
                      fontSize: 35,
                      color: appState.selectedSuccess[0]
                          ? Colors.green
                          : Colors.red),
                  appState.itnChangeOfUser.isNaN
                      ? ''
                      : appState.selectedSuccess[0]
                          ? '- ${appState.itnChangeOfUser.toStringAsFixed(3)} ⟶ ${(appState.itnUser - appState.itnChangeOfUser).toStringAsFixed(3)}'
                          : '+ ${appState.itnChangeOfUser.toStringAsFixed(3)} ⟶ ${(appState.itnUser + appState.itnChangeOfUser).toStringAsFixed(3)}'),
              SizedBox(height: 20),
            ],
          )),
    );
  }

  TextField getItnTextField(
      MyAppState appState,
      TextEditingController controller,
      String label,
      void Function(double) onChangedCallback) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: label,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
          LengthLimitingTextInputFormatter(6),
          NumericalRangeFormatter(min: minItn, max: maxItn)
        ],
        onChanged: (value) {
          setState(() {
            onChangedCallback(double.tryParse(value) ?? 0.0);
            appState.calculateItnChange(appState.selectedSuccess[0]);
          });
        });
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (RegExp(r'^\d\.\d\d\d\d$').hasMatch(newValue.text) ||
        RegExp(r'^\.').hasMatch(newValue.text)) {
      return oldValue;
    } else if (newValue.text == '') {
      return newValue;
    } else if (double.parse(newValue.text) < min) {
      return TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return double.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}
