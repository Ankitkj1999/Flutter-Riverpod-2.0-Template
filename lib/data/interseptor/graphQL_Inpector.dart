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
    _logger.i('Executing GraphQL Query');
    _logger.d('Query: $queryString');
    _logger.d('Variables: $variables');

    return _executeOperation(
          () => _client.query(QueryOptions(
        document: gql(queryString),
        variables: variables ?? {},
      )),
      operationType: 'Query',
    );
  }

  Future<QueryResult> mutate(String mutationString, {Map<String, dynamic>? variables}) async {
    _logger.i('Executing GraphQL Mutation');
    _logger.d('Mutation: $mutationString');
    _logger.d('Variables: $variables');

    return _executeOperation(
          () => _client.mutate(MutationOptions(
        document: gql(mutationString),
        variables: variables ?? {},
      )),
      operationType: 'Mutation',
    );
  }

  Future<QueryResult> _executeOperation(
      Future<QueryResult> Function() operation,
      {required String operationType}
      ) async {
    int retries = 0;
    while (true) {
      try {
        final result = await operation();
        if (result.hasException) {
          _logger.e('GraphQL $operationType error: ${result.exception.toString()}');
          throw result.exception!;
        }
        _logger.i('GraphQL $operationType completed successfully');
        _logger.d('Response data: ${result.data}');
        return result;
      } catch (e) {
        if (retries >= _maxRetries) {
          _logger.e('Max retries reached for GraphQL $operationType. Error: $e');
          rethrow;
        }
        retries++;
        _logger.w('Retrying GraphQL $operationType. Attempt $retries of $_maxRetries');
        await Future.delayed(Duration(seconds: retries * 2)); // Exponential backoff
      }
    }
  }
}