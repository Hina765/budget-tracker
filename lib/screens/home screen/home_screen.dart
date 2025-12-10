import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/screens/currency selector/currency_picker_screen.dart';
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

  String currencySymbol = "₹";

  bool _isLoading = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      currencySymbol = prefs.getString("currency_symbol") ?? "₹";
    });
  }

  Future<void> _loadData({String query = ""}) async {
    setState(() => _isLoading = true);

    final data = query.isEmpty
        ? await DbHelper.readItems()
        : await DbHelper.searchItems(query);

    double income = 0;
    double expense = 0;

    for (var item in data) {
      if (item["type"] == "income") {
        income += item["amount"];
      } else {
        expense += item["amount"];
      }
    }

    if (!mounted) return;

    setState(() {
      myData = data;
      totalIncome = income;
      totalExpense = expense;
      _isLoading = false;
    });
  }

  Future<void> _openAddSheet({Map<String, dynamic>? expense}) async {
    final changed = await showModalBottomSheet<bool>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseScreen(expense: expense),
    );

    if (changed == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _deleteItem(int id) async {
    await DbHelper.deleteItem(id);
    if (mounted) await _loadData();
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
          decoration: const InputDecoration(
            hintText: "Search transactions…",
            border: InputBorder.none,
          ),
          onChanged: (value) => _loadData(query: value),
        )
            : AppText("BudgetTracker", 25, Colors.black, FontWeight.bold),
        actions: [
          _isSearching
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              setState(() => _isSearching = false);
              _searchController.clear();
              _loadData();
            },
          )
              : IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              setState(() => _isSearching = true);
            },
          ),

          // Currency Button
          IconButton(
            icon: const Icon(Icons.currency_exchange, color: Colors.black),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CurrencyPickerScreen()),
              );

              if (updated == true) {
                await _loadCurrencySymbol();
                await _loadData();
              }
            },
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NET BALANCE CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  AppText("Net Balance", 18, Colors.deepPurple,
                      FontWeight.w600),
                  AppText(
                      "$currencySymbol${netBalance.toStringAsFixed(2)}",
                      32,
                      Colors.deepPurpleAccent,
                      FontWeight.bold),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // INCOME & EXPENSE CARDS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  title: "Income",
                  amount: totalIncome,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
                _buildStatCard(
                  title: "Expense",
                  amount: totalExpense,
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
              ],
            ),

            const SizedBox(height: 25),

            AppText("Transactions", 22, Colors.black, FontWeight.bold),
            const SizedBox(height: 15),

            myData.isEmpty
                ? Center(
              child: AppText(
                  "No transactions found",
                  20,
                  Colors.black87,
                  FontWeight.w600),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: myData.length,
              itemBuilder: (_, index) {
                final item = myData[index];
                final createdAt =
                DateTime.parse(item["createdAt"]);

                return _buildDismissibleItem(item, createdAt);
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _openAddSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ======= STAT CARD =======
  Widget _buildStatCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 25,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            AppText(title, 18, Colors.black, FontWeight.bold),
          ]),
          const SizedBox(height: 10),
          AppText("$currencySymbol${amount.toStringAsFixed(2)}", 20, color,
              FontWeight.bold),
        ],
      ),
    );
  }

  // ======= DISMISSIBLE ITEM =======
  Widget _buildDismissibleItem(
      Map<String, dynamic> item, DateTime createdAt) {
    return Dismissible(
      key: ValueKey(item["id"]),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete"),
            content: const Text("Are you sure you want to delete?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(item["id"]),
      child: _buildTransactionItem(item, createdAt),
    );
  }

  // ======= TRANSACTION ITEM =======
  Widget _buildTransactionItem(
      Map<String, dynamic> item, DateTime createdAt) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: () => _openAddSheet(expense: item),
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: AppText(item["notes"], 18, Colors.black, FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: AppText(DateFormat.yMMMd().format(createdAt), 15,
              Colors.black54, FontWeight.w500),
        ),
        trailing: AppText(
          "$currencySymbol${item['amount'].toStringAsFixed(2)}",
          18,
          item["type"] == "income" ? Colors.green : Colors.red,
          FontWeight.bold,
        ),
      ),
    );
  }
}
