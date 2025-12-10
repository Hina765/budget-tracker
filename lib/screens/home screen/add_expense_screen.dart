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
  bool isExpense = true;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      final data = widget.expense!;
      isExpense = data['type'] == 'expense';
      _amountController.text = data['amount'].toString();
      _noteController.text = data['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final note = _noteController.text.trim();
    final type = isExpense ? 'expense' : 'income';

    if (widget.expense == null) {
      await DbHelper.addItem(amount, note, type);
    } else {
      await DbHelper.updateItem(
        widget.expense!['id'],
        amount,
        note,
        type,
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.expense != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.50,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Center(
                child: AppText(
                  isEditing ? 'Edit Transaction' : 'Add Transaction',
                  22,
                  Colors.black,
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // INCOME / EXPENSE Toggle
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isExpense = false);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: isExpense ? Colors.transparent : Colors.green,
                            ),
                            child: Center(
                              child: AppText(
                                'INCOME',
                                20,
                                isExpense ? Colors.black : Colors.white,
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isExpense = true);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: isExpense ? Colors.red : Colors.transparent,
                            ),
                            child: Center(
                              child: AppText(
                                'EXPENSE',
                                20,
                                isExpense ? Colors.white : Colors.black,
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              AppText('Amount', 18, Colors.black, FontWeight.w600),
              const SizedBox(height: 10),

              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              AppText('Add Note', 18, Colors.black, FontWeight.w600),
              const SizedBox(height: 10),

              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Salary, Coffee, Shopping',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpense ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: AppText(
                    isEditing
                        ? (isExpense ? 'Save Expense' : 'Save Income')
                        : (isExpense ? 'Add Expense' : 'Add Income'),
                    20,
                    Colors.white,
                    FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
