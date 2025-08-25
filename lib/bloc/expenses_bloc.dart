import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/expense.dart';

abstract class ExpensesEvent {}

class AddExpense extends ExpensesEvent {
  final Expense expense;
  AddExpense(this.expense);
}

class DeleteExpense extends ExpensesEvent {
  final String id;
  DeleteExpense(this.id);
}

class SetFilterCategory extends ExpensesEvent {
  /// null = alle
  final String? category;
  SetFilterCategory(this.category);
}

/*
speichert alle Ausgaben ungefiltert und den aktuellen Filter (inkl. null)
*/
class ExpensesState {
  final List<Expense> expenses;
  final String? filterCategory; // null = alle

  const ExpensesState({
    this.expenses = const [],
    this.filterCategory,
  });

  /// Objekt zur Unterscheidung null->nicht ausgewählt und return->null
  static const Object _notSet = Object();

  /*
  Erzeugt aus dem aktuellen State einen neue ExpensesState
  */
  ExpensesState copyWith({
    List<Expense>? expenses,
    Object? filterCategory = _notSet,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      filterCategory: identical(filterCategory, _notSet)
          ? this.filterCategory
          : filterCategory as String?,
    );
  }
  /// berechnet Summe aller Expenses unabhängig von Filter
  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

/*
Returned alle aktuellen Expenses entsprechend des ausgewählten Filters
*/
  List<Expense> get filtered {
    if (filterCategory == null || filterCategory!.isEmpty) return expenses;
    return expenses.where((e) => e.category == filterCategory).toList();
  }
}

/// BLOC

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {

  ExpensesBloc() : super(const ExpensesState()) {
    /*
    kopiert die alte Liste und fügt die neue Expense hinten an und sendet den neuen State (Zustandsänderung UI Reload)
    */
    on<AddExpense>((event, emit) {
      final updated = List<Expense>.from(state.expenses)..add(event.expense);
      emit(state.copyWith(expenses: updated));
    });
    
    /*
    behält alle Elemente die nicht die id haben und baut eine neue Liste 
    sendet neuen State
    */
    on<DeleteExpense>((event, emit) {
      final updated = state.expenses.where((e) => e.id != event.id).toList();
      emit(state.copyWith(expenses: updated));
    });

    /*
    setzt filterCategory auf übergebenen Wert
    UI zeigt dann berechnete Ansicht (state-filtered) an
    */
    on<SetFilterCategory>((event, emit) {
      emit(state.copyWith(filterCategory: event.category));
    });
  }
}
