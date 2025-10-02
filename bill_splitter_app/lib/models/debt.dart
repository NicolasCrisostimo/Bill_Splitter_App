/// Modelo que representa uma dívida entre dois usuários.
/// Funciona como a planta para todos os objetos de dívida no app.
class Debt {
  final String id; // ID único da dívida (ex: "userId1-userId2")
  final String userId1;
  final String userName1;
  final String userId2;
  final String userName2;
  final List<Expense> expenses; // Lista de despesas associadas a esta dívida.

  Debt({
    required this.id,
    required this.userId1,
    required this.userName1,
    required this.userId2,
    required this.userName2,
    required this.expenses,
  });

  /// Calcula os totais gastos por cada usuário e gera a mensagem de quem deve a quem.
  /// Este método contém a principal lógica de negócios do cálculo.
  Map<String, dynamic> calculateTotals() {
    double totalUser1 = 0;
    double totalUser2 = 0;

    // Itera sobre cada despesa para somar os totais.
    for (var expense in expenses) {
      if (expense.paidById == userId1) {
        totalUser1 += expense.amount;
      } else if (expense.paidById == userId2) {
        totalUser2 += expense.amount;
      }
    }

    String whoOwesMessage;
    // Lógica de cálculo: subtrai o menor do maior e divide por 2.
    if (totalUser1 > totalUser2) {
      final difference = (totalUser1 - totalUser2) / 2;
      whoOwesMessage = '$userName2 deve R\$ ${difference.toStringAsFixed(2)} para $userName1';
    } else if (totalUser2 > totalUser1) {
      final difference = (totalUser2 - totalUser1) / 2;
      whoOwesMessage = '$userName1 deve R\$ ${difference.toStringAsFixed(2)} para $userName2';
    } else {
      whoOwesMessage = 'Vocês estão quites!';
    }

    // Retorna um mapa com todos os resultados calculados.
    return {
      'totalUser1': totalUser1,
      'totalUser2': totalUser2,
      'whoOwesMessage': whoOwesMessage,
    };
  }
}

/// Modelo que representa uma única despesa (um item de gasto).
class Expense {
  final String id; // ID único para a despesa, útil para exclusão.
  final String description;
  final double amount;
  final String paidById; // ID do usuário que pagou.
  final DateTime date; // Data em que o gasto foi feito.
  final String category;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidById,
    required this.date,
    required this.category,
  });
}

