import 'package:expense_tracker/screens/home%20screen/home_screen.dart';
import 'package:expense_tracker/screens/currency%20selector/currency_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{

  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(vsync: this, duration: Duration(seconds: 3));
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 0.1).animate(animation);
    
    animation.addListener((){
      if(animation.isCompleted){
        animation.reverse();
      } else{
        animation.forward();
      }
    });
    animation.repeat();
    
    _checkCurrency();
  }

  Future _checkCurrency() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isCurrencySelected = prefs.getBool("currency_selected");

    await Future.delayed(Duration(seconds: 1));

    if(isCurrencySelected == true){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CurrencyPickerScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: animation,
          child: Text(
            'Budget Tracker',
            style: TextStyle(
              fontFamily: "Sen",
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}
