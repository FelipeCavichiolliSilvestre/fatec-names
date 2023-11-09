import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:names/entities/locality.dart';
import 'package:names/entities/name.dart';
import "package:names/extensions.dart";

class NamesScreen extends StatefulWidget {
  final Locality locality;

  const NamesScreen({super.key, required this.locality});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  Future<List<Name>> _names = Future(() => []);

  @override
  void initState() {
    _names = _fetchNames();
    super.initState();
  }

  Future<List<Name>> _fetchNames() async {
    var url = Uri.https(
        'servicodados.ibge.gov.br',
        'api/v2/censos/nomes/ranking',
        {"localidade": widget.locality.id.toString()});

    var response = await http.get(url);
    var data = jsonDecode(utf8.decode(response.bodyBytes))[0]["res"] as List;

    var nameList = data
        .map((n) => Name(
            value: (n["nome"] as String).capitalize(),
            frequency: n["frequencia"],
            ranking: n["ranking"]))
        .toList();

    nameList.sort((a, b) => a.ranking - b.ranking);

    return nameList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.locality.name),
      ),
      body: FutureBuilder(
          future: _names,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _nameList(context, snapshot.data!);
            }

            if (snapshot.hasError) {
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
      title: Text("${name.ranking}. ${name.value}"),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          "x${name.frequency}",
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(185)),
        ),
      ),
    );
  }
}
