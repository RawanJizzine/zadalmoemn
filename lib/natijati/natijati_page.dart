import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NatijatiPage extends StatefulWidget {
  final int competitionId;

  const NatijatiPage({Key? key, required this.competitionId}) : super(key: key);

  @override
  _NatijatiPageState createState() => _NatijatiPageState();
}

class _NatijatiPageState extends State<NatijatiPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> results = []; // List to store results from API
 
  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    final accessToken = await storage.read(key: 'token');
    final storedUserId = await storage.read(key: 'user_id');
    final competitionId =
        widget.competitionId; // Get the competitionId from the widget
    print('zh2na');
    print(storedUserId);
    try {
      final response = await http.get(
        Uri.parse(
            'http://zadalmomen.com/api/getnatijatiestkhfar?competition_id=$competitionId&user_id=$storedUserId'), // Use query parameter
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('sucees');
        setState(() {
         
          results = json.decode(response.body);
        });
      } else {
       
        print('Failed to load results');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl, // Set the text direction to right-to-left
      child: Scaffold(
        appBar: AppBar(
           leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white), // Customize the back icon color
    onPressed: () {
      Navigator.pop(context); // Action to go back
    },
  ),
          flexibleSpace: FlexibleSpaceBar(
    centerTitle: true,
    title: Text(
      'نتيجتي',
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontFamily: 'primary',
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
    ),
  ),
          backgroundColor: const Color(0xff104F59),
        ),
        body: results.isEmpty
            ? const Center(child: Text('No data available')) // Show a loading indicator while fetching data
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Add spacing below the AppBar
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return InkWell(
                          onTap: () {
                            // Handle tap event
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'اليوم ${index + 1} :', // Use string interpolation to include the index + 1 value
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontFamily: 'primary',
                                              fontSize: 22,
                                              color: const Color(0xff104F59),
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      result['date'] ??
                                          'N/A', // Update with actual date field
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontFamily: 'primary',
                                              fontSize: 22,
                                              color: const Color(0xff104F59),
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height:
                                        5), // Add a small space between the texts
                                Row(
                                  children: [
                                    Text(
                                      'المجموع :',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontFamily: 'primary',
                                              fontSize: 22,
                                              color: const Color(0xff104F59),
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      result['counter_value']?.toString() ??
                                          '', // Update with actual competition field
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontFamily: 'primary',
                                              fontSize: 22,
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  thickness: 1.5,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
