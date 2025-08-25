import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hallo_app/theme.dart';
import 'package:hallo_app/models/expense.dart';
import 'package:hallo_app/widgets/budget_card.dart';
import 'package:hallo_app/widgets/expense_dialog.dart';
import 'package:hallo_app/bloc/budget_cubit.dart';
import 'package:hallo_app/bloc/expenses_bloc.dart';

/*
Stellt die beiden Zustände Budget und Expenses bereit und redenert die _HomeView Ansicht
*/
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BudgetCubit(3000)),
        BlocProvider(create: (_) => ExpensesBloc()),
      ],
      child: const _HomeView(),
    );
  }
}

/*
eigentlicher View
*/
class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}


class _HomeViewState extends State<_HomeView> {
  ///Anzeigelabel für alle Kategorien
  static const String _allLabel = 'Alle';
  ///merkt sich aufgeklappte Elemente in UI
  final Set<String> _expanded = <String>{};
  /*
  öffnet Add-Dialog, bei Erfolg wird AddExpense Event an Bloc geschickt
  */
  Future<void> _addExpense(BuildContext context) async {
    final exp = await showDialog<Expense>(
      context: context,
      builder: (_) => const ExpenseDialog(),
    );
    if (exp != null) {
      context.read<ExpensesBloc>().add(AddExpense(exp));
    }
  }
  /*
  Dialog zum Setzen des Gehalts (double), ruft bei Erfolg BudgetCubit.setBudget auf
  */
  Future<void> _setBudget(BuildContext context, double current) async {
    final ctrl = TextEditingController(text: current.toStringAsFixed(2));
    final newBudget = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Gehalt setzen"),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: "Gehalt (€)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(ctrl.text.replaceAll(',', '.'))),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (newBudget != null) context.read<BudgetCubit>().setBudget(newBudget);
  }
  /*
  Löscht Ausgabe per Event und zeigt Snackbar um Löschen rückgängig zu machen
  */
  void _deleteWithUndo(BuildContext context, Expense exp) {
    context.read<ExpensesBloc>().add(DeleteExpense(exp.id));

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Ausgabe gelöscht'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            context.read<ExpensesBloc>().add(AddExpense(exp));
          },
        ),
      ),
    );
  }
  ///Hilfsfunktion um Datum vernünftig zu formatieren (TT.MM.JJJJ)
  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}";

  @override
  Widget build(BuildContext context) {
    final divider = const Divider();

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<BudgetCubit, double>(
                builder: (context, budget) {
                  return BlocBuilder<ExpensesBloc, ExpensesState>(
                    builder: (context, state) {
                      return BudgetCard(
                        total: budget,
                        spent: state.totalSpent,
                        onEditBudget: () => _setBudget(context, budget),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              ///Dropdown mit allen vorhandenen Kategorien inkl. "Alle"
              BlocBuilder<ExpensesBloc, ExpensesState>(
                builder: (context, state) {
                  final categories = <String>{...state.expenses.map((e) => e.category)}.toList()
                    ..sort();

                  final items = <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: _allLabel,
                      child: Text(_allLabel),
                    ),
                    ...categories.map(
                      (c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ),
                    ),
                  ];

                  final currentValue =
                      state.filterCategory == null ? _allLabel : state.filterCategory!;

                  return Row(
                    children: [
                      Text("Filter:", style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: currentValue,
                        items: items,
                        onChanged: (v) {
                          if (v == null || v == _allLabel) {
                            context.read<ExpensesBloc>().add(SetFilterCategory(null));
                          } else {
                            context.read<ExpensesBloc>().add(SetFilterCategory(v));
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              /*
              Listview der Ausgaben mit Divider
              wenn leer, dann Platzhaltertext
              expand und collape möglich wenn notes hinzugefügt
              */
              Expanded(
                child: BlocBuilder<ExpensesBloc, ExpensesState>(
                  builder: (context, state) {
                    final list = state.filtered;
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            "Noch keine Ausgaben",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => divider,
                      itemBuilder: (_, index) {
                        final item = list[index];
                        final dateStr = _fmtDate(item.date);
                        final isExpanded = _expanded.contains(item.id);
                        final hasNotes = (item.notes != null && item.notes!.trim().isNotEmpty);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              onTap: hasNotes
                                  ? () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expanded.remove(item.id);
                                        } else {
                                          _expanded.add(item.id);
                                        }
                                      });
                                    }
                                  : null,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.title.isEmpty ? "(ohne Namen)" : item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textMuted,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textMuted,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              ///kompakter Delete Button neben dem Betrag
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: Text(
                                      "${item.amount.toStringAsFixed(2)} €",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _deleteWithUndo(context, item),
                                    icon: const Icon(Icons.delete),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    visualDensity:
                                        const VisualDensity(horizontal: -3, vertical: -3),
                                    tooltip: "Löschen",
                                  ),
                                ],
                              ),
                              minVerticalPadding: 6,
                            ),
                            ///Expand Indicator wenn notes existierene aber collapsed
                            if (hasNotes && !isExpanded)
                              const SizedBox(
                                height: 14,
                                child: Center(
                                  child: Icon(Icons.expand_more, size: 14, color: AppTheme.textMuted),
                                ),
                              ),
                            ///Notes Text wenn aufgeklappt
                            if (hasNotes && isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 8),
                                child: Text(
                                  item.notes!,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppTheme.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              ///Action Button für Add Expense
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addExpense(context),
                    child: const Text("ADD EXPENSE"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
