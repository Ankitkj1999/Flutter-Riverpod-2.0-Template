import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

import '../../../common/app_bar_gone.dart';
import '../../../common/bottom_nav_bar/bottom_nav_bar.dart';

class Country {
  final String code;
  final String name;
  final String emoji;

  Country({required this.code, required this.name, required this.emoji});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
    );
  }
}

class CountriesScreen extends ConsumerStatefulWidget {
  const CountriesScreen({Key? key}) : super(key: key);

  @override
  _CountriesScreenState createState() => _CountriesScreenState();
}

class _CountriesScreenState extends ConsumerState<CountriesScreen> {
  List<Country> countries = [];
  bool isLoading = false;
  final logger = Logger();
  @override
  void initState() {
    super.initState();
    fetchCountries();
    // logger initialized in main.dart
    logger.d('CountriesScreen initialized');
  }

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
    });

    final HttpLink httpLink = HttpLink("https://countries.trevorblades.com");
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    const String query = '''
    query {
      countries {
        code
        name
        emoji
      }
    }
    ''';

    final QueryResult result = await client.query(
      QueryOptions(document: gql(query)),
    );

    if (result.hasException) {
      print(result.exception.toString());
    } else {
      setState(() {
        countries = (result.data?['countries'] as List<dynamic>?)
            ?.map((dynamic country) => Country.fromJson(country as Map<String, dynamic>))
            .toList() ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      bottomNavigationBar: const BottomNavBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          return ListTile(
            leading: Text(country.emoji),
            title: Text(country.name),
            subtitle: Text(country.code),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchCountries,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// TODO: Impletent the network print interceptor