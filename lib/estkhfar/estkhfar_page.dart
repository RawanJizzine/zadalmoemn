import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zadalmoemn/nataeej/nataeej_page.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zadalmoemn/natijati/natijati_page.dart';

class EstkhfarPage extends StatefulWidget {
   final int competitionId;
  final String endDate;
  final String startDate;
  final String today;

  const EstkhfarPage({super.key, 
    required this.competitionId,
    required this.endDate,
    required this.startDate,
    required this.today
  });
  @override
  _EstkhfarPageState createState() => _EstkhfarPageState();
}

class _EstkhfarPageState extends State<EstkhfarPage> {
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
        Uri.parse('http://zadalmomen.com/api/getcounterestkhfar?competition_id=${widget.competitionId}&user_id=$storedUserId'),
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
  

    // Get the current date and time in the specified timezone
   
    final startDate = DateTime.parse(widget.startDate);
    final endDate = DateTime.parse(widget.endDate);

   DateTime today = DateTime.parse(widget.today).toLocal();
    print('jizzineeeeeeeeeeeeee');
    print(today);


    if (today.isBefore(startDate) || today.isAfter(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لقد انتهت المسابقة"),
        ),
      );
      return;
    }

    if (today.weekday == DateTime.friday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا يمكن زيادة العداد يوم الجمعة"),
        ),
      );
      return;
    }

    setState(() {
      counter++;
    });
    await saveCounterValue();
  }
  Future<void> saveCounterValue() async {
    final accessToken = await storage.read(key: 'token');
    final storedUserId = await storage.read(key: 'user_id');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://zadalmomen.com/api/savecounterestkhfar')
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
      'الإستغفار',
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontFamily: 'primary',
            fontSize: 22,
            color:  Colors.white,
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
                      title: Text(
                        'نتيجتي',
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontFamily: 'primary',
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NatijatiPage(
                              competitionId: widget.competitionId,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 1,
                      color: Color.fromARGB(255, 129, 122, 122),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NataeejPage(
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
                
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Card(
                        color: Color(0xff104F59),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
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
                                'فَقُلْتُ اسْتَغْفِرُوا رَبَّكُمْ إِنَّهُ كَانَ غَفَّارًا (10)',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'يُرْسِلِ السَّمَاءَ عَلَيْكُم مِّدْرَارًا (11)',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  'وَيُمْدِدْكُم بِأَمْوَالٍ وَبَنِينَ وَيَجْعَل لَّكُمْ ',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontFamily: 'primary',
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  ' جَنَّاتٍ وَيَجْعَل لَّكُمْ أَنْهَارًا (12)',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontFamily: 'primary',
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
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
                    flex: 2,
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
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'الذكر الملزم به: ',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 18,
                                  color: const Color(0xff104F59),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '"أستغفر الله ربي وأتوب إليه"',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontFamily: 'primary',
                                  fontSize: 18,
                                  color: const Color(0xff104F59),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    child: Text(
                      'شرط المشاركة: أيُّ شخصٍ معنا غَيرُ مُسَامَحٍ شَرْعًا مِنِّي ولا مِن أيِّ مُشْتَرِكٍ مُلْتَزِمٍ بهذا الشرطِ أن يَغُشَّ،إذا عن عَمدٍ.. ضَغَطَ العَدَّادَ ولم يَقُلْ هذا القَولَ المُلزَمَ به كامِلًا.  ',
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
