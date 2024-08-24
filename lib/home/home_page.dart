import 'package:flutter/material.dart';
import 'package:zadalmoemn/competition/competitions.dart';
import 'package:zadalmoemn/results/results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Color kPrimaryColor = const Color(0xff104F59);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex == 0) {
          return true;
        } else {
          setState(() {
            currentIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: const [
            CompetitionsPage(),
            ResultsPage(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(0),
          child: Card(
            child: PhysicalModel(
              color: Colors.grey,
              elevation: 2,
              shadowColor: Colors.grey,
              borderRadius: BorderRadius.circular(5),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 50,
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icon/homeoff.jpeg',
                      width: 80,
                      height: 42,
                    ),
                    label: '',
                    activeIcon: Image.asset(
                      'assets/icon/homeon.jpeg',
                      width: 80,
                      height: 42,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icon/icontwo.jpeg',
                      width: 80,
                      height: 42,
                    ),
                    label: '',
                    activeIcon: Image.asset(
                      'assets/icon/iconone.jpeg',
                      width: 80,
                      height: 42,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
