import 'package:flutter/material.dart';
import '../models/expense.dart';
/*
Dialog zum Anlegen einer neuen Ausgabe
erfasst alle Daten, validiert und 
gibt bei save ein expense objekt zurück oder bei cancel null
*/
class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({super.key});

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _dateCtrl; 
  late DateTime _date;
  late String _category;

  /// alle Dropdown Elemente im Filter
  static const List<String> _categories = <String>[
    'Einkäufe',
    'Transport',
    'Unterhaltung',
    'Wohnen',
    'Nebenkosten',
    'Shopping',
    'Gesundheit',
    'Sonstiges',
  ];
  ///Hilfsfunktion um Datum vernünftig zu formatieren (TT.MM.JJJJ)
  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}";

  @override
  void initState() {
    super.initState();
    /// Add-Dialog: Felder starten leer, Datum ist heute, Kategorie ist erstes Listenelement
    _titleCtrl  = TextEditingController();
    _amountCtrl = TextEditingController();
    _notesCtrl  = TextEditingController();
    _date       = DateTime.now();
    _dateCtrl   = TextEditingController(text: _fmtDate(_date));
    _category   = _categories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }
  /*
  Öffnet den datepicker. Wenn ein Datum gewählt wurde, wird
  _date angepasst und Datum aktualisiert
  */
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = _fmtDate(_date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ausgabe hinzufügen"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///Name
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Name (z. B. Einkauf)"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Bitte einen Namen eingeben" : null,
              ),
              const SizedBox(height: 12),
              /// Betrag in Euro (Komma wird zu Punkt gemappt für Parsing)
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Betrag (€)"),
                validator: (v) {
                  final val = double.tryParse((v ?? "").replaceAll(',', '.'));
                  if (val == null || val <= 0) return "Bitte gültigen Betrag eingeben";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Kategorieauswahl
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: "Kategorie"),
              ),
              const SizedBox(height: 12),
              //Beschreibung
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: "Beschreibung (optional)"),
                maxLines: 3,
              ),
              ///Datum als readOnly Textfeld für gleiches Aussehen
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: "Datum",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
        ),
      ),
      /// Cancel Save Buttons
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        /// Schließt den Dialog mit null
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        /// Validiert, baut ein Expense und returnt
        ElevatedButton(
          onPressed: () {
            /// Form aufbereiten
            if (!_formKey.currentState!.validate()) return;
            final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
            final title  = _titleCtrl.text.trim();
            final notes  = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

            /// Neues Expense-Objekt mit neuer ID 
            final exp = Expense(
              id: DateTime.now().microsecondsSinceEpoch.toString(), // immer neu
              amount: amount,
              category: _category,
              title: title,
              notes: notes,
              date: _date,
            );
            ///Dialog closen und return Ergebnis
            Navigator.pop(context, exp);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
