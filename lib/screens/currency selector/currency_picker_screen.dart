import 'package:country_flags/country_flags.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:expense_tracker/screens/home screen/home_screen.dart';
import 'package:expense_tracker/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPickerScreen extends StatefulWidget {
  const CurrencyPickerScreen({super.key});

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  final _searchController = TextEditingController();

  List<Currency> allCurrencies = [];
  List<Currency> filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  void loadCurrencies() {
    allCurrencies = CurrencyService().getAll();
    filteredCurrencies = allCurrencies;
    setState(() {});
  }

  void filterSearch(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredCurrencies = allCurrencies.where((currency) {
        final name = currency.name.toLowerCase();
        final code = currency.code.toLowerCase();
        final symbol = currency.symbol.toLowerCase();

        return name.contains(query) ||
            code.contains(query) ||
            symbol.contains(query);
      }).toList();
    });
  }

  Future<void> _saveCurrency(Currency currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('currency_symbol', currency.symbol);
    await prefs.setBool("currency_selected", true);

    if (!mounted) return; // FIX: Prevent using context if widget unmounted

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              AppText('Select Currency', 18, Colors.black, FontWeight.bold),
              const SizedBox(height: 20),

              // Search box
              TextField(
                controller: _searchController,
                onChanged: filterSearch,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: "Search currency or country...", // FIXED
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Currency list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListView.builder(
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          child: ClipOval(
                            child: CountryFlag.fromCountryCode(
                                currency.code.substring(0, 2)),
                          ),
                        ),
                        title: AppText(currency.name, 18, Colors.black, FontWeight.bold),
                        subtitle: AppText(currency.code, 16, Colors.black, FontWeight.w300),
                        trailing: AppText(currency.symbol, 22, Colors.black, FontWeight.w500),
                        onTap: () => _saveCurrency(currency),
                      );
                    },
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
