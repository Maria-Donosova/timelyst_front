import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleSignInManager.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleSignInOut.dart';
import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';

import 'google_sign_in_manager_test.mocks.dart';

@GenerateMocks([GoogleSignInOutService])
void main() {
  group('GoogleSignInManager', () {
    late MockGoogleSignInOutService mockGoogleSignInOutService;
    late GoogleSignInManager googleSignInManager;

    setUp(() {
      mockGoogleSignInOutService = MockGoogleSignInOutService();
      googleSignInManager = GoogleSignInManager(signInService: mockGoogleSignInOutService);
    });

    test('signIn should return GoogleSignInResult on successful sign-in', () async {
      // Arrange
      final signInResult = GoogleSignInResult(isSuccess: true, email: 'test@example.com');
      when(mockGoogleSignInOutService.googleSignIn()).thenAnswer((_) async => signInResult);

      // Act
      final result = await googleSignInManager.signIn(MockBuildContext());

      // Assert
      expect(result, signInResult);
      verify(mockGoogleSignInOutService.googleSignIn()).called(1);
    });

    test('signIn should return null on GoogleSignInException', () async {
      // Arrange
      when(mockGoogleSignInOutService.googleSignIn()).thenThrow(GoogleSignInException('Sign-in failed'));

      // Act
      final result = await googleSignInManager.signIn(MockBuildContext());

      // Assert
      expect(result, isNull);
      verify(mockGoogleSignInOutService.googleSignIn()).called(1);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
