import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/bmi_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const VMAApp());
}

class VMAApp extends StatelessWidget {
  const VMAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens = [
    HomeScreen(
      onNavigate: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    const CalculatorScreen(),
    const BMIScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Domů',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Kalkulačka',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: 'BMI',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Hlavní obrazovka';
      case 1:
        return 'Kalkulačka';
      case 2:
        return 'BMI Kalkulačka';
      default:
        return 'VMA App';
    }
  }
}
