import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleAuthService.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleSignInOut.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';

import 'google_sign_in_out_service_test.mocks.dart';

@GenerateMocks([GoogleSignIn, GoogleAuthService])
void main() {
  group('GoogleSignInOutService', () {
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleAuthService mockGoogleAuthService;
    late GoogleSignInOutService googleSignInOutService;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleAuthService = MockGoogleAuthService();
      googleSignInOutService = GoogleSignInOutService(
        googleSignIn: mockGoogleSignIn,
        googleAuthService: mockGoogleAuthService,
      );
    });

    group('googleSignIn', () {
      test('should return GoogleSignInResult on successful sign-in', () async {
        // Arrange
        final serverAuthCode = 'test_auth_code';
        final backendResponse = {
          'success': true,
          'message': 'Success',
          'email': 'test@example.com',
          'data': {'userId': 'user1'},
          'calendars': [
            {
              'id': 'cal1',
              'summary': 'Test Calendar',
              'backgroundColor': '#ffffff',
              'primary': true
            }
          ]
        };
        when(mockGoogleAuthService.requestServerAuthenticatioinCode()).thenAnswer((_) async => serverAuthCode);
        when(mockGoogleAuthService.sendAuthCodeToBackend(serverAuthCode)).thenAnswer((_) async => backendResponse);

        // Act
        final result = await googleSignInOutService.googleSignIn(serverAuthCode);

        // Assert
        expect(result, isA<GoogleSignInResult>());
        expect(result.userId, 'user1');
        expect(result.email, 'test@example.com');
        expect(result.authCode, serverAuthCode);
        expect(result.calendars, isA<List>());
        expect(result.calendars?.length, 1);
      });

      test('should throw GoogleSignInException when server auth code is null', () async {
        // Arrange
        when(mockGoogleAuthService.requestServerAuthenticatioinCode()).thenAnswer((_) async => null);

        // Act & Assert
        expect(() => googleSignInOutService.googleSignIn(''), throwsA(isA<GoogleSignInException>()));
      });

      test('should throw GoogleSignInException on backend error', () async {
        // Arrange
        final serverAuthCode = 'test_auth_code';
        final backendResponse = {'success': false, 'message': 'Backend error'};
        when(mockGoogleAuthService.requestServerAuthenticatioinCode()).thenAnswer((_) async => serverAuthCode);
        when(mockGoogleAuthService.sendAuthCodeToBackend(serverAuthCode)).thenAnswer((_) async => backendResponse);

        // Act & Assert
        expect(() => googleSignInOutService.googleSignIn(serverAuthCode), throwsA(isA<GoogleSignInException>()));
      });
    });
  });
}
