import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _visitCount = 0;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      _visitCount = prefs.getInt('visit_count') ?? 0;
    });
    _incrementVisitCount();
  }

  Future<void> _incrementVisitCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _visitCount++;
    });
    await prefs.setInt('visit_count', _visitCount);
  }

  Future<void> _saveUserName() async {
    if (_nameController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);
      setState(() {
        _userName = _nameController.text;
      });
      _nameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jméno uloženo!')),
      );
    }
  }

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _userName = '';
      _visitCount = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data smazána!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vítejte v aplikaci!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_userName.isNotEmpty)
                    Text(
                      'Jméno: $_userName',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  Text(
                    'Počet návštěv: $_visitCount',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Uložit své jméno:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Zadejte jméno',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveUserName,
                child: const Text('Uložit'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Spacer(),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Kalkulačka'),
              subtitle: const Text('Základní matematické operace'),
              onTap: () {
                // Navigate to calculator tab
                widget.onNavigate(1);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('BMI Kalkulačka'),
              subtitle: const Text('Výpočet body mass index'),
              onTap: () {
                // Navigate to BMI tab
                widget.onNavigate(2);
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _clearData,
              icon: const Icon(Icons.delete),
              label: const Text('Smazat všechna data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
