// lib/pages/calculator.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorPage extends StatefulWidget {
  final void Function(double)? onUse;
  const CalculatorPage({super.key, this.onUse});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  bool _isNewNumber = true;
  double _fontSize = 48.0;

  @override
  void initState() {
    super.initState();
    // Mengatur status bar agar transparan dan teks menjadi putih
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_display == '0' || _isNewNumber) {
        _display = number == '.' ? '0.' : number;
        _isNewNumber = false;
      } else {
        if (number == '.' && _display.contains('.')) return;
        _display += number;
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (_operation.isNotEmpty && !_isNewNumber) {
        _calculate();
      }
      _firstNumber = double.tryParse(_display) ?? 0;
      _operation = operation;
      _isNewNumber = true;
    });
  }

  void _calculate() {
    if (_operation.isEmpty || _isNewNumber) return;

    double secondNumber = double.tryParse(_display) ?? 0;
    double result = 0;
    try {
      switch (_operation) {
        case '+':
          result = _firstNumber + secondNumber;
          break;
        case '-':
          result = _firstNumber - secondNumber;
          break;
        case '×':
          result = _firstNumber * secondNumber;
          break;
        case '÷':
          if (secondNumber == 0) throw Exception('Division by zero');
          result = _firstNumber / secondNumber;
          break;
      }
      setState(() {
        _display = _formatNumber(result);
        _operation = '';
        _firstNumber = result;
        _isNewNumber = true;
      });
    } catch (e) {
      setState(() {
        _display = 'Error';
        _isNewNumber = true;
        _operation = '';
      });
    }
  }

  String _formatNumber(double number) {
    if (number == number.toInt().toDouble()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  void _clear() {
    setState(() {
      _display = '0';
      _operation = '';
      _firstNumber = 0;
      _isNewNumber = true;
    });
  }

  void _deleteLastDigit() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _isNewNumber = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Opsi 1: Menggunakan extendBodyBehindAppBar dan extendBody
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: const Color(0xFF3AD0A2), // Set background color
      body: Column(
        children: [
          // Display Area - Expanded untuk mengisi ruang yang tersedia
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: const Color(0xFF3AD0A2),
              // Menggunakan SafeArea untuk menghindari notch/status bar
              child: SafeArea(
                bottom: false, // Tidak perlu safe area di bottom
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _operation.isNotEmpty
                            ? '${_formatNumber(_firstNumber)} $_operation'
                            : '',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _display,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _fontSize,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Button Grid Area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(child: Row(children: [
                      _buildButton('C', color: Colors.orange, onPressed: _clear),
                      _buildButton('⌫', color: Colors.orange, onPressed: _deleteLastDigit),
                      _buildButton('=', color: const Color(0xFF3AD0A2), onPressed: _calculate),
                      _buildButton('÷', color: const Color(0xFF3AD0A2), onPressed: () => _onOperationPressed('÷')),
                    ])),
                    Expanded(child: Row(children: [
                      _buildButton('7', onPressed: () => _onNumberPressed('7')),
                      _buildButton('8', onPressed: () => _onNumberPressed('8')),
                      _buildButton('9', onPressed: () => _onNumberPressed('9')),
                      _buildButton('×', color: const Color(0xFF3AD0A2), onPressed: () => _onOperationPressed('×')),
                    ])),
                    Expanded(child: Row(children: [
                      _buildButton('4', onPressed: () => _onNumberPressed('4')),
                      _buildButton('5', onPressed: () => _onNumberPressed('5')),
                      _buildButton('6', onPressed: () => _onNumberPressed('6')),
                      _buildButton('-', color: const Color(0xFF3AD0A2), onPressed: () => _onOperationPressed('-')),
                    ])),
                    Expanded(child: Row(children: [
                      _buildButton('1', onPressed: () => _onNumberPressed('1')),
                      _buildButton('2', onPressed: () => _onNumberPressed('2')),
                      _buildButton('3', onPressed: () => _onNumberPressed('3')),
                      _buildButton('+', color: const Color(0xFF3AD0A2), onPressed: () => _onOperationPressed('+')),
                    ])),
                    Expanded(child: Row(children: [
                      _buildButton('0', onPressed: () => _onNumberPressed('0')),
                      _buildButton('.', onPressed: () => _onNumberPressed('.')),
                      _buildButton('±', color: Colors.orange, onPressed: () {
                        setState(() {
                          if (_display.startsWith('-')) {
                            _display = _display.substring(1);
                          } else {
                            _display = '-$_display';
                          }
                        });
                      }),
                      _buildButton('%', color: Colors.orange, onPressed: () {
                        double number = double.tryParse(_display) ?? 0;
                        setState(() {
                          _display = _formatNumber(number / 100);
                          _isNewNumber = true;
                        });
                      }),
                    ])),
                  ],
                ),
              ),
            ),
          ),

          // Use Button
          if (widget.onUse != null)
            Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final value = double.tryParse(_display) ?? 0.0;
                      widget.onUse!(value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3AD0A2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'Gunakan',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(String text,
      {Color? color, Color? textColor, VoidCallback? onPressed}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey.shade300,
            foregroundColor: textColor ?? Colors.black87,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(text,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}