import 'package:names/entities/locality.dart';

class CountryState extends Locality {
  final String acronym;

  CountryState({required this.acronym, required super.id, required super.name});
}
