import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NataeejSalawatPage extends StatefulWidget {
  final int competitionId;
  const NataeejSalawatPage({Key? key, required this.competitionId}) : super(key: key);

  @override
  _NataeejSalawatPageState createState() => _NataeejSalawatPageState();
}

class _NataeejSalawatPageState extends State<NataeejSalawatPage> {
  List<Map<String, dynamic>> competitionData = [];
  final storage = const FlutterSecureStorage();
  bool isLoading = true;

  Future<void> fetchCompetitionData() async {
    final accessToken = await storage.read(key: 'token');
    String url = 'https://api.zadalmomen.com/api/getnataeejsalawat/${widget.competitionId}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          competitionData = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load competition data');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompetitionData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set the text direction to right-to-left
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // Customize the back icon color
            onPressed: () {
              Navigator.pop(context); // Action to go back
            },
          ),
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              'النتائج',
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator
            : competitionData.isEmpty
                ? const Center(child: Text('لا توجد بيانات متاحة')) // Show message when no data is available
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: competitionData.length,
                          itemBuilder: (context, index) {
                            final data = competitionData[index];
                            return InkWell(
                              onTap: () {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: ClipOval(
                                              child: data['image'] != null && data['image'].isNotEmpty
                                                  ? Image.network(
                                                      'https://api.zadalmomen.com/images/${data['image']}',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset('assets/icon/person.jpeg'),
                                            ),
                                          ),
                                          const SizedBox(width: 10), // Add a small space between image and text
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['full_name'],
                                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                    fontFamily: 'primary',
                                                    fontSize: 22,
                                                    color: const Color(0xff104F59),
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5), // Add a small space between the texts
                                              Row(
                                                children: [
                                                  Text(
                                                    "المجموع",
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        fontFamily: 'primary',
                                                        fontSize: 18,
                                                        color: const Color.fromARGB(255, 0, 0, 0),
                                                        fontWeight: FontWeight.w900),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    ":",
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        fontFamily: 'primary',
                                                        fontSize: 18,
                                                        color: const Color.fromARGB(255, 0, 0, 0),
                                                        fontWeight: FontWeight.w900),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    data['total_counter_value'].toString(),
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        fontFamily: 'primary',
                                                        fontSize: 18,
                                                        color: const Color.fromARGB(255, 0, 0, 0),
                                                        fontWeight: FontWeight.w900),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 1.5,
                                  ),
                                ],
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
