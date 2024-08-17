import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadalmoemn/addcompetition/addcompetition_page.dart';
import 'package:zadalmoemn/addsubscribe/addsubscribe_page.dart';
import 'package:zadalmoemn/adduser/adduser_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zadalmoemn/login/login.dart';
import 'package:zadalmoemn/salawat/salawat_page.dart';
import '../estkhfar/estkhfar_page.dart'; // Import the EstkhfarPage

class CompetitionsPage extends StatefulWidget {
  const CompetitionsPage({Key? key}) : super(key: key);

  @override
  _CompetitionsPageState createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends State<CompetitionsPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> competitions = [];
  bool isLoading = true;
  String? userId;
  String? userType;
  @override
  void initState() {
    super.initState();
    fetchUserIdAndCompetitions();
  }

  Future<void> fetchUserIdAndCompetitions() async {
    final storedUserId = await storage.read(key: 'user_id');
    final accessToken = await storage.read(key: 'token');
    final storedUserType = await storage.read(key: 'user_type');
    if (storedUserId == null || accessToken == null) {
      throw Exception('No user ID or access token found');
    }

    setState(() {
      userId = storedUserId;
      userType = storedUserType;
      print('user type $userType');
      print('User ID: $userId');
      print('Access Token: $accessToken');
    });
   
    await fetchCompetitions(storedUserId, accessToken);
  }


  Future<void> fetchCompetitions(String userId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/getusercompetitions/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Log status code and response body for debugging
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          competitions = json.decode(response.body);
          print(competitions);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load competitions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error
      print('Error: $e');
      setState(() {
        isLoading = false; // Stop loading indicator
      });
      // Optionally, show an alert or error message to the user
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.tryParse(url) ?? Uri();
    if (uri.hasScheme && uri.hasAuthority) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      throw 'Invalid URL: $url';
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all stored values
    prefs.setBool('isLoggedIn', false);

    // Clear all stored values
    await storage.deleteAll();
    // Navigate to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Color _getStatusColor(String? status) {
    print(status);
    switch (status) {
      case 'new':
        return Colors.red;
      case 'active':
        return Colors.green;
      case 'old':
        return Colors.grey;
      default:
        return Colors.grey; // Default color if status is null or unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl, // Set the text direction to right-to-left
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              color: Colors.white,
              iconSize: 25,
              icon: const Icon(Icons.more_vert), // Use the more_vert icon
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              'تسجيل الخروج',
                              textDirection: TextDirection.rtl,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      fontFamily: 'primary',
                                      fontSize: 22,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              _logout(context);
                            },
                          ),
                          const Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 129, 122, 122),
                          ),
                          if (userType == 'admin') ...[
                            ListTile(
                              title: Text(
                                'إضافة مسابقة',
                                textDirection: TextDirection.rtl,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        fontFamily: 'primary',
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddCompetitionPage(), // Navigate to the new page
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 129, 122, 122),
                            ),
                            ListTile(
                              title: Text(
                                'إضافة مشتركين',
                                textDirection: TextDirection.rtl,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        fontFamily: 'primary',
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddSubscribePage(), // Navigate to the new page
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 129, 122, 122),
                            ),
                            ListTile(
                              title: Text(
                                "إضافة مستخدمين",
                                textDirection: TextDirection.rtl,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        fontFamily: 'primary',
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddUserPage(), // Navigate to the new page
                                  ),
                                );
                              },
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
    centerTitle: true,
    title: Text(
      'مسابقة',
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
        body: competitions.isNotEmpty
            ? Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: competitions.length,
                      itemBuilder: (context, index) {
                        final competition = competitions[index]['competition'];
                        final  today = competitions[index]['today'];
                        return InkWell(
                          onTap: () {
                            if (competition['status'] != 'new') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    if (competition['type'] == "مسابقة صلوات") {
                                      return SalawatPage(
                                        competitionId: competition['id'],
                                        endDate: competition['end_date'],
                                        startDate: competition['start_date'],
                                        today: today,
                                      
                                      );
                                    } else {
                                      return EstkhfarPage(
                                        competitionId: competition['id'],
                                        endDate: competition['end_date'],
                                        startDate: competition['start_date'],
                                         today: today,
                                      );
                                    }
                                  },
                                ),
                              );
                            } else {
                              // Optionally, show a message or alert to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'You cannot access this competition yet.'),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: ClipOval(
                                        child: competition['image'] != null
                                            ? Image.network(
                                                'http://zadalmomen.com/imageapp/${competition['image']}',
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 60,
                                              )
                                            : Image.asset(
                                                'assets/icon/person.jpeg',
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 60,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            competition['name'] ?? 'N/A',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  fontFamily: 'primary',
                                                  fontSize: 20,
                                                  color: const Color(0xff104F59),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            competition['type'] ?? 'N/A',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  fontFamily: 'primary',
                                                  fontSize: 14,
                                                  color: const Color.fromARGB(255, 0, 0, 0),
                                                  fontWeight: FontWeight.w200,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            competition['status']),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          competition['status'] ?? 'N/A',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                fontFamily: 'primary',
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (competition['instagram_image'] != null)
                                      InkWell(
                                        onTap: () {
                                          final url =
                                              competition['instagram'] ?? '';
                                          if (url.isNotEmpty) {
                                            _launchURL(url);
                                          } else {
                                            print('Invalid URL');
                                          }
                                        },
                                        child: Image.network(
                                          competition['instagram_image'],
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    if (competition['instagram_image'] == null)
                                      Image.asset(
                                        'assets/icon/insta.jpeg',
                                        width: 28,
                                        height: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(child: Text('No data available')),
      ),
    );
  }
}
