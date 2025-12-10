import 'package:flutter/material.dart';

import '../../../database/db_helper.dart';
import '../../../widget/app_text.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.expense});

  final Map<String, dynamic>? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool isExpense = false;

  final _amountController = TextEditingController();
  final _addNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      isExpense = widget.expense!['type'] == 'expense';
      _amountController.text = widget.expense!['amount'].toString();
      _addNoteController.text = widget.expense!['notes'];
    } else {
      isExpense = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _addNoteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) return;

    final amount = double.tryParse(text);
    if (amount == null) return;

    final notes = _addNoteController.text.trim();
    final type = isExpense ? 'expense' : 'income';

    if (widget.expense == null) {
      // add
      await DbHelper.addItem(amount, notes, type);
    } else {
      // update
      await DbHelper.updateItem(widget.expense!['id']!, amount, notes, type);
    }

    Navigator.pop(context, true); // return true to indicate change
  }


  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.49,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                  child: AppText(isEditing ? 'Edit Transaction' : 'Add Transaction',
                      22, Colors.black, FontWeight.bold)),
              const SizedBox(height: 20),

              // Toggle button
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //income container
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpense = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: !isExpense
                                    ? Colors.green
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                                child: AppText(
                                    'INCOME',
                                    20,
                                    !isExpense ? Colors.white : Colors.black,
                                    FontWeight.bold)),
                          ),
                        ),
                      ),

                      //expense container
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpense = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: isExpense ? Colors.red : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                                child: AppText(
                                    'EXPENSE',
                                    20,
                                    isExpense ? Colors.white : Colors.black,
                                    FontWeight.bold)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              AppText('Amount', 20, Colors.black, FontWeight.w600),

              const SizedBox(height: 10),

              // amount textfield
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: '0.00',
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),

              const SizedBox(height: 20),

              AppText('Add Note', 20, Colors.black, FontWeight.w600),

              const SizedBox(height: 10),

              // add note textfield
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: _addNoteController,
                  decoration: const InputDecoration(
                      hintText: 'e.g., Salary, Coffee, Shopping',
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isExpense ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: AppText(
                        isEditing
                            ? (isExpense ? 'Save Expense' : 'Save Income')
                            : (isExpense ? 'Add Expense' : 'Add Income'),
                        20,
                        Colors.white,
                        FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
