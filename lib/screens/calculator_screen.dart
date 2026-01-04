import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _output = '0';
  String _input = '';
  double? _num1;
  String? _operator;
  bool _shouldResetInput = false;
  List<String> _history = [];

  final TextEditingController _customController1 = TextEditingController();
  final TextEditingController _customController2 = TextEditingController();
  String _customResult = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('calc_history') ?? [];
    });
  }

  Future<void> _saveToHistory(String calculation) async {
    final prefs = await SharedPreferences.getInstance();
    _history.insert(0, calculation);
    if (_history.length > 10) _history.removeLast();
    await prefs.setStringList('calc_history', _history);
    setState(() {});
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldResetInput) {
        _input = '';
        _shouldResetInput = false;
      }
      if (_input == '0') {
        _input = number;
      } else {
        _input += number;
      }
      _output = _input;
    });
  }

  void _onOperatorPressed(String operator) {
    if (_input.isNotEmpty) {
      setState(() {
        _num1 = double.tryParse(_input);
        _operator = operator;
        _shouldResetInput = true;
      });
    }
  }

  void _onEqualsPressed() {
    if (_num1 != null && _operator != null && _input.isNotEmpty) {
      final num2 = double.tryParse(_input);
      if (num2 != null) {
        double result;
        switch (_operator) {
          case '+':
            result = _num1! + num2;
            break;
          case '-':
            result = _num1! - num2;
            break;
          case '×':
            result = _num1! * num2;
            break;
          case '÷':
            result = num2 != 0 ? _num1! / num2 : double.infinity;
            break;
          default:
            return;
        }

        final calculation = '$_num1 $_operator $num2 = $result';
        _saveToHistory(calculation);

        setState(() {
          _output = result
              .toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);
          _input = _output;
          _num1 = null;
          _operator = null;
          _shouldResetInput = true;
        });
      }
    }
  }

  void _onClearPressed() {
    setState(() {
      _output = '0';
      _input = '';
      _num1 = null;
      _operator = null;
      _shouldResetInput = false;
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_shouldResetInput) {
        _input = '0';
        _shouldResetInput = false;
      }
      if (!_input.contains('.')) {
        _input += '.';
        _output = _input;
      }
    });
  }

  void _calculateCustom() {
    final num1 = double.tryParse(_customController1.text);
    final num2 = double.tryParse(_customController2.text);

    if (num1 != null && num2 != null) {
      setState(() {
        _customResult = 'Součet: ${num1 + num2}\n'
            'Rozdíl: ${num1 - num2}\n'
            'Součin: ${num1 * num2}\n'
            'Podíl: ${num2 != 0 ? (num1 / num2).toStringAsFixed(2) : 'Nemožné dělit nulou'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _output,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildOperatorButton('÷'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildOperatorButton('×'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildOperatorButton('-'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildOperatorButton('='),
                      _buildOperatorButton('+'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onClearPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('C'),
                    ),
                  ),
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
                    'Vlastní výpočet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController1,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Číslo 1',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _customController2,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Číslo 2',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _calculateCustom,
                    child: const Text('Vypočítat'),
                  ),
                  if (_customResult.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_customResult),
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
                  Text(
                    'Historie',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Text('Žádná historie')
                  else
                    ..._history.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(item),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (text == '=') {
            _onEqualsPressed();
          } else if (text == '.') {
            _onDecimalPressed();
          } else {
            _onNumberPressed(text);
          }
        },
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildOperatorButton(String operator) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (operator == '=') {
            _onEqualsPressed();
          } else {
            _onOperatorPressed(operator);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: Text(
          operator,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
