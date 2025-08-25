import 'package:flutter_bloc/flutter_bloc.dart';

/* 
Setzt den initial value des budgets auf 1500
Wird dieser Wert von setBudget nicht überschrieben wird dieser verwendet
Bei negativem Override wird 0 gesetzt
*/
class BudgetCubit extends Cubit<double> {
  BudgetCubit([double initial = 1500]) : super(initial);

  void setBudget(double value) {
    emit(value < 0 ? 0 : value);
  }
}
