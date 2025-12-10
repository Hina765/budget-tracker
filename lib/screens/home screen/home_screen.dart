import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/screens/currency%20selector/currency_picker_screen.dart';
import 'package:expense_tracker/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> myData = [];

  String currencySymbol = " ";

  bool _isLoading = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    loadCurrencySymbol();
  }

  Future<void> loadCurrencySymbol() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currencySymbol = prefs.getString("currency_symbol") ?? "₹";
    });
  }

  Future _loadData({String query = ''}) async {
    setState(() {
      _isLoading = true;
    });

    final data = query.isEmpty
        ? await DbHelper.readItems()
        : await DbHelper.searchItems(query);

    double income = 0;
    double expense = 0;

    for (var item in data) {
      if (item['type'] == 'income') {
        income += item['amount'];
      } else {
        expense += item['amount'];
      }
    }

    setState(() {
      myData = data;
      totalIncome = income;
      totalExpense = expense;
      _isLoading = false;
    });
  }

  Future deleteItem(int id) async {
    await DbHelper.deleteItem(id);
    _loadData();
  }

  Future<void> _openAddSheet({Map<String, dynamic>? expense}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseScreen(expense: expense),
    );
    if (changed == true) await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final netBalance = totalIncome - totalExpense;

    return Scaffold(

      appBar: AppBar(

        automaticallyImplyLeading: false,

        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hint: AppText('Search transactions...', 18, Colors.grey, FontWeight.w500),
            border: InputBorder.none,
          ),
          onChanged: (value) => _loadData(query: value),
        )
        : AppText('BudgetTracker', 25, Colors.black, FontWeight.bold),

        actions: [
          _isSearching
          ? IconButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _loadData();
              });
            },
            icon: const Icon(Icons.close, color: Colors.black, size: 25),
          )
          : IconButton(
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
            icon: const Icon(Icons.search, color: Colors.black, size: 25),
          ),

          const SizedBox(width: 10),

          IconButton(
            onPressed: () async{
              final updated = await Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CurrencyPickerScreen())
              );

              if(updated == true){
                await loadCurrencySymbol();
                await _loadData();
              }
            },
            icon: Icon(Icons.currency_exchange, color: Colors.black, size: 25)
          )
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // total net balance
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText('Net Balance', 18, Colors.deepPurpleAccent,
                        FontWeight.w600),
                    AppText(
                        '$currencySymbol${netBalance.toStringAsFixed(2)}',
                        32,
                        Colors.deepPurple,
                        FontWeight.bold
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // total income & expense
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // income container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.44,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green),
                              child: const Icon(Icons.arrow_downward,
                                  color: Colors.white, size: 25),
                            ),
                            const SizedBox(width: 10),
                            AppText('Income', 18, Colors.black, FontWeight.w700)
                          ],
                        ),

                        const SizedBox(height: 10),

                        AppText(
                            '$currencySymbol${totalIncome.toStringAsFixed(2)}',
                            20,
                            Colors.green,
                            FontWeight.bold
                        )
                      ],
                    ),
                  ),

                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                  // expense container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.44,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red),
                              child: const Icon(Icons.arrow_upward,
                                  color: Colors.white, size: 25),
                            ),
                            const SizedBox(width: 10),
                            AppText('Expense', 18, Colors.black, FontWeight.w700)
                          ],
                        ),

                        const SizedBox(height: 10),

                        AppText(
                            '$currencySymbol${totalExpense.toStringAsFixed(2)}',
                            20,
                            Colors.red,
                            FontWeight.bold
                        )
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              AppText('Transactions', 22, Colors.black, FontWeight.bold),

              const SizedBox(height: 20),

              myData.isEmpty
                  ? Column(
                    children: [
                      Center(
                        child: AppText('No transactions found', 20,
                            Colors.black, FontWeight.w600),
                      ),
                    ],
                  )

                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myData.length,
                      itemBuilder: (_, index) {
                        final item = myData[index];
                        final createdAtString =
                            item['createdAt'] ?? item['createdAT'];
                        final createdAt = createdAtString != null
                            ? DateTime.parse(createdAtString as String)
                            : DateTime.now();

                        return Dismissible(
                          key: ValueKey(item['id']),
                          direction: DismissDirection.endToStart, // swipe right → left only

                          // Background while swiping
                          background: Container(
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            color: Colors.red.shade400,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Icon(Icons.edit, color: Colors.white, size: 28),
                                SizedBox(width: 25),
                                Icon(Icons.delete, color: Colors.white, size: 28),
                              ],
                            ),
                          ),

                          confirmDismiss: (direction) async {
                            return await showModalBottomSheet<bool>(
                              context: context,

                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                              builder: (context) {
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.25,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        AppText("Actions", 20, Colors.black, FontWeight.bold),

                                        const SizedBox(height: 20),

                                        // EDIT
                                        ListTile(
                                          leading: Icon(Icons.edit, color: Colors.blue),
                                          title: AppText("Edit", 18, Colors.black, FontWeight.w500),
                                          onTap: () {
                                            Navigator.pop(context, false);
                                            _openAddSheet(expense: item);
                                          },
                                        ),

                                        // DELETE
                                        ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: AppText("Delete", 18, Colors.black, FontWeight.w500),
                                          onTap: () async {
                                            Navigator.pop(context, false);
                                            await deleteItem(item['id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },

                          child: Card(
                            color: Colors.white,
                            child: ListTile(
                              onTap: () => _openAddSheet(expense: item), // edit on tap

                              title: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: AppText(item['notes'], 18, Colors.black, FontWeight.w800),
                              ),

                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: AppText(
                                    DateFormat.yMMMd().format(createdAt),
                                    16,
                                    Colors.black54,
                                    FontWeight.w600
                                ),
                              ),

                              trailing: AppText(
                                '$currencySymbol${item['amount'].toStringAsFixed(2)}',
                                18,
                                item['type'] == 'income' ? Colors.green : Colors.red,
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        );

                      }),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _openAddTransactionSheet(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

    );
  }

  void _openAddTransactionSheet() async {
    final changed = await showModalBottomSheet<bool>(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => AddExpenseScreen());
    if (changed == true) _loadData();
  }

  String _shortMonth(int month) {
    const m = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return m[month - 1];
  }
}
