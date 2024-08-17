import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCompetitionPage extends StatefulWidget {
  const AddCompetitionPage({super.key});

  @override
  _AddCompetitionPageState createState() => _AddCompetitionPageState();
}

class _AddCompetitionPageState extends State<AddCompetitionPage> {
  final _formKey = GlobalKey<FormState>();

  String? responsiblePerson;
  String? competitionType;
  String? instagramLink;
  DateTime? startDate;
  DateTime? endDate;
  File? _image;
  int? numberOfCompetition;

  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();
  final List<String> competitionTypes = ['مسابقة إستغفار', 'مسابقة صلوات'];

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

      try {
        final accessToken = await storage.read(key: 'token');

        if (accessToken == null) {
          throw Exception('No token found');
        }

        var uri = Uri.parse('http://zadalmomen.com/api/competitions');
        var request = http.MultipartRequest('POST', uri);

        request.headers['Authorization'] = 'Bearer $accessToken';
        request.headers['Content-Type'] = 'multipart/form-data';

        request.fields['name'] = responsiblePerson ?? '';
        request.fields['type'] = competitionType ?? '';
        request.fields['instagram'] = instagramLink ?? '';
        request.fields['start_date'] = startDate?.toIso8601String() ?? '';
        request.fields['end_date'] = endDate?.toIso8601String() ?? '';
        request.fields['competition_number'] = numberOfCompetition?.toString() ?? '';

        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
        }

        // Log request details
        print('Request URL: ${request.url}');
        print('Request Headers: ${request.headers}');
        print('Request Fields: ${request.fields}');
        print('Request Files: ${request.files.map((file) => file.filename).toList()}');

        var response = await request.send();

        // Log response details
        print('Response Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');

        response.stream.bytesToString().then((value) {
          if (response.statusCode == 201) {
            var jsonResponse = jsonDecode(value);
            print("Competition saved successfully: ${jsonResponse['message']}");

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Competition saved successfully!')),
            );

            _formKey.currentState?.reset();
            setState(() {
              responsiblePerson = null;
              competitionType = null;
              instagramLink = null;
              startDate = null;
              endDate = null;
              _image = null;
              numberOfCompetition = null;
            });
          } else {
            print("Failed to save competition: $value");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save competition.')),
            );
          }
        });
      } catch (e) {
        print("Error occurred: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred while saving competition.')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff104F59),
        title: const Text('Add Competition Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the responsible person';
                  }
                  return null;
                },
                onSaved: (value) {
                  responsiblePerson = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Competition Type ',
                ),
                items: competitionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    competitionType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a competition type';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Link of your Instagram',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Instagram link';
                  }
                  return null;
                },
                onSaved: (value) {
                  instagramLink = value;
                },
              ),
              ListTile(
                title: Text("Start Date: ${startDate == null ? '' : DateFormat('yyyy-MM-dd').format(startDate!)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context, true);
                },
              ),
              ListTile(
                title: Text("End Date: ${endDate == null ? '' : DateFormat('yyyy-MM-dd').format(endDate!)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context, false);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'max number of subscriber',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of competition';
                  }
                  return null;
                },
                onSaved: (value) {
                  numberOfCompetition = int.tryParse(value!);
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
