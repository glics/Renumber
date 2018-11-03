import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorConverter extends StatefulWidget {
  @override
  _ColorConverterState createState() => _ColorConverterState();
}

class _ColorConverterState extends State<ColorConverter> {
  final hController = TextEditingController(text: "#FFFFFF");
  final rController = TextEditingController(text: "255");
  final gController = TextEditingController(text: "255");
  final bController = TextEditingController(text: "255");

  Color currentColor = Colors.white;
  Color ccRed = Color(0xFFFF0000);
  Color ccGreen = Color(0xFF00FF00);
  Color ccBlue = Color(0xFF0000FF);

  @override
  void dispose() {
    hController.dispose();
    rController.dispose();
    gController.dispose();
    bController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title
          Text(
            "Color Tool",
            textScaleFactor: 2.0,
          ),

          // Padding after title
          SizedBox(height: 26.0),

          // Row with two elements: The column on the left and a preview square on the right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Textboxes container
              SizedBox(
                width: 125.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Hex color input
                    Theme(
                      data: ThemeData(
                          primaryColor: currentColor != Colors.transparent &&
                                  currentColor.computeLuminance() < 0.5
                              ? currentColor
                              : Theme.of(context).primaryColor,
                          splashColor: Colors.transparent),
                      child: TextField(
                        controller: hController,
                        cursorColor: currentColor != Colors.transparent &&
                                  currentColor.computeLuminance() < 0.5
                              ? currentColor
                              : Theme.of(context).primaryColor,
                        cursorRadius: Radius.circular(2.0),
                        decoration: InputDecoration(
                          labelText: "Hexadecimal",
                        ),
                        onChanged: convertColorHex,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(7),
                          WhitelistingTextInputFormatter(
                              //Regex explaination: Accept "#" as first character, then A-F, a-f and 0-9
                              RegExp("^#|[A-F0-9]", caseSensitive: false)),
                        ],
                      ),
                    ),
                    // Padding under hex input
                    SizedBox(height: 13.0),
                    // RGB inputs label
                    Text.rich(
                      TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: "Red", style: TextStyle(color: Colors.red)),
                        TextSpan(text: " / "),
                        TextSpan(
                            text: "Green",
                            style: TextStyle(color: Colors.greenAccent[700])),
                        TextSpan(text: " / "),
                        TextSpan(
                            text: "Blue",
                            style: TextStyle(color: Colors.blueAccent[700])),
                      ]),
                      textScaleFactor: 0.9,
                    ),
                    // Container for R/G/B input boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // This is going to look like a giant mess, anyway:
                        // Red text box (inside a Theme for coloring the underline, and a SizedBox)
                        SizedBox(
                          width: 30.0,
                          child: Theme(
                            data: ThemeData(
                                primaryColor: ccRed,
                                splashColor: Colors.transparent),
                            child: TextField(
                              controller: rController,
                              onChanged: (val) => convertColorRGB(0, val),
                              cursorColor: Colors.red,
                              cursorRadius: Radius.circular(2.0),
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[0-9]")),
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ),
                        // Green text box
                        SizedBox(
                          width: 30.0,
                          child: Theme(
                            data: ThemeData(
                                primaryColor: ccGreen,
                                splashColor: Colors.transparent),
                            child: TextField(
                              controller: gController,
                              onChanged: (val) => convertColorRGB(1, val),
                              cursorColor: Colors.greenAccent[400],
                              cursorRadius: Radius.circular(2.0),
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[0-9]")),
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ),
                        // Blue text box
                        SizedBox(
                          width: 30.0,
                          child: Theme(
                            data: ThemeData(
                                primaryColor: ccBlue,
                                splashColor: Colors.transparent),
                            child: TextField(
                              controller: bController,
                              onChanged: (val) => convertColorRGB(2, val),
                              cursorColor: Colors.blueAccent[700],
                              cursorRadius: Radius.circular(2.0),
                              inputFormatters: [
                                WhitelistingTextInputFormatter(RegExp("[0-9]")),
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 130.0,
                height: 130.0,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                  color: currentColor,
                )),
              ),
            ],
          ),
          SizedBox(
            height: 30.0,
          )
        ]);
  }

  void convertColorHex(String value) {
    switch (value.length) {
      case 0:
        hController.text = "#";
        hController.selection = TextSelection.collapsed(offset: 1);
        setState(() => currentColor = Colors.transparent);
        return;
      case 7:
        break;
      default:
        if (hController.text.substring(0, 1) != "#")
          hController.text = "#" + hController.text;
        setState(() => currentColor = Colors.transparent);
        return;
    }

    //col is a 24-bit integer, it has no Alpha channel
    int nCol = int.tryParse(value.substring(1, 7), radix: 16);
    //Color(int) takes a 32-bit int, divided in 8-bit groups of Alpha-Red-Green-Blue
    Color _color = Color(0xFF000000 + nCol);

    ccRed = Color.fromARGB(_color.red, 255, 0, 0);
    ccGreen = Color.fromARGB(_color.green, 0, 255, 0);
    ccBlue = Color.fromARGB(_color.blue, 0, 0, 255);

    rController.text = _color.red.toString();
    gController.text = _color.green.toString();
    bController.text = _color.blue.toString();

    setState(() => currentColor = _color);
  }

  convertColorRGB(int primaryColor, String value) {
    int _ccRed = 0, _ccGreen = 0, _ccBlue = 0;
    switch (primaryColor) {
      case 0:
        // Red field changed
        if (int.parse(value) > 255) rController.text = "255";
        break;
      case 1:
        // Green field changed
        if (int.parse(value) > 255) gController.text = "255";
        break;
      case 2:
        // Blue field changed
        if (int.parse(value) > 255) bController.text = "255";
        break;
      default:
        debugPrint("This just can't be happening.");
        break;
    }

    _ccRed = int.parse(rController.text);
    ccRed = Color.fromARGB(_ccRed, 255, 0, 0);

    _ccGreen = int.parse(gController.text);
    ccGreen = Color.fromARGB(_ccGreen, 0, 255, 0);

    _ccBlue = int.parse(bController.text);
    ccBlue = Color.fromARGB(_ccBlue, 0, 0, 255);

    setState(() {
      currentColor = Color.fromARGB(255, _ccRed, _ccGreen, _ccBlue);
      hController.text = "#" +
          currentColor.value
              .toRadixString(16)
              .substring(2)
              .padLeft(6, "0")
              .toUpperCase();
    });
  }
}
