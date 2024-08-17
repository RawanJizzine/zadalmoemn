import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final storage = const FlutterSecureStorage();
  TextEditingController username = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  String? imageUrl;
  File? _image;
  final _picker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final storedUserId = await storage.read(key: 'user_id');
    final accessToken = await storage.read(key: 'token');

    if (storedUserId == null || accessToken == null) {
      setState(() {
        isLoading = false;
      });
      throw Exception('No user ID or access token found');
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/getuser/$storedUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username.text = data['username'] ?? '';
          phoneNumber.text = data['phone_number'] ?? '';
          imageUrl = data['image'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserData() async {
  final storedUserId = await storage.read(key: 'user_id');
  final accessToken = await storage.read(key: 'token');

  if (storedUserId == null || accessToken == null) {
    setState(() {
      isLoading = false;
    });
    throw Exception('No user ID or access token found');
  }

  setState(() {
    isLoading = true;
  });

  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.26:8000/api/updateuser/$storedUserId'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['username'] = username.text;
    request.fields['phone_number'] = phoneNumber.text;

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully')),
      );

      // Optionally, fetch updated user data
      fetchUserData();
    } else {
      throw Exception('Failed to update user data');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
    centerTitle: true,
    title: Text(
      'حسابي',
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontFamily: 'primary',
            fontSize: 22,
            color:  Colors.white,
            fontWeight: FontWeight.bold,
          ),
    ),
  ),
          backgroundColor: const Color(0xff104F59),
        ),
        body:  SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                     Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 120),
    child: GestureDetector(
      onTap: _pickImage,
      child: _image == null
          ? (imageUrl != null && imageUrl!.isNotEmpty
              ? SizedBox(
                height: 90,
                width: 90,
                child: ClipOval(
                    child: Image.network(
                      'http://10.0.2.2:8000/images/$imageUrl',
                      fit: BoxFit.cover,
                    ),
                  ),
              )
              : SizedBox(
                height: 90,
                width: 90,
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/iconone.jpeg',
                  ),
                ),
              ))
          : SizedBox(
            height: 90,
            width: 90,
            child: ClipOval(
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ),
              ),
          ),
    ),
  ),
),
                      const SizedBox(height: 25),
                      Text(
                        'إسم حسابك',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontFamily: 'primary',
                            fontSize: 16,
                            color: const Color(0xff104F59),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: username,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'رقم هاتفك',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontFamily: 'primary',
                            fontSize: 16,
                            color: const Color(0xff104F59),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: phoneNumber,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!_isValidPhoneNumber(value)) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                
                                    updateUserData();
                                  
                                },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                const Color(0xff104F59)),
                          ),
                          child: const Text('تعديل', style: TextStyle(color: Colors.white),       ),
                        ),
                      ),
                      const SizedBox(height: 23),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  bool _isValidPhoneNumber(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }
}
