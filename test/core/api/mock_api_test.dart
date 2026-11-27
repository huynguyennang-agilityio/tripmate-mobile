// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-5 (level U, edge): an operation whose contract has no example, in mock
// mode: the interceptor fails with the operation's name; it returns no
// made-up data.
//
// The contract is a small OpenAPI document written in the test. Its one
// operation answers 200 with a JSON schema that has no example anywhere.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate_mobile/core/api/mock_api.dart';

import '../../support/fake_adapter.dart';

const _operationId = 'list_things_v1_things_get';

final Map<String, dynamic> _contract = {
  'openapi': '3.1.0',
  'info': {'title': 'MF2-5', 'version': '0.0.0'},
  'paths': {
    '/v1/things': {
      'get': {
        'operationId': _operationId,
        'responses': {
          '200': {
            'description': 'Successful Response',
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/Thing'},
              },
            },
          },
        },
      },
    },
  },
  'components': {
    'schemas': {
      'Thing': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
        'required': ['name'],
      },
    },
  },
};

void main() {
  test('MF2-5 an operation with no example fails with its operationId and '
      'returns no data', () async {
    final adapter = RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
      ..httpClientAdapter = adapter
      ..interceptors.add(MockApiInterceptor(_contract));

    DioException? failure;
    Response<Object?>? response;
    try {
      response = await dio.get<Object?>('/v1/things');
    } on DioException catch (error) {
      failure = error;
    }

    expect(response, isNull, reason: 'no answer is made up');
    expect(failure, isNotNull);
    expect(failure!.error, isA<MissingExampleError>());
    expect((failure.error! as MissingExampleError).operationId, _operationId);
    expect(failure.message, contains(_operationId));
    expect(failure.response?.data, isNull);
  });
}
