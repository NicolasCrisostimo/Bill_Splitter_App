import 'package:bill_splitter_app/screens/home_screen.dart';
import 'package:bill_splitter_app/screens/login_screen.dart';
import 'package:bill_splitter_app/services/auth_service.dart';
import 'package:bill_splitter_app/services/data_service.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  final AuthService authService;
  final DataService dataService;

  const AuthGate({
    super.key,
    required this.authService,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService.currentUser,
      builder: (context, user, _) {
        if (user != null) {
          return HomeScreen(authService: authService, dataService: dataService);
        } else {
          return LoginScreen(authService: authService);
        }
      },
    );
  }
}
