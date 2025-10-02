// Arquivo de teste para os widgets do aplicativo.
// Testes de widget verificam se a UI se parece e se comporta como esperado.

import 'package:bill_splitter_app/main.dart';
import 'package:bill_splitter_app/services/auth_service.dart';
import 'package:bill_splitter_app/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Define um novo teste de widget.
  testWidgets('App starts and shows Login Screen', (WidgetTester tester) async {
    // PREPARAÇÃO (Arrange):
    // Crie instâncias "mock" ou reais dos seus serviços.
    // Para este teste, as instâncias reais funcionam bem.
    final authService = AuthService();
    final dataService = DataService();

    // AÇÃO (Act):
    // Construa o widget principal do app (MyApp) e dispare um frame para renderizá-lo.
    // É crucial passar os serviços que o MyApp agora exige.
    await tester.pumpWidget(MyApp(
      authService: authService,
      dataService: dataService,
    ));

    // 'pumpAndSettle' aguarda todas as animações e operações assíncronas terminarem.
    // É útil para garantir que a tela esteja em seu estado final antes de fazer as verificações.
    await tester.pumpAndSettle();

    // VERIFICAÇÃO (Assert):
    // Use 'expect' e 'find' para verificar se os widgets esperados estão na tela.
    
    // Verifica se existe um widget de Texto com o conteúdo 'Login'.
    expect(find.text('Login'), findsOneWidget);
    // Verifica se existe um TextFormField (campo de texto) com o texto de rótulo 'E-mail'.
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    // Verifica se existe um TextFormField com o rótulo 'Senha'.
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
  });
}

