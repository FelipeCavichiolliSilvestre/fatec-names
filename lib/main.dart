import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:names/name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Names',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Ourinhos'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Name>> _names = Future(() => []);

  @override
  void initState() {
    _names = _fetchNames();
    super.initState();
  }

  Future<List<Name>> _fetchNames() async {
    var url = Uri.https('servicodados.ibge.gov.br',
        'api/v2/censos/nomes/ranking', {"localidade": "3534708"});

    var response = await http.get(url);
    var data = jsonDecode(utf8.decode(response.bodyBytes))[0]["res"] as List;

    var nameList = data
        .map((e) => Name(
            name: e["nome"], frequency: e["frequencia"], ranking: e["ranking"]))
        .toList();

    return nameList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: _names,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _nameList(context, snapshot.data!);
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text("Something went wrong"));
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _nameList(BuildContext context, List<Name> names) {
    return ListView(
        children: ListTile.divideTiles(
                tiles: names.map((e) => _nameListItem(e)), context: context)
            .toList());
  }

  Widget _nameListItem(Name name) {
    return ListTile(
      title: Text("${name.ranking}. ${name.name}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  "x${name.frequency}",
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(185)),
                ),
              )),
        ],
      ),
    );
  }
}
