import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadalmoemn/home/home_page.dart';
import 'package:zadalmoemn/login/login.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    handleTimezoneConversion();
    _checkFirstLaunch();
  }
 
  void handleTimezoneConversion() async {
    try {
      String timezone = await getTimezone();
      await convertTimestamps(timezone);
    } catch (e) {
      print('Error handling timezone conversion: $e');
    }
  }

  Future<String> getTimezone() async {
    // Ensure the timezone data is initialized
    tz_data.initializeTimeZones();
    // Use the current location
    final String currentTimezone = tz.local.name;
    print('Timezone: $currentTimezone');
    return currentTimezone;
  }

  Future<void> convertTimestamps(String timezone) async {
    final url = Uri.parse('https://127.0.0.1:8000/api/convert-timestamps');

    final response = await http.post(
      url,
      body: {'timezone': 'Asia/Beirut'},
    );

    if (response.statusCode == 200) {
      print('Timestamps converted successfully');
    } else {
      print('Failed to convert timestamps');
    }
  }
  _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      prefs.setBool('isFirstLaunch', false);
      _navigateToLoginOrHome();
    } else {
      _navigateToLoginOrHome(showSplash: true);
    }
  }

  _navigateToLoginOrHome({bool showSplash = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
print(isLoggedIn);
    if (showSplash) {
      print('splash');
      await Future.delayed(const Duration(seconds: 4)); // Simulate a splash screen delay
    }

    if (isLoggedIn) {
      print('login done');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
         print('login not done');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 300,
              height: 300,
              // Adjust width and height as needed
            ),
          ],
        ),
      ),
    );
  }
}
