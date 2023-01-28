import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// *we are creating a breadcrumb application
// simple application with 2 buttons having adding
// into the breadcrumb root and also stays activated
// using provider and solving real world provider issuses
// we also having the resest to resest the crumb root
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // * we need the instance of the provider that listens to its providers
    // * so we are using ChangeNotifierProvider since it helps in creating that instance and notifies its decendents

    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      // ? the child of the ChangeNotifierProvider's BuildContext shall have acces to BreadCrumbProvider as we linked it above
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {"/new": ((context) => const NewBreadCrumbWidget())},
      ),
    );
  }
}
// we are creating a class BreadCrumb
//that can be active and deactivated

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;
  // generating the constructor to access the variables
  // of the class when required
  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

// to check the equality of objects we need
// to define the override as shown below and its
// used for only objects not variables.
  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  // TODO: implement hashCode
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? '>' : '');
}
// we need something take hold of breadCrumbs

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  // we also want the read only version of a list
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);
  // lists in darts are classes that can change internally

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({
    Key? key,
    required this.breadCrumbs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: breadCrumbs.map(
      (breadCrumb) {
        return Text(
          breadCrumb.title,
          style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.black),
        );
      },
    ).toList());
  }
}

// ?go to main method for checking the instance
class HomePage extends StatelessWidget {
  const HomePage({super.key});
// todo we need check what is wrap widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Home Page')),
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(builder: ((context, value, child) {
            return BreadCrumbsWidget(breadCrumbs: value.items);
          })),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/new');
              },
              child: const Text("Add"),
            ),
          ),
          Center(
            child: ElevatedButton(
              // * Using read to communicate with provider like issue an call on the provider
              // ! dont use read if u are waiting for a mutable value because it won't do so
              onPressed: () {
                context.read<BreadCrumbProvider>().reset();
              },
              child: const Text("Reset"),
            ),
          ),
          
        ],
      ),
    );
  }
}


class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Node"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Enter the name of Node"),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                final breadCrumb = BreadCrumb(isActive: false, name: text);
                context.read<BreadCrumbProvider>().add(breadCrumb);
                Navigator.of(context).pop();
              }
            },
            child: const Text('ADD'),
          )
        ],
      ),
    );
  }
}

// ! Important
// read should be used in callbacks
// ? context.select():
//   allows to watch specific changes in the provider.
//  eg:
//    if there are 10 changes happening the provider then you can cherry pick the
//    the changes you want to watch using select.
// * it same as Inherited Model
// ! it is only useful inside the build() function of widgets
// ? context.read():
//   it is used to order the provider to do specified work :) XD
//   it must not be used inside build() directly
//   it must be inside the callback function where the changes are tracked in that
//   instances
// ? context.watch():
//   allows to watch the changes happening in the provider (any changes not specific)
//   context.watch() marks the widget to rebuild if the provider changes and
//   context.select() marks the widget to rebuild if the particular change looking for has actually changed.
//  It allows to watch optional providers and notify there on ,
// * you can use if - else to watch the optionl provider not the complete provider changes.
// ! Dont use watch and select in callbacks
// ! IF YOU ARE OUTSIDE THE BUILD() THEN USE
//  todo Provider.of()

// ?Consumer:
//  it is a provider that has builder
// creates a new Widget and calls the builder with its own BuildContext
// Consumer has a child Widget that doesn't get rebuilt whtn the provider changes
//  it is a building block for a widget it is used when the changeNotifier is notifies
