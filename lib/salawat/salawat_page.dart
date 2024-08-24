import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zadalmoemn/salawat/salawat_nataaj.dart';


class SalawatPage extends StatefulWidget {
final int competitionId;
  final String endDate;
  final String startDate;
 final String today;
  const SalawatPage({super.key, 
    required this.competitionId,
    required this.endDate,
    required this.startDate,
    required this.today
  });
  @override
  _SalawatPageState createState() => _SalawatPageState();
}

class _SalawatPageState extends State<SalawatPage> {
  int counter = 0;

  @override
  void initState() {
    super.initState();
    getCounterValue();
  }

  final storage = const FlutterSecureStorage();

  Future<void> getCounterValue() async {
    final accessToken = await storage.read(key: 'token');
    final storedUserId = await storage.read(key: 'user_id');

    try {
      final response = await http.get(
        Uri.parse('https://api.zadalmomen.com/api/getcountersalawat?competition_id=${widget.competitionId}&user_id=$storedUserId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['counter_value'] != null) {
          setState(() {
            counter = responseData['counter_value'] ?? 0;
          });
        }
      } else {
        print('Failed to fetch counter value');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }
Future<void> incrementCounter() async {
   DateTime today = DateTime.parse(widget.today).toLocal();
    final startDate = DateTime.parse(widget.startDate);
    final endDate = DateTime.parse(widget.endDate);
final startDateAdjusted = startDate.subtract(const Duration(hours: 8));

  // Check if the current date is before the startDateAdjusted or after the endDate
  if (today.isBefore(startDateAdjusted) || today.isAfter(endDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("لقد انتهت المسابقة"),
      ),
    );
    return;
  }

  // Increment the counter if conditions are met
  setState(() {
    counter++;
  });

  // Save the updated counter value
  await saveCounterValue();
}
  Future<void> saveCounterValue() async {
    final accessToken = await storage.read(key: 'token');
    final storedUserId = await storage.read(key: 'user_id');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.zadalmomen.com/api/savecountersalawat')
      );

      request.headers['Content-Type'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $accessToken';

      request.fields['competition_id'] = widget.competitionId.toString();
      request.fields['user_id'] = storedUserId!;
      request.fields['counter_value'] = counter.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Counter value saved successfully');
        response.stream.transform(utf8.decoder).listen((value) {
          print('Response body: $value');
        });
      } else {
        print('Failed to save counter value');
        response.stream.transform(utf8.decoder).listen((value) {
          print('Response body: $value');
        });
      }
    } catch (error) {
      print('Error occurred: $error');
    }
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
      'الصلوات',
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontFamily: 'primary',
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
    ),
  ),
      backgroundColor: const Color(0xff104F59),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert,color: Colors.white,),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NataeejSalawatPage(
                              competitionId: widget.competitionId,
                            ),
                          ),
                        );
                      },
                      title: Text(
                        'النتائج',
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontFamily: 'primary',
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Card(
                        color: const Color(0xff104F59),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'بسم الله الرحمن الرحيم',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'إنَّ اللَّهَ وَمَلائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ يَا',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '$counter',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontFamily: 'primary',
                            fontSize: 60,
                            color: const Color(0xff104F59),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SizedBox(
                        height: 120,
                        width: 100,
                        child: FloatingActionButton(
                          onPressed: incrementCounter,
                          backgroundColor: const Color(0xff104F59),
                          child: const Icon(Icons.add, size: 50,color: Colors.white,),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    child: Text(
                      'شرط المشاركة: أيُّ شخصٍ معنا غَيرُ مُسَامَحٍ شَرْعًا مِنِّي ولا مِن أيِّ مُشْتَرِكٍ مُلْتَزِمٍ بهذا الشرطِ أن يَغُشَّ،  إذا عن عَمدٍ.. ضَغَطَ العَدَّادَ ولم يَقُلْ ذكر الصلوات ',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontFamily: 'primary',
                        fontSize: 17,
                        color: const Color(0xff104F59),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ),
);

  }
}
