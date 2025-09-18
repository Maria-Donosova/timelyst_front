// Quick test to verify getUserEmail method exists
import 'lib/services/authService.dart';

void main() async {
  final authService = AuthService();
  
  // This should compile without errors
  final email = await authService.getUserEmail();
  print('getUserEmail method exists and returns: $email');
}