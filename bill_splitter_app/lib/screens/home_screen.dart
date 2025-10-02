import 'package:bill_splitter_app/models/debt.dart';
import 'package:bill_splitter_app/models/user.dart';
import 'package:bill_splitter_app/screens/debt_detail_screen.dart';
import 'package:bill_splitter_app/services/auth_service.dart';
import 'package:bill_splitter_app/services/data_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final DataService dataService;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.dataService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  List<Debt> _debts = [];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.authService.currentUser.value;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await widget.dataService.initialize();
    await widget.authService.initialize();

    if (mounted) {
      setState(() {
        _currentUser = widget.authService.currentUser.value;
        _debts = widget.dataService.getDebtsForUser(_currentUser!.id);
      });
    }
  }

  Future<void> _showCreateDebtDialog() async {
    final friendEmailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Dívida'),
          content: TextField(
            controller: friendEmailController,
            decoration: const InputDecoration(labelText: "E-mail do amigo"),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final friendEmail = friendEmailController.text.trim();
                if (friendEmail.isEmpty) return;

                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final friend =
                    await widget.authService.getUserByEmail(friendEmail);

                if (friend == null) {
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Usuário não encontrado.')));
                } else if (friend.id == _currentUser!.id) {
                  messenger.showSnackBar(const SnackBar(
                      content: Text(
                          'Você não pode criar uma dívida com você mesmo.')));
                } else {
                  await widget.dataService.createDebt(
                    _currentUser!.id,
                    _currentUser!.name,
                    friend.id,
                    friend.name,
                  );
                  _loadInitialData();
                  navigator.pop();
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Dívidas'),
        actions: [
          // Botão de logout.
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.authService.logout();
            },
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : _debts.isEmpty
              ? const Center(
                  child: Text(
                      'Nenhuma dívida encontrada.\nClique no + para começar.',
                      textAlign: TextAlign.center),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _debts.length,
                  itemBuilder: (context, index) {
                    final debt = _debts[index];
                    final friendName = _currentUser!.id == debt.userId1
                        ? debt.userName2
                        : debt.userName1;

                    final totals = debt.calculateTotals();
                    final summary = totals['whoOwesMessage'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child:
                              Text(friendName.isNotEmpty ? friendName[0] : '?'),
                        ),
                        title: Text('Dívida com $friendName'),
                        subtitle: Text(summary),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DebtDetailScreen(
                                debtId: debt.id,
                                dataService: widget.dataService,
                                authService: widget.authService,
                              ),
                            ),
                          ).then((_) => _loadInitialData());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDebtDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
