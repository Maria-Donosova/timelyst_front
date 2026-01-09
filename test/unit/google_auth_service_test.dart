import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:timelyst_flutter/services/googleIntegration/googleAuthService.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../mocks/mockAuthService.dart';

// Manual Mocks
class MockApiClient extends Mock implements ApiClient {
  @override
  Future<http.Response> post(String? url, {Map<String, String>? headers, dynamic body, String? token}) =>
      super.noSuchMethod(Invocation.method(#post, [url], {#headers: headers, #body: body, #token: token}),
          returnValue: Future.value(http.Response('', 200)));
}

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() =>
      super.noSuchMethod(Invocation.method(#signOut, []), returnValue: Future<GoogleSignInAccount?>.value(null));
  
  @override
  Future<GoogleSignInAccount?> signIn() =>
      super.noSuchMethod(Invocation.method(#signIn, []), returnValue: Future<GoogleSignInAccount?>.value(null));
}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  @override
  String? get serverAuthCode => super.noSuchMethod(Invocation.getter(#serverAuthCode), returnValue: null);
}

void main() {
  group('GoogleAuthService', () {
    late MockApiClient mockApiClient;
    late MockAuthService mockAuthService;
    late MockGoogleSignIn mockGoogleSignIn;
    late GoogleAuthService googleAuthService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuthService = MockAuthService();
      mockGoogleSignIn = MockGoogleSignIn();
      googleAuthService = GoogleAuthService.test(mockApiClient, mockAuthService, mockGoogleSignIn);
    });

    group('sendAuthCodeToBackend', () {
      test('returns success: true on 200 response', () async {
        mockAuthService.setLoginState(true, token: 'user-token');
        
        when(mockApiClient.post(any, body: anyNamed('body'), token: 'user-token'))
            .thenAnswer((_) async => http.Response(jsonEncode({'message': 'Success'}), 200));

        final result = await googleAuthService.sendAuthCodeToBackend('auth-code');

        expect(result['success'], isTrue);
        expect(result['message'], 'Success');
      });

      test('returns success: false on backend error (400)', () async {
        mockAuthService.setLoginState(true, token: 'user-token');
        
        when(mockApiClient.post(any, body: anyNamed('body'), token: 'user-token'))
            .thenAnswer((_) async => http.Response('Bad Request', 400));

        final result = await googleAuthService.sendAuthCodeToBackend('auth-code');

        expect(result['success'], isFalse);
        expect(result['message'], contains('400'));
      });

      test('returns success: false on exception', () async {
        mockAuthService.setLoginState(true, token: 'user-token');
        
        when(mockApiClient.post(any, body: anyNamed('body'), token: 'user-token'))
            .thenThrow(Exception('Network Error'));

        final result = await googleAuthService.sendAuthCodeToBackend('auth-code');

        expect(result['success'], isFalse);
        expect(result['message'], contains('Network Error'));
      });
    });

    group('requestServerAuthenticationCode', () {
      test('returns null if sign-in is aborted', () async {
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        final result = await googleAuthService.requestServerAuthenticationCode();

        expect(result, isNull);
        verify(mockGoogleSignIn.signOut()).called(1);
        verify(mockGoogleSignIn.signIn()).called(1);
      });

      test('returns serverAuthCode if sign-in is successful', () async {
        final mockAccount = MockGoogleSignInAccount();
        when(mockAccount.serverAuthCode).thenReturn('server-code');
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);

        final result = await googleAuthService.requestServerAuthenticationCode();

        expect(result, 'server-code');
      });
    });
  });
}
