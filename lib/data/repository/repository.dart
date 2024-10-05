import 'package:logger/logger.dart';
import '../cache/cache_manager.dart';
import '../interseptor/graphQL_Inpector.dart';
import '../models/country.dart';


class CountryRepository {
  final GraphQLInterceptor _graphQLInterceptor;
  final CacheManager _cacheManager;
  final Logger _logger;

  CountryRepository(this._graphQLInterceptor, this._cacheManager, {Logger? logger})
      : _logger = logger ?? Logger();

  Future<List<Country>> getCountries() async {
    try {
      final cachedCountries = await _cacheManager.getCachedCountries();
      if (cachedCountries.isNotEmpty) {
        _logger.i('Returning cached countries');
        return cachedCountries;
      }

      const String query = '''
      query {
        countries {
          code
          name
          emoji
        }
      }
      ''';

      final result = await _graphQLInterceptor.query(query);
      final List<dynamic> countriesData = result.data?['countries'] as List<dynamic>? ?? [];
      final countries = countriesData
          .map((dynamic countryData) => Country.fromJson(countryData as Map<String, dynamic>))
          .toList();

      await _cacheManager.saveCountries(countries);
      return countries;
    } catch (e) {
      _logger.e('Error fetching countries: $e');
      rethrow;
    }
  }

  Future<Country> getCountryByCode(String code) async {
    try {
      const String query = '''
      query (\$code: ID!) {
        country(code: \$code) {
          code
          name
          emoji
        }
      }
      ''';

      final result = await _graphQLInterceptor.query(
        query,
        variables: {'code': code},
      );
      final Map<String, dynamic>? countryData = result.data?['country'] as Map<String, dynamic>?;
      if (countryData == null) {
        throw Exception('Country not found');
      }
      return Country.fromJson(countryData);
    } catch (e) {
      _logger.e('Error fetching country by code: $e');
      rethrow;
    }
  }
}