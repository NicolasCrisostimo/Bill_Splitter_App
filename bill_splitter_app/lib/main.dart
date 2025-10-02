import 'package:bill_splitter_app/auth_gate.dart';
import 'package:bill_splitter_app/services/auth_service.dart';
import 'package:bill_splitter_app/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  final authService = AuthService();
  final dataService = DataService();

  runApp(MyApp(
    authService: authService,
    dataService: dataService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final DataService dataService;

  const MyApp({
    super.key,
    required this.authService,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divisor de Contas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        useMaterial3: true,
      ),
      home: AuthGate(authService: authService, dataService: dataService),
      debugShowCheckedModeBanner: false,
    );
  }
}
