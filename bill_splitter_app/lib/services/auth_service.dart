import 'dart:io';
import 'package:bill_splitter_app/models/user.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AuthService with ChangeNotifier {
  final ValueNotifier<User?> currentUser = ValueNotifier(null);

  List<User> _users = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadUsersFromCsv();
    _isInitialized = true;
  }

  Future<String?> login(
      {required String email, required String password}) async {
    await initialize();
    try {
      final user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      currentUser.value = user;
      notifyListeners();
      return null;
    } catch (e) {
      return 'E-mail ou senha inválidos.';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await initialize();
    if (_users.any((user) => user.email == email)) {
      return 'Este e-mail já está em uso.';
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );

    _users.add(newUser);
    await _saveUsersToCsv();
    currentUser.value = newUser;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    currentUser.value = null;
    notifyListeners();
  }

  Future<User?> getUserByEmail(String email) async {
    await initialize();
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // --- Métodos de persistência em CSV ---

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/users.csv');
  }

  Future<void> _loadUsersFromCsv() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return;
      }

      final contents = await file.readAsString();
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(contents);

      _users = csvTable
          .skip(1)
          .map((row) => User(
                id: row[0].toString(),
                name: row[1].toString(),
                email: row[2].toString(),
                password: row[3].toString(),
              ))
          .toList();
      debugPrint("${_users.length} usuários carregados do CSV.");
    } catch (e) {
      debugPrint("Erro ao carregar usuários: $e");
    }
  }

  Future<void> _saveUsersToCsv() async {
    try {
      final file = await _localFile;
      List<List<dynamic>> csvData = [
        ['id', 'name', 'email', 'password'],
        ..._users.map((user) => [user.id, user.name, user.email, user.password])
      ];
      String csv = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csv);
      debugPrint("Usuários salvos no CSV.");
    } catch (e) {
      debugPrint("Erro ao salvar usuários: $e");
    }
  }
}
