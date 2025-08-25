import 'package:flutter/material.dart';
import '../theme.dart';
/*
Zeigt die Haupt Budgetcard, mit Titel dem noch verfügbaren Geldbetrag und einer umgekehrten Progressbar
*/
class BudgetCard extends StatelessWidget {
  final double total;
  final double spent;
  final VoidCallback? onEditBudget;

  const BudgetCard({
    super.key,
    required this.total,
    required this.spent,
    this.onEditBudget,
  });
  ///formatiert double als Ganzzahl mit Tausenderpunkt und rundet auf natürliche Zahlen
  String _fmtEuroInt(double v) {
    final s = v.round().toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '.');
  }

  @override
  Widget build(BuildContext context) {
    ///Betrag wird nicht unter 0 droppen gelassen
    final double remaining =
        (total - spent).clamp(0.0, double.infinity).toDouble();
    ///berechnet Fortschritt für die Leiste
    final double percent = total <= 0
        ? 0.0
        : ((total - spent) / total).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Stack(
        children: [
          ///Edit-Icon oben rechts
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              tooltip: "Gehalt bearbeiten",
              onPressed: onEditBudget,
              icon: const Icon(Icons.edit),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Gehalt",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "${_fmtEuroInt(remaining)} €",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Zur Verfügung",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _ProgressBar(value: percent),
            ],
          ),
        ],
      ),
    );
  }
}
/*
baut die animierte Progressbar
*/
class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final double width = constraints.maxWidth;
      final double fillWidth = (width * value).clamp(0.0, width).toDouble();

      return Container(
        height: 18,
        decoration: BoxDecoration(
          color: AppTheme.trackGrey,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: fillWidth,
            decoration: BoxDecoration(
              color: AppTheme.greenFill,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      );
    });
  }
}
