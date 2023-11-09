import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:names/entities/state.dart';
import 'package:names/screens/cities_screen.dart';

class StatesScreen extends StatefulWidget {
  const StatesScreen({super.key});

  @override
  State<StatesScreen> createState() => _StatesScreenState();
}

class _StatesScreenState extends State<StatesScreen> {
  Future<List<CountryState>> _states = Future(() => []);

  @override
  void initState() {
    _states = _fetchStates();
    super.initState();
  }

  Future<List<CountryState>> _fetchStates() async {
    var url =
        Uri.https('servicodados.ibge.gov.br', '/api/v1/localidades/estados');

    var response = await http.get(url);
    var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;

    return data
        .map((s) =>
            CountryState(id: s["id"], acronym: s["sigla"], name: s["nome"]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Estados"),
      ),
      body: FutureBuilder(
          future: _states,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _stateList(context, snapshot.data!);
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _stateList(BuildContext context, List<CountryState> states) {
    return ListView(
        children: ListTile.divideTiles(
                tiles: states.map((e) => _stateListItem(e)), context: context)
            .toList());
  }

  Widget _stateListItem(CountryState state) {
    return ListTile(
        title: Text("${state.name} - ${state.acronym}"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CitiesScreen(state: state),
              ),
            ));
  }
}
