import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:names/entities/city.dart';
import 'package:names/entities/locality.dart';
import 'package:names/entities/state.dart';
import 'package:names/screens/names_screen.dart';

class CitiesScreen extends StatefulWidget {
  final CountryState state;

  const CitiesScreen({super.key, required this.state});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  Future<List<City>> _cities = Future(() => [City(id: 11, name: "Ourinhos")]);

  @override
  void initState() {
    _cities = _fetchCities();
    super.initState();
  }

  Future<List<City>> _fetchCities() async {
    var url = Uri.https('servicodados.ibge.gov.br',
        '/api/v1/localidades/estados/${widget.state.id}/municipios');

    var response = await http.get(url);
    var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;

    return data.map((c) => City(id: c["id"], name: c["nome"])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.state.name),
      ),
      body: FutureBuilder(
          future: _cities,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _cityList(context, snapshot.data!);
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _cityList(BuildContext context, List<City> cities) {
    final cityList = cities.map((e) => _listItem(e)).toList();
    cityList.insert(0, _listItem(widget.state));

    return ListView(
        children:
            ListTile.divideTiles(tiles: cityList, context: context).toList());
  }

  Widget _listItem(Locality locality) {
    return ListTile(
        title: Text(locality.name),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NamesScreen(locality: locality),
            )));
  }
}
