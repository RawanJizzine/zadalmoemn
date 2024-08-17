import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zadalmoemn/addsubscribe/user.dart';

class AddSubscribePage extends StatefulWidget {
  const AddSubscribePage({super.key});

  @override
  _AddSubscribePageState createState() => _AddSubscribePageState();
}

class _AddSubscribePageState extends State<AddSubscribePage> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  User? selectedUser;
  DateTime? startDate;
  DateTime? endDate;
  String? competitionType;
  List<User> userOptions = [];
  List<User> filteredUserOptions = [];
  List<String> competitionTypeOptions = ['Type 1', 'Type 2'];
  List<Map<String, dynamic>> _competitions = [];
  String? _selectedCompetition;

  Future<void> fetchUsers([String? query]) async {
    final accessToken = await storage.read(key: 'token');

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('http://zadalmomen.com/api/getusers${query != null ? '?search=$query' : ''}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      setState(() {
        userOptions = users.map((user) => User(id: user['id'].toString(), name: user['full_name'].toString())).toList();
        filteredUserOptions = userOptions;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _fetchCompetitions() async {
    final accessToken = await storage.read(key: 'token');

    if (accessToken == null) {
      throw Exception('No access token found');
    }
    try {
      final response = await http.get(
        Uri.parse('http://zadalmomen.com/api/getcompetitions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _competitions = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load competitions');
      }
    } catch (e) {
      // Handle errors here, like showing a message to the user
      print(e);
    }
  }

  Future<void> _fetchCompetitionDetails(String competitionId) async {
    final accessToken = await storage.read(key: 'token');

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('http://zadalmomen.com/api/getcompetitiondetails/$competitionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        startDate = DateTime.parse(data['start_date']);
        endDate = DateTime.parse(data['end_date']);
      });
    } else {
      throw Exception('Failed to load competition details');
    }
  }

  Future<void> _saveSubscription() async {
    final accessToken = await storage.read(key: 'token');

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('http://zadalmomen.com/api/addsubscription'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'user_id': selectedUser?.id,
        'competition_id': _selectedCompetition,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'competition_type': 'go',
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful save
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription saved successfully!')));
      print('Subscription saved successfully');
    } else {
      // Handle save error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save subscription!')));
      print('Failed to save subscription');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _fetchCompetitions();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void handleSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _saveSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscribe Page'),
        backgroundColor: const Color(0xff104F59),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Competition With',
                ),
                value: _selectedCompetition,
                items: _competitions.map((competition) {
                  return DropdownMenuItem<String>(
                    value: competition['id'].toString(),
                    child: Text(competition['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCompetition = newValue;
                  });
                  if (newValue != null) {
                    _fetchCompetitionDetails(newValue);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a competition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15,),
              CustomSearchableDropdown<User>(
                items: filteredUserOptions,
                value: selectedUser,
                hintText: 'Select User',
                searchHintText: 'Search User',
                onChanged: (newValue) {
                  setState(() {
                    selectedUser = newValue;
                  });
                },
                onSearch: (value) {
                  setState(() {
                    filteredUserOptions = userOptions
                        .where((option) => option.name.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 15,),
              ListTile(
                title: Text('Start Date: ${startDate != null ? DateFormat.yMd().format(startDate!) : ''}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 15,),
              ListTile(
                title: Text('End Date: ${endDate != null ? DateFormat.yMd().format(endDate!) : ''}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
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

class CustomSearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String hintText;
  final String searchHintText;
  final ValueChanged<T?> onChanged;
  final ValueChanged<String> onSearch;

  const CustomSearchableDropdown({super.key, 
    required this.items,
    required this.value,
    required this.hintText,
    required this.searchHintText,
    required this.onChanged,
    required this.onSearch,
  });

  @override
  _CustomSearchableDropdownState<T> createState() =>
      _CustomSearchableDropdownState<T>();
}

class _CustomSearchableDropdownState<T>
    extends State<CustomSearchableDropdown<T>> {
  T? _selectedItem;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.value;
    _searchController.addListener(() {
      widget.onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchHintText,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: _selectedItem,
          hint: Text(widget.hintText),
          onChanged: (newValue) {
            setState(() {
              _selectedItem = newValue;
            });
            widget.onChanged(newValue);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select an item';
            }
            return null;
          },
          items: widget.items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
        ),
      ],
    );
  }
}
