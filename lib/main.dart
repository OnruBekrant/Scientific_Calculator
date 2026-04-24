import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const ScientificCalculatorApp());
}

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '0';
  String _result = '';
  bool _evaluated = false;
  final List<Map<String, String>> _history = [];

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _history.clear();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          // Show newest first
                          final item = _history[_history.length - 1 - index];
                          return ListTile(
                            title: Text(item['expression']!, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                            subtitle: Text('=${item['result']!}', style: const TextStyle(color: Colors.greenAccent, fontSize: 22)),
                            onTap: () {
                              setState(() {
                                _input = item['expression']!;
                                _result = item['result']!;
                                _evaluated = true;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _input = '0';
        _result = '';
        _evaluated = false;
        return;
      }

      if (buttonText == '⌫') {
        if (_evaluated) {
          _input = '0';
          _result = '';
          _evaluated = false;
        } else {
          if (_input.length > 1) {
            _input = _input.substring(0, _input.length - 1);
          } else {
            _input = '0';
          }
        }
        return;
      }

      if (buttonText == '=') {
        _evaluate();
        return;
      }

      if (_evaluated) {
        if (['÷', '×', '-', '+', '^'].contains(buttonText)) {
          _input = _result + buttonText;
          _result = '';
        } else {
          _input = buttonText;
          _result = '';
        }
        _evaluated = false;
      } else {
        if (_input == '0') {
          if (['÷', '×', '-', '+', '^', '.'].contains(buttonText)) {
            _input += buttonText;
          } else {
            _input = buttonText;
          }
        } else {
          _input += buttonText;
        }
      }
    });
  }

  void _evaluate() {
    String expression = _input;
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');
    expression = expression.replaceAll('log(', 'log(10,');

    // Balance parentheses
    int openCount = 0;
    int closeCount = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') openCount++;
      if (expression[i] == ')') closeCount++;
    }
    expression += ')' * (openCount - closeCount);

    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      num evalNum = RealEvaluator(cm).evaluate(exp);
      double eval = evalNum.toDouble();

      setState(() {
        // Format to remove trailing .0 if present
        if (eval == eval.toInt()) {
          _result = eval.toInt().toString();
        } else {
          _result = eval.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        _history.add({'expression': _input, 'result': _result});
        _input = _result;
        _evaluated = true;
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
        _evaluated = true;
      });
    }
  }

  Widget _buildButton(String text, Color color, {int flex = 1, bool isIcon = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _onButtonPressed(text),
          child: isIcon && text == '⌫'
              ? const Icon(Icons.backspace_outlined, size: 24.0)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color funcColor = Color(0xFF6B8797);
    const Color numColor = Color(0xFF333333);
    const Color opColor = Color(0xFFF99D2A);
    const Color redColor = Color(0xFFFC565A);
    const Color greenColor = Color(0xFF5AB65B);

    Widget displayArea = Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Scientific Calculator',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white70),
                onPressed: _showHistory,
              ),
            ],
          ),
          const Spacer(),
          Container(
            alignment: Alignment.bottomRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _input,
                style: const TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (_result.isNotEmpty && _result != _input)
            Container(
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 30.0,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget keypadArea = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('sin(', funcColor),
                _buildButton('cos(', funcColor),
                _buildButton('tan(', funcColor),
                _buildButton('log(', funcColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('sqrt(', funcColor),
                _buildButton('^', funcColor),
                _buildButton('(', funcColor),
                _buildButton(')', funcColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('7', numColor),
                _buildButton('8', numColor),
                _buildButton('9', numColor),
                _buildButton('÷', opColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('4', numColor),
                _buildButton('5', numColor),
                _buildButton('6', numColor),
                _buildButton('×', opColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('1', numColor),
                _buildButton('2', numColor),
                _buildButton('3', numColor),
                _buildButton('-', opColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('0', numColor),
                _buildButton('.', numColor),
                _buildButton('⌫', redColor, isIcon: true),
                _buildButton('+', opColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('C', redColor, flex: 2),
                _buildButton('=', greenColor, flex: 2),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                children: [
                  Expanded(flex: 3, child: displayArea),
                  Expanded(flex: 4, child: keypadArea),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(flex: 2, child: displayArea),
                  Expanded(flex: 5, child: keypadArea),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
