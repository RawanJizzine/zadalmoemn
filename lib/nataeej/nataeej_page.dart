import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NataeejPage extends StatefulWidget {
  final int competitionId;
  const NataeejPage({Key? key, required this.competitionId}) : super(key: key);

  @override
  _NataeejPageState createState() => _NataeejPageState();
}

class _NataeejPageState extends State<NataeejPage> {
  String? selectedValue;
  final List<String> items = ['النصف النهائي', 'النهائي'];
  List<Map<String, dynamic>> competitionData = [];
  final storage = const FlutterSecureStorage();

  Future<void> fetchCompetitionData(int competitionId, String stage) async {
  final accessToken = await storage.read(key: 'token');
  print(stage);
  print('object');
  String url = 'http://10.0.2.2:8000/api/getcompetitionestkhfar/$competitionId/results?stage=$stage';

  print('Fetching data from: $url');
  print('Using token: $accessToken');

  // Clear the previous competitionData
  setState(() {
    competitionData = [];  // Clear data before fetching new data
  });

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      if (data.isNotEmpty) {
        setState(() {
          competitionData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('No data found for stage: $stage');
        setState(() {
          competitionData = [];  // Ensure data is cleared if no data found
        });
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
      setState(() {
        competitionData = [];  // Ensure data is cleared on failure
      });
    }
  } catch (e) {
    print('Error fetching data: $e');
    setState(() {
      competitionData = [];  // Ensure data is cleared on error
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
            color:  Colors.white,
            fontWeight: FontWeight.bold,
          ),
    ),
  ),
          backgroundColor: const Color(0xff104F59),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
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
                    value: selectedValue,
                    elevation: 16,
                    hint: const Text(
                      'نتائج',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue = value;
                        if (selectedValue != null) {
                          print('Selected value: $selectedValue');
                          fetchCompetitionData(widget.competitionId, selectedValue!);
                        }
                      });
                    },
                    items: items.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: competitionData.length,
                itemBuilder: (context, index) {
                  var data = competitionData[index];
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
                                    child: data['image'] != null
                                        ? Image.network(
                                            'http://zadalmomen.com/images/${data['image']}',
                                            fit: BoxFit.cover,
                                            scale: 1.0,
                                          )
                                        : Image.asset(
                                            'assets/icon/person.jpeg',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data["full_name"]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontFamily: 'primary',
                                              fontSize: 22,
                                              color: const Color(0xff104F59),
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          "المجموع",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontFamily: 'primary',
                                                  fontSize: 18,
                                                  color: const Color.fromARGB(255, 0, 0, 0),
                                                  fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          ":",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontFamily: 'primary',
                                                  fontSize: 18,
                                                  color: const Color.fromARGB(255, 0, 0, 0),
                                                  fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${data['total_counter_value']}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
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
