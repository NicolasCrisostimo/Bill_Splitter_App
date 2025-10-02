import 'package:bill_splitter_app/models/debt.dart';
import 'package:bill_splitter_app/models/user.dart';
import 'package:bill_splitter_app/screens/analytics_screen.dart';
import 'package:bill_splitter_app/services/auth_service.dart';
import 'package:bill_splitter_app/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DebtDetailScreen extends StatefulWidget {
  final String debtId;
  final DataService dataService;
  final AuthService authService;

  const DebtDetailScreen({
    super.key,
    required this.debtId,
    required this.dataService,
    required this.authService,
  });

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  Debt? _debt;
  User? _currentUser;
  Map<String, dynamic> _totals = {};

  @override
  void initState() {
    super.initState();
    _currentUser = widget.authService.currentUser.value;
    _loadDebtDetails();
  }

  void _loadDebtDetails() {
    final debt = widget.dataService.getDebtById(widget.debtId);
    if (debt != null) {
      debt.expenses.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _debt = debt;
        _totals = _debt!.calculateTotals();
      });
    }
  }

  Future<void> _showDeleteDebtConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Dívida'),
          content: const Text(
              'Tem certeza de que deseja excluir permanentemente esta dívida e todas as suas despesas?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                await widget.dataService.deleteDebt(widget.debtId);

                navigator.pop();
                if (navigator.canPop()) {
                  navigator.pop();
                }

                messenger.showSnackBar(const SnackBar(
                    content: Text('Dívida excluída com sucesso.')));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddExpenseDialog() async {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    String? paidById = _currentUser?.id;
    final availableCategories = widget.dataService.getCategories();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar Despesa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Descrição')),
                    TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Valor'),
                        keyboardType: TextInputType.number),
                    Autocomplete<String>(
                      optionsBuilder: (textEditingValue) => textEditingValue
                                  .text ==
                              ''
                          ? const Iterable.empty()
                          : availableCategories.where((c) => c
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase())),
                      onSelected: (selection) =>
                          categoryController.text = selection,
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmit) {
                        return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration:
                                const InputDecoration(labelText: 'Categoria'),
                            onChanged: (value) =>
                                categoryController.text = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Quem pagou?'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                            value: _debt!.userId1,
                            groupValue: paidById,
                            onChanged: (v) =>
                                setDialogState(() => paidById = v)),
                        Text(_debt!.userName1, overflow: TextOverflow.ellipsis),
                        Radio<String>(
                            value: _debt!.userId2,
                            groupValue: paidById,
                            onChanged: (v) =>
                                setDialogState(() => paidById = v)),
                        Text(_debt!.userName2, overflow: TextOverflow.ellipsis),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(dialogContext);

                    final amount = double.tryParse(amountController.text);
                    if (amount == null ||
                        amount <= 0 ||
                        descriptionController.text.trim().isEmpty ||
                        categoryController.text.trim().isEmpty) {
                      messenger.showSnackBar(const SnackBar(
                          content: Text(
                              'Por favor, preencha todos os campos corretamente.'),
                          backgroundColor: Colors.red));
                      return;
                    }

                    if (paidById != null) {
                      final newExpense = Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        description: descriptionController.text.trim(),
                        amount: amount,
                        paidById: paidById!,
                        date: DateTime.now(),
                        category: categoryController.text.trim(),
                      );
                      await widget.dataService
                          .addExpenseToDebt(_debt!.id, newExpense);

                      if (mounted) _loadDebtDetails();
                      navigator.pop();
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_debt == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }

    final friendName = _currentUser!.id == _debt!.userId1
        ? _debt!.userName2
        : _debt!.userName1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dívida com $friendName'),
        actions: [
          IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnalyticsScreen(
                          debt: _debt!, currentUser: _currentUser!)))),
          IconButton(
              icon: const Icon(Icons.delete_forever_outlined),
              onPressed: _showDeleteDebtConfirmationDialog),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(_totals['whoOwesMessage'],
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            '${_debt!.userName1} gastou: R\$ ${_totals['totalUser1'].toStringAsFixed(2)}'),
                        Text(
                            '${_debt!.userName2} gastou: R\$ ${_totals['totalUser2'].toStringAsFixed(2)}'),
                      ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Despesas',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          // Lista de despesas.
          Expanded(
            child: _debt!.expenses.isEmpty
                ? const Center(child: Text('Nenhuma despesa adicionada.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _debt!.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _debt!.expenses[index];
                      final paidByName = expense.paidById == _debt!.userId1
                          ? _debt!.userName1
                          : _debt!.userName2;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: Text(
                                        'Tem certeza de que deseja excluir a despesa "${expense.description}"?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar')),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Excluir',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (direction) async {
                            final messenger = ScaffoldMessenger.of(context);
                            await widget.dataService
                                .deleteExpense(_debt!.id, expense.id);

                            if (mounted) _loadDebtDetails();

                            messenger.showSnackBar(SnackBar(
                                content:
                                    Text('${expense.description} excluído.')));
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12)),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: ListTile(
                            title: Text(expense.description),
                            subtitle: Text(
                                'Pago por $paidByName em ${DateFormat('dd/MM/yy').format(expense.date)} - ${expense.category}'),
                            trailing: Text(
                                'R\$ ${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
