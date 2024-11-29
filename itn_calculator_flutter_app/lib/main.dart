import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const List<Widget> icons = <Widget>[
  Icon(Icons.person),
  Icon(Icons.group),
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
  var itnUser = 0.0;
  var itnPartner = 0.0;
  var itnOpponent1 = 0.0;
  var itnOpponent2 = 0.0;

  final List<bool> selectedMode = <bool>[true, false];

  double calculateItnChange() {
    return 0.0;
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
        page = HomePage();
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


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome to ITN Calculator",
            style: GoogleFonts.robotoCondensed(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 22.0
              ) 
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

    return Center(
      child: Column(
        children: [
          SizedBox(height: 25),
          Text(
            "ITN Calculator",
            style: GoogleFonts.robotoCondensed(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 22.0
              ) 
            ),
          ),
          SizedBox(height: 25),
          ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) {
              setState(() {
                // The button that is tapped is set to true, and the others to false.
                for (int i = 0; i < appState.selectedMode.length; i++) {
                  appState.selectedMode[i] = i == index;
                }
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            selectedBorderColor: Theme.of(context).colorScheme.secondary,
            selectedColor: Colors.white,
            fillColor: Theme.of(context).colorScheme.onPrimaryContainer,
            color: Theme.of(context).colorScheme.secondary,
            isSelected: appState.selectedMode,
            children: icons,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: getITNTextFormField(appState, 'Your ITN'),
          ),
          if (appState.selectedMode[1]) ...[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: getITNTextFormField(appState, 'ITN of your partner', )
            )
          ],
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: getITNTextFormField(appState, 'ITN of your opponent')
          ),
          if (appState.selectedMode[1]) ...[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: getITNTextFormField(appState, 'ITN of your opponent', )
            )
          ],
          SizedBox(height: 20),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed:() {},
            child: Text('Calculate'),
          )
        ],
      ),
    );
  }

  TextFormField getITNTextFormField(MyAppState appState, String label) {
    return TextFormField(
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: label,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              setState(() {
                // TODO
                appState.itnUser = double.tryParse(value) ?? 0;
              });
            },
          );
  }
}

/*
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}*/
