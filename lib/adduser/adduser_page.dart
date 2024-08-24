import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  String? fullName;
  String? username;
  String? emailOrPhone;
   String? phone;
  String? password;
  File? _image;
  final _picker = ImagePicker();
  final _storage = const FlutterSecureStorage();
  
   Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> handleSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final accessToken = await _storage.read(key: 'token');
      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No token found')));
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse('https://zadalmomen.com/api/users'));
      
      request.headers['Authorization'] = 'Bearer $accessToken';

      request.fields['full_name'] = fullName!;
      request.fields['email'] = emailOrPhone!;
      request.fields['password'] = password!;
      request.fields['username'] = username!;
      request.fields['phone_number'] = phone!;

      if (_image != null) {
        try {
          request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
          print("Image added to request: ${_image!.path}"); // Debug: Confirm image is added
        } catch (e) {
          print("Error adding image: $e"); // Debug: Catch and print errors
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error adding image')));
        }
      } else {
        print("No image to add");
      }

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added successfully!')));
          _formKey.currentState?.reset();
          setState(() {
            fullName = null;
            username=null;
            phone=null;
            emailOrPhone = null;
            password = null;
            _image = null;
          });
        } else {
          print("Failed to add user, status code: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add user.')));
        }
      } catch (e) {
        print("Error occurred while adding user: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error occurred while adding user')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User Page'),
        backgroundColor: const Color(0xff104F59),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the full name';
                  }
                  return null;
                },
                onSaved: (value) {
                  fullName = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'UserName',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the user name';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'EmailorPhone',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email or phone';
                  }
                  return null;
                },
                onSaved: (value) {
                  emailOrPhone = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the  phone';
                  }
                  return null;
                },
                onSaved: (value) {
                  phone = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Center(
                        child: Container(
                          height: 100,
                          width: 110,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                      )
                    : Center(
                        child: Image.file(
                          _image!,
                          height: 100,
                          width: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
             ElevatedButton(
  onPressed: handleSave,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xff104F59), // Set the background color here
  ),
  child: const Text('Save'),
)
            ],
          ),
        ),
      ),
    );
  }
}
