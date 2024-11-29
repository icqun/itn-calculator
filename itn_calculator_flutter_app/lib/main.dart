import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const List<Widget> modeIcons = <Widget>[
  Icon(Icons.person, size: 30),
  Icon(Icons.group, size: 30),
];

const List<Widget> successIcons = <Widget>[
  Icon(Icons.check, color: Colors.green, size: 30),
  Icon(Icons.close, color: Colors.red, size: 30),
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
    if (itnUser < 1.0 || itnUser > 10.3 || itnOpponent1 < 1.0 || itnOpponent1 > 10.3) {
      itnChangeOfUser = double.nan;
      return false;
    }
    
    // Single mode calculation
    if (selectedMode[0]) {
      var x = userWon ? itnOpponent1 - itnUser : itnUser - itnOpponent1;
      itnChangeOfUser = 0.250 / (1.000 + 2.595 * exp(3.500 * x));
      notifyListeners();
      return true;
    }
    
    // Double mode calculation
    else if (selectedMode[1]) {
      if (itnPartner < 1.0 || itnPartner > 10.3 || itnOpponent2 < 1.0 || itnOpponent2 > 10.3) {
        itnChangeOfUser = double.nan;
        return false;
      }

      var userDoubleItn = (itnUser + itnPartner) / 2;
      var opponentDoubleItn = (itnOpponent1 + itnOpponent2) / 2;

      var x = userWon ? opponentDoubleItn - userDoubleItn : userDoubleItn - opponentDoubleItn;
      itnChangeOfUser = (0.250 / (1.000 + 2.595 * exp(3.500 * x))) * 0.25;
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
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = WelcomeHomePage();
        break;
      case 1:
        page = ITNCalculatorPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate_rounded),
                      label: Text('ITN Calculator'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class WelcomeHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome to ITN Calculator",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22.0
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            ],
          ),
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
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Text(
              "ITN Calculator",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22.0
              ),
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

                      appState.calculateItnChange(appState.selectedSuccess[0]);
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  selectedColor: Colors.black,
                  fillColor: Theme.of(context).colorScheme.inversePrimary,
                  color: Theme.of(context).colorScheme.secondary,
                  borderWidth: 2,
                  isSelected: appState.selectedMode,
                  children: modeIcons,
                ),
                SizedBox(width: 30),
                ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < appState.selectedSuccess.length; i++) {
                        appState.selectedSuccess[i] = i == index;
                      }

                      appState.calculateItnChange(appState.selectedSuccess[0]);
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  fillColor: Theme.of(context).colorScheme.inversePrimary,
                  borderWidth: 2,
                  isSelected: appState.selectedSuccess,
                  children: successIcons,
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: getITNTextFormField(appState, 'Your ITN', (value) => appState.itnUser = value),
            ),
            if (appState.selectedMode[1]) ...[
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: getITNTextFormField(appState, 'ITN of your partner', (value) => appState.itnPartner = value)
              )
            ],
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: getITNTextFormField(appState, 'ITN of your opponent', (value) => appState.itnOpponent1 = value)
            ),
            if (appState.selectedMode[1]) ...[
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: getITNTextFormField(appState, 'ITN of your opponent', (value) => appState.itnOpponent2 = value)
              )
            ],
            SizedBox(height: 20),
            Text(
              style: TextStyle(
                fontSize: 50,
                color: appState.selectedSuccess[0]
                  ? Colors.green
                  : Colors.red
              ),
              appState.itnChangeOfUser.isNaN
                ? ""
                : appState.selectedSuccess[0]
                  ? '- ${appState.itnChangeOfUser.toStringAsFixed(3)}'
                  : '+ ${appState.itnChangeOfUser.toStringAsFixed(3)}'
            )
          ],
        ),
      )
    );
  }

  Future<dynamic> showErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Please enter valid ITN\'s between 1.000 and 10.300'),
              const SizedBox(height: 7),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      )
    );
  }

  TextFormField getITNTextFormField(MyAppState appState, String label, void Function(double) onChangedCallback) {
    return TextFormField(
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: label,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
        LengthLimitingTextInputFormatter(6)
      ],
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        double itn = double.tryParse(value ?? "") ?? 0;
        return RegExp(r'^\d{0,2}(\.\d{3})?$').hasMatch(itn.toString()) || itn >= 1.000 && itn <= 10.300 ? null : 'Invalid value';
      },
      onChanged: (value) {
        setState(() {
          onChangedCallback(double.tryParse(value) ?? 0.0);
          appState.calculateItnChange(appState.selectedSuccess[0]);
        });
      },
    );
  }
}
