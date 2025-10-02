import 'dart:io';
import 'package:bill_splitter_app/models/debt.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DataService {
  List<Debt> _debts = [];
  List<String> _categories = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadDebtsFromCsv();
    await _loadCategoriesFromCsv();
    _isInitialized = true;
  }

  // --- Métodos de Acesso e Manipulação de Dados ---

  List<Debt> getDebtsForUser(String userId) =>
      _debts.where((d) => d.userId1 == userId || d.userId2 == userId).toList();

  Debt? getDebtById(String debtId) {
    try {
      return _debts.firstWhere((d) => d.id == debtId);
    } catch (e) {
      return null;
    }
  }

  List<String> getCategories() => _categories;

  Future<void> createDebt(String userId1, String userName1, String userId2,
      String userName2) async {
    final ids = [userId1, userId2]..sort();
    final debtId = ids.join('-');

    if (_debts.any((d) => d.id == debtId)) return;

    final newDebt = Debt(
      id: debtId,
      userId1: userId1,
      userName1: userName1,
      userId2: userId2,
      userName2: userName2,
      expenses: [],
    );

    _debts.add(newDebt);
    await _saveDebtsToCsv();
    debugPrint('Dívida criada com ID: $debtId');
  }

  Future<void> addExpenseToDebt(String debtId, Expense newExpense) async {
    final debt = getDebtById(debtId);
    if (debt != null) {
      debt.expenses.add(newExpense);
      await _saveDebtsToCsv();
      await addCategory(newExpense.category);
    }
  }

  Future<void> deleteDebt(String debtId) async {
    _debts.removeWhere((debt) => debt.id == debtId);
    await _saveDebtsToCsv();
    debugPrint('Dívida com ID $debtId excluída.');
  }

  Future<void> deleteExpense(String debtId, String expenseId) async {
    final debt = getDebtById(debtId);
    if (debt != null) {
      debt.expenses.removeWhere((expense) => expense.id == expenseId);
      await _saveDebtsToCsv();
      debugPrint('Despesa com ID $expenseId excluída da dívida $debtId.');
    }
  }

  // --- Métodos de manipulação de categorias ---

  Future<void> addCategory(String category) async {
    final formattedCategory = category.trim();
    if (formattedCategory.isNotEmpty &&
        !_categories
            .any((c) => c.toLowerCase() == formattedCategory.toLowerCase())) {
      _categories.add(formattedCategory);
      await _saveCategoriesToCsv();
    }
  }

  // --- Métodos de persistência em CSV ---

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> _loadDebtsFromCsv() async {
    try {
      final path = await _getFilePath('debts_data.csv');
      final file = File(path);
      if (!await file.exists()) return;

      final csvString = await file.readAsString();
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);

      Map<String, Debt> debtsMap = {};
      if (csvTable.length > 1) {
        for (var i = 1; i < csvTable.length; i++) {
          final row = csvTable[i];
          final debtId = row[0].toString();

          if (debtsMap[debtId] == null) {
            debtsMap[debtId] = Debt(
              id: debtId,
              userId1: row[1].toString(),
              userName1: row[2].toString(),
              userId2: row[3].toString(),
              userName2: row[4].toString(),
              expenses: [],
            );
          }
          if (row.length > 5 && row[5] != null) {
            debtsMap[debtId]?.expenses.add(Expense(
                  id: row[5].toString(),
                  description: row[6].toString(),
                  amount: double.parse(row[7].toString()),
                  paidById: row[8].toString(),
                  date: DateTime.parse(row[9].toString()),
                  category: row[10].toString(),
                ));
          }
        }
      }
      _debts = debtsMap.values.toList();
      debugPrint('${_debts.length} dívidas carregadas do CSV.');
    } catch (e) {
      debugPrint('Erro ao carregar dívidas do CSV: $e');
    }
  }

  Future<void> _saveDebtsToCsv() async {
    try {
      List<List<dynamic>> csvData = [
        [
          'debtId',
          'userId1',
          'userName1',
          'userId2',
          'userName2',
          'expenseId',
          'description',
          'amount',
          'paidById',
          'date',
          'category'
        ]
      ];

      for (var debt in _debts) {
        if (debt.expenses.isEmpty) {
          csvData.add([
            debt.id,
            debt.userId1,
            debt.userName1,
            debt.userId2,
            debt.userName2,
            null,
            null,
            null,
            null,
            null,
            null
          ]);
        } else {
          for (var expense in debt.expenses) {
            csvData.add([
              debt.id,
              debt.userId1,
              debt.userName1,
              debt.userId2,
              debt.userName2,
              expense.id,
              expense.description,
              expense.amount,
              expense.paidById,
              expense.date.toIso8601String(),
              expense.category
            ]);
          }
        }
      }

      String csvString = const ListToCsvConverter().convert(csvData);
      final path = await _getFilePath('debts_data.csv');
      await File(path).writeAsString(csvString);
      debugPrint('Dívidas salvas no CSV.');
    } catch (e) {
      debugPrint('Erro ao salvar dívidas no CSV: $e');
    }
  }

  Future<void> _loadCategoriesFromCsv() async {
    try {
      final path = await _getFilePath('categories.csv');
      final file = File(path);
      if (!await file.exists()) return;

      final csvString = await file.readAsString();
      _categories = const CsvToListConverter()
          .convert(csvString)
          .expand((row) => row.map((item) => item.toString()))
          .toList();
      debugPrint('${_categories.length} categorias carregadas.');
    } catch (e) {
      debugPrint("Erro ao carregar categorias: $e");
    }
  }

  Future<void> _saveCategoriesToCsv() async {
    try {
      List<List<dynamic>> csvData = [_categories];
      String csvString = const ListToCsvConverter().convert(csvData);
      final path = await _getFilePath('categories.csv');
      await File(path).writeAsString(csvString);
      debugPrint("Categorias salvas.");
    } catch (e) {
      debugPrint("Erro ao salvar categorias: $e");
    }
  }
}
