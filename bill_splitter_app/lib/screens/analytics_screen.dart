import 'package:bill_splitter_app/models/debt.dart';
import 'package:bill_splitter_app/models/user.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AnalyticsScreen extends StatefulWidget {
  final Debt debt;
  final User currentUser;

  const AnalyticsScreen({
    super.key,
    required this.debt,
    required this.currentUser,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final Map<String, Color> _categoryColors = {};

  final List<String> _filterOptions = [
    'Desde o início',
    'Este Mês',
    'Mês Passado'
  ];
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filterOptions[0];
  }

  Color _generateRandomColor(String category) {
    if (_categoryColors.containsKey(category)) {
      return _categoryColors[category]!;
    }
    final random = Random(category.hashCode);
    final color = Color.fromRGBO(
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
      1,
    );
    _categoryColors[category] = color;
    return color;
  }

  List<Expense> get _filteredExpenses {
    final now = DateTime.now();
    if (_selectedFilter == 'Este Mês') {
      return widget.debt.expenses
          .where((e) => e.date.month == now.month && e.date.year == now.year)
          .toList();
    }
    if (_selectedFilter == 'Mês Passado') {
      return widget.debt.expenses
          .where(
              (e) => e.date.month == now.month - 1 && e.date.year == now.year)
          .toList();
    }
    return widget.debt.expenses;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _groupExpensesByCategory(_filteredExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Gastos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gastos por Categoria',
                style: Theme.of(context).textTheme.titleLarge),
            DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: _filterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: _buildPieChart(_filteredExpenses, categoryTotals),
            ),
            const SizedBox(height: 20),
            _buildLegend(categoryTotals),
            const SizedBox(height: 40),
            Text('Gastos por Mês (Últimos 6 meses)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _buildBarChart(widget.debt.expenses),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _groupExpensesByCategory(List<Expense> expenses) {
    Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Widget _buildLegend(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: categoryTotals.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                    width: 16,
                    height: 16,
                    color: _generateRandomColor(entry.key)),
                const SizedBox(width: 8),
                Expanded(child: Text(entry.key)),
                Text('R\$ ${entry.value.toStringAsFixed(2)}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(
      List<Expense> expenses, Map<String, double> categoryTotals) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Nenhuma despesa neste período.'));
    }

    final double grandTotal =
        categoryTotals.values.fold(0, (sum, item) => sum + item);

    final pieChartSections = categoryTotals.entries.map((entry) {
      final category = entry.key;
      final total = entry.value;
      final percentage = (total / grandTotal) * 100;

      return PieChartSectionData(
        color: _generateRandomColor(category),
        value: total,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
      );
    }).toList();

    return PieChart(
        PieChartData(sections: pieChartSections, centerSpaceRadius: 20));
  }

  Widget _buildBarChart(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Nenhuma despesa para exibir.'));
    }

    Map<String, double> monthlyTotals = {};
    final now = DateTime.now();

    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM/yy', 'pt_BR').format(month);
      monthlyTotals[monthKey] = 0;
    }

    for (var expense in expenses) {
      final monthKey = DateFormat('MMM/yy', 'pt_BR').format(expense.date);
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }
    }

    int index = 0;
    final barGroups = monthlyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
              toY: entry.value,
              color: Theme.of(context).primaryColor,
              width: 20,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4), topRight: Radius.circular(4)))
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                  monthlyTotals.keys.elementAt(value.toInt()),
                  style: const TextStyle(fontSize: 10)),
              reservedSize: 30,
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }
}
