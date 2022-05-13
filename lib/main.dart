import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Color drinkStatusColor(String status) {
  switch (status) {
    case "Ready":
      return Colors.blue;
    case "Preparing":
      return Colors.orange;
    case "Done":
      return Colors.green;
    default:
      return Colors.yellow;
  }
}

ListView getOrder(List<Order> data) {
  return ListView.separated(
    itemCount: data.length,
    separatorBuilder: (BuildContext context, int index) => const Divider(),
    itemBuilder: (BuildContext context, int index) {
      return Card(
          child: ListTile(
        title: Text(data[index].customerName),
        subtitle: Text('${data[index].coffee.region} - ${data[index].drink}'),
        trailing: Icon(
          Icons.circle,
          color: drinkStatusColor(data[index].status),
        ),
        leading: const Icon(
          Icons.coffee_rounded,
          color: Colors.grey,
        ),
      ));
    },
  );
}

Future<List<Order>> fetchOrder() async {
  final response =
      await http.get(Uri.parse('http://127.0.0.1:8080/app/orders'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var data = json.decode(response.body);
    List<Order> orders = [];
    for (var element in data) {
      orders.add(Order.fromJson(element));
    }
    return orders;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Coffee {
  final String region;
  final String roaster;
  final String tastingNotes;

  const Coffee({
    required this.region,
    required this.roaster,
    required this.tastingNotes,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      region: json['region'],
      roaster: json['roaster'],
      tastingNotes: json['tasting_notes'],
    );
  }
}

class Order {
  final String customerName;
  final Coffee coffee;
  final String drink;
  final String status;

  const Order({
    required this.customerName,
    required this.coffee,
    required this.drink,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerName: json['customer'],
      coffee: Coffee.fromJson(json['coffee']),
      drink: json['drink'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return "(customerName: $customerName drink: $drink)";
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barista Champ',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Welcome to Smort n\' Su\'s'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Order>> futureOrder;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    futureOrder = fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    {
      return MaterialApp(
        title: 'Barista Champ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Smort n\' Su\'s Coffee'),
          ),
          body: Center(
            child: FutureBuilder<List<Order>>(
              future: futureOrder,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Order> data = snapshot.data!;
                  return getOrder(data);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ),
          floatingActionButton: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Positioned(
                            right: -40.0,
                            top: -40.0,
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const CircleAvatar(
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                      decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: "Customer")),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: "Customer"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: "Customer"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: const Text("Order"),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.blueAccent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 20),
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal)),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.add, size: 24),
            label: const Text("PLACE ORDER"),
          ),
        ),
      );
    }
  }
}
