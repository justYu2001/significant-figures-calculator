import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(Calculator());
}

class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '有效數字計算機',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SimpleCalculator(),
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  String equation = "0";
  String result = "0";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  bool clear = false;

  bool isOperator(String symbol) {
    for (int i = 0; i < 10; i++) {
      if (i.toString() == symbol) return false;
    }
    if (symbol == ".") return false;
    return true;
  }

  bool isTri(String symbol) {
    var name = ["sin", "cos", "tan", "cot", "sec", "csc"];
    if (name.indexOf(symbol) >= 0) return true;
    return false;
  }

  bool isDigit(String s) {
    return s == "0" ||
        s == "1" ||
        s == "2" ||
        s == "3" ||
        s == "4" ||
        s == "5" ||
        s == "6" ||
        s == "7" ||
        s == "8" ||
        s == "9";
  }

  int getPriority(String opr) {
    if (isTri(opr)) {
      return 3;
    } else if (opr == "*" || opr == "/" || opr == "×" || opr == "÷") {
      return 2;
    } else if (opr == "+" || opr == "-") {
      return 1;
    } else {
      return 0;
    }
  }

  int getAPL(String number) {
    if (number.contains(".")) {
      return number.length - number.indexOf(".") - 1;
    }
    return 0;
  }

  double cot(num radians) {
    return 1 / tan(radians);
  }

  double sec(num radians) {
    return 1 / cos(radians);
  }

  double csc(num radians) {
    return 1 / sin(radians);
  }

  double toRad(num deg) {
    return (deg * pi) / 180.0;
  }

  int getSFL(String number) {
    if (number.contains('.')) {
      if (number[0] == "0") {
        for (int i = 2; i < number.length; i++) {
          if (number[i] != "0") {
            return number.length - i;
          }
        }
      } else {
        return number.length - 1;
      }
    }
    int _num = int.parse(number);
    while (_num % 10 == 0) _num ~/= 10;
    return _num.toString().length;
  }

  String toStringRound(double number, int dights) {
    String numstr = number.toString();
    print("numstr:" + numstr);
    if (dights == 0) return number.round().toString();
    int pointPos = numstr.indexOf(".") + dights;
    while (pointPos >= numstr.length) {
      numstr += "0";
    }
    if (pointPos + 1 == numstr.length) return numstr;
    int num1 = int.parse(numstr[pointPos]);
    int num2 = int.parse(numstr[pointPos + 1]);
    if (num2 >= 5) {
      numstr = numstr.substring(0, pointPos) + (num1 + 1).toString();
    } else {
      numstr = numstr.substring(0, pointPos + 1);
    }
    return numstr;
  }

  String cal(String num1, String num2, String opr) {
    int afterPointLen = min(getAPL(num1), getAPL(num2));
    int significantNumber = min(getSFL(num1), getSFL(num2));
    double _num1 = double.parse(num1);
    double _num2 = double.parse(num2);
    print(afterPointLen);
    print(significantNumber);
    switch (opr) {
      case "+":
        double sum = _num1 + _num2;
        print(sum);
        return toStringRound(sum, afterPointLen);
        break;
      case "-":
        double difference = _num1 - _num2;
        print("difference:" + difference.toString());
        return toStringRound(difference, afterPointLen);
        break;
      case "*":
        double product = _num1 * _num2;
        return product.toStringAsPrecision(significantNumber);
        break;
      case "/":
        double quotient = _num1 / _num2;
        print(quotient);
        return quotient.toStringAsPrecision(significantNumber);
        break;
      default:
        return "";
    }
  }

  buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        equation = "0";
        result = "0";
        equationFontSize = 38.0;
        resultFontSize = 48.0;
        clear = false;
      } else if (buttonText == "⌫") {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == "." || getPriority(buttonText) > 0) {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        int last = equation.length - 1;
        String lastChr = equation[last];
        if (isTri(buttonText) && isDigit(lastChr)) {
          var numstr = "";
          while (isDigit(equation[last]) || equation[last] == ".") {
            numstr = equation[last] + numstr;
            last--;
            if (last < 0) {
              break;
            }
          }
          equation = equation.substring(0, last + 1) + buttonText + numstr;
        } else if ((getPriority(lastChr) > 0 || lastChr == ".") &&
            !isTri(buttonText)) {
          equation = equation.substring(0, last) + buttonText;
        } else if (!isTri(buttonText)) {
          equation += buttonText;
        }
      } else if (buttonText == "=") {
        equationFontSize = 38.0;
        resultFontSize = 48.0;

        try {
          String num = "";
          String opr;
          var stk = [];
          var postfix = [];
          var expression = [];
          var numstk = [];
          clear = true;
          print(equation);
          for (int i = 0; i < equation.length; i++) {
            var topr = "";
            if (equation.length - i > 3) topr = equation.substring(i, i + 3);
            if (isOperator(equation[i]) && !isTri(topr)) {
              expression.add(num);
              opr = equation[i];
              if (opr == "×") opr = "*";
              if (opr == "÷") opr = "/";
              expression.add(opr);
              num = "";
            } else if (isTri(topr)) {
              i += 3;
              var numstr = "";
              while (i < equation.length && isDigit(equation[i])) {
                numstr += equation[i++];
              }
              var rad = toRad(double.parse(numstr));
              print(rad);
              i--;
              if (topr == "sin") {
                num += sin(rad).toString();
              } else if (topr == "cos") {
                num += cos(rad).toString();
              } else if (topr == "tan") {
                num += tan(rad).toString();
              } else if (topr == "cot") {
                num += cot(rad).toString();
              } else if (topr == "sec") {
                num += sec(rad).toString();
              } else if (topr == "csc") {
                num += csc(rad).toString();
              }
            } else
              num += equation[i];
          }
          expression.add(num);
          print(expression);
          for (int i = 0; i < expression.length; i++) {
            if (getPriority(expression[i]) == 0) {
              postfix.add(expression[i]);
            } else if (stk.length > 0 &&
                getPriority(expression[i]) <= getPriority(stk.last)) {
              postfix.add(stk.last);
              stk.removeLast();
              stk.add(expression[i]);
            } else {
              stk.add(expression[i]);
            }
          }
          while (stk.isNotEmpty) {
            postfix.add(stk.last);
            stk.removeLast();
          }
          for (int i = 0; i < postfix.length; i++) {
            if (getPriority(postfix[i]) != 0) {
              var num1 = numstk.removeLast();
              var num2 = numstk.removeLast();
              numstk.add(cal(num2, num1, postfix[i]));
            } else {
              numstk.add(postfix[i]);
            }
          }
          result = numstk.last;
        } catch (e) {
          print(e);
          result = "Error";
        }
      } else {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
        } else if (clear) {
          clear = false;
          equation = buttonText;
          result = "0";
        } else {
          print(equation + "2");
          equation = equation + buttonText;
        }
      }
    });
  }

  Widget buildButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
                side: BorderSide(
                    color: Colors.white, width: 1, style: BorderStyle.solid)),
            padding: EdgeInsets.all(16.0),
          ),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('有效數字計算機')),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Text(
              equation,
              style: TextStyle(fontSize: equationFontSize),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Text(
              result,
              style: TextStyle(fontSize: resultFontSize),
            ),
          ),
          Expanded(
            child: Divider(),
          ),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("sin", 0.75, Colors.blue),
                      buildButton("cos", 0.75, Colors.blue),
                      buildButton("tan", 0.75, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("cot", 0.75, Colors.blue),
                      buildButton("sec", 0.75, Colors.blue),
                      buildButton("csc", 0.75, Colors.blue),
                    ]),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("C", 0.75, Colors.redAccent),
                      buildButton("⌫", 0.75, Colors.blue),
                      buildButton("÷", 0.75, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("7", 0.75, Colors.black54),
                      buildButton("8", 0.75, Colors.black54),
                      buildButton("9", 0.75, Colors.black54),
                    ]),
                    TableRow(children: [
                      buildButton("4", 0.75, Colors.black54),
                      buildButton("5", 0.75, Colors.black54),
                      buildButton("6", 0.75, Colors.black54),
                    ]),
                    TableRow(children: [
                      buildButton("1", 0.75, Colors.black54),
                      buildButton("2", 0.75, Colors.black54),
                      buildButton("3", 0.75, Colors.black54),
                    ]),
                    TableRow(children: [
                      buildButton(".", 0.75, Colors.black54),
                      buildButton("0", 0.75, Colors.black54),
                      buildButton("00", 0.75, Colors.black54),
                    ]),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("×", 0.75, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("-", 0.75, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("+", 0.75, Colors.blue),
                    ]),
                    TableRow(children: [
                      buildButton("=", 1.5, Colors.redAccent),
                    ]),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
