import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'muž';
  String _result = '';
  String _category = '';
  Color _categoryColor = Colors.black;
  List<Map<String, dynamic>> _bmiHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBMIHistory();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _heightController.text = prefs.getString('saved_height') ?? '';
      _weightController.text = prefs.getString('saved_weight') ?? '';
      _ageController.text = prefs.getString('saved_age') ?? '';
      _gender = prefs.getString('saved_gender') ?? 'muž';
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_height', _heightController.text);
    await prefs.setString('saved_weight', _weightController.text);
    await prefs.setString('saved_age', _ageController.text);
    await prefs.setString('saved_gender', _gender);
  }

  Future<void> _loadBMIHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getStringList('bmi_history') ?? [];
    setState(() {
      _bmiHistory = historyString.map((item) {
        final parts = item.split('|');
        return {
          'date': parts[0],
          'bmi': double.tryParse(parts[1]) ?? 0,
          'category': parts[2],
        };
      }).toList();
    });
  }

  Future<void> _saveToHistory(double bmi, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr = '${now.day}.${now.month}.${now.year}';
    final historyItem = '$dateStr|$bmi|$category';
    
    final historyString = prefs.getStringList('bmi_history') ?? [];
    historyString.insert(0, historyItem);
    if (historyString.length > 10) historyString.removeLast();
    
    await prefs.setStringList('bmi_history', historyString);
    _loadBMIHistory();
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);

    if (height == null || height <= 0 || weight == null || weight <= 0) {
      setState(() {
        _result = 'Prosím zadejte platné hodnoty!';
        _category = '';
      });
      return;
    }

    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    
    setState(() {
      _result = 'Vaše BMI: ${bmi.toStringAsFixed(2)}';
      
      if (bmi < 18.5) {
        _category = 'Podváha';
        _categoryColor = Colors.blue;
      } else if (bmi < 25) {
        _category = 'Normální hmotnost';
        _categoryColor = Colors.green;
      } else if (bmi < 30) {
        _category = 'Nadváha';
        _categoryColor = Colors.orange;
      } else {
        _category = 'Obezita';
        _categoryColor = Colors.red;
      }
    });

    _saveToHistory(bmi, _category);
    _saveData();
  }

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bmi_history');
    _loadBMIHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historie smazána!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
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
                    'Výpočet BMI',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Výška (cm)',
                      border: OutlineInputBorder(),
                      suffixText: 'cm',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Váha (kg)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Věk',
                      border: OutlineInputBorder(),
                      suffixText: 'let',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Pohlaví',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'muž', child: Text('Muž')),
                      DropdownMenuItem(value: 'žena', child: Text('Žena')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateBMI,
                      child: const Text('Vypočítat BMI'),
                    ),
                  ),
                  if (_result.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _result,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (_category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _category,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BMI kategorie',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: _clearHistory,
                        child: const Text('Smazat historii'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryRow('Podváha', '< 18.5', Colors.blue),
                  _buildCategoryRow('Normální', '18.5 - 24.9', Colors.green),
                  _buildCategoryRow('Nadváha', '25 - 29.9', Colors.orange),
                  _buildCategoryRow('Obezita', '≥ 30', Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historie měření',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_bmiHistory.isEmpty)
                    const Text('Žádná historie')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bmiHistory.length,
                      itemBuilder: (context, index) {
                        final item = _bmiHistory[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.history),
                          title: Text('${item['date']} - BMI: ${item['bmi'].toStringAsFixed(1)}'),
                          subtitle: Text(item['category']),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(category),
          ),
          Text(
            range,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
