import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

class GraphQLInterceptor {
  final GraphQLClient _client;
  final Logger _logger;
  final int _maxRetries;

  GraphQLInterceptor(this._client, {Logger? logger, int maxRetries = 3})
      : _logger = logger ?? Logger(),
        _maxRetries = maxRetries;

  Future<QueryResult> query(String queryString, {Map<String, dynamic>? variables}) async {
    return _executeOperation(
          () => _client.query(QueryOptions(
        document: gql(queryString),
        variables: variables ?? {},
      )),
    );
  }

  Future<QueryResult> mutate(String mutationString, {Map<String, dynamic>? variables}) async {
    return _executeOperation(
          () => _client.mutate(MutationOptions(
        document: gql(mutationString),
        variables: variables ?? {},
      )),
    );
  }

  Future<QueryResult> _executeOperation(Future<QueryResult> Function() operation) async {
    int retries = 0;
    while (true) {
      try {
        final result = await operation();
        if (result.hasException) {
          _logger.e('GraphQL error: ${result.exception.toString()}');
          throw result.exception!;
        }
        return result;
      } catch (e) {
        if (retries >= _maxRetries) {
          _logger.e('Max retries reached. Error: $e');
          rethrow;
        }
        retries++;
        _logger.w('Retrying operation. Attempt $retries of $_maxRetries');
        await Future.delayed(Duration(seconds: retries * 2)); // Exponential backoff
      }
    }
  }
}