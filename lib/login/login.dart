import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zadalmoemn/home/home_page.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailOrPhoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? selectedTimezone;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 250,
                  height: 250,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'Email',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailOrPhoneNumberController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email or phone',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or phone';
                  }
                  if (!_isValidEmail(value) && !_isValidPhoneNumber(value)) {
                    return 'Invalid email or phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 31),
              Text(
                'Password',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text(
                'Timezone',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.075,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xff104F59),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTimezone,
                    elevation: 16,
                    hint: const Text(
                      'Select Timezone',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    onChanged: (String? value) {
                      setState(() {
                        selectedTimezone = value;
                      });
                    },
                    items: tz.timeZoneDatabase.locations.keys.toList().map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            if (selectedTimezone == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a timezone')),
                              );
                              return;
                            }
                            login(
                              emailOrPhoneNumberController.text,
                              passwordController.text,
                              selectedTimezone!,
                            );
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff104F59)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 23),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  bool _isValidPhoneNumber(String value) {
    return double.tryParse(value) != null;
  }

  Future<void> login(String emailOrPhone, String password, String timezone) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/login'), // Adjust the URL as needed
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailOrPhone,
          'password': password,
          'timezone': timezone, // Send the selected timezone to the backend
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        await storage.write(key: 'token', value: responseBody['token']);
        await storage.write(key: 'user_id', value: responseBody['user']['id'].toString());
        await storage.write(key: 'user_type', value: responseBody['user']['type'].toString());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HomePage(), // Navigate to the new page
          ),
        );
      } else {
        try {
          final responseData = jsonDecode(response.body);
          print('Login failed: ${responseData['email']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${responseData['email']}')),
          );
        } catch (e) {
          print('Unexpected response format');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected response format')),
          );
        }
      }
    } catch (e) {
      print('Connection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
