import 'package:hive/hive.dart';
import '../models/country.dart';

class CacheManager {
  static const String _countriesBoxName = 'countries';

  Future<void> saveCountries(List<Country> countries) async {
    final box = await Hive.openBox<Country>(_countriesBoxName);
    await box.clear();
    await box.addAll(countries);
  }

  Future<List<Country>> getCachedCountries() async {
    final box = await Hive.openBox<Country>(_countriesBoxName);
    return box.values.toList();
  }

  Future<void> clearCache() async {
    final box = await Hive.openBox<Country>(_countriesBoxName);
    await box.clear();
  }
}