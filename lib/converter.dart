import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renumber/color.dart';

class ConverterLayout extends StatefulWidget {
  @override
  ConverterLayoutState createState() {
    return new ConverterLayoutState();
  }
}

class ConverterLayoutState extends State<ConverterLayout> {
  final EdgeInsets insets =
      EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0);

  final TextEditingController hex = TextEditingController();
  final TextEditingController bin = TextEditingController();
  final TextEditingController dec = TextEditingController();

  @override
  void dispose() {
    // free up resources
    dec.dispose();
    hex.dispose();
    bin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListView layout, this will go inside the Stack, which also contains the HexaRow
    // We declare this separately so we can avoid rendering the ColorConverter at all when the keyboard is showm.
    var _lvList = <Widget>[
      // Top padding
      SizedBox(height: 25.0),

      // Decimal input box
      TextField(
        cursorRadius: Radius.circular(2.0),
        keyboardType: TextInputType.number,
        controller: dec,
        onChanged: (s) => convert(0, s),
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          labelText: "Decimal",
          contentPadding: insets,
        ),
        inputFormatters: [
          // maxLength adds a character counter under the textbox which i don't want
          // 9,223,372,036,854,775,807 (19 chars) = 2^63-1 = max 64 bit int val
          LengthLimitingTextInputFormatter(19),
          WhitelistingTextInputFormatter(RegExp("[0-9]"))
        ],
      ),

      // Second padding
      SizedBox(height: 24.0),

      // Hexadecimal input box
      TextField(
        cursorRadius: Radius.circular(2.0),
        controller: hex,
        onChanged: (s) => convert(1, s),
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          labelText: "Hexadecimal",
          contentPadding: insets,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(16),
          WhitelistingTextInputFormatter(RegExp("[0-9A-Fa-f]"))
        ],
      ),

      // Third padding
      SizedBox(height: 24.0),

      // Binary input box
      TextField(
        cursorRadius: Radius.circular(2.0),
        keyboardType: TextInputType.number,
        controller: bin,
        onChanged: (s) => convert(2, s),
        cursorColor: Theme.of(context).primaryColor,
        maxLines: 3,
        inputFormatters: [
          LengthLimitingTextInputFormatter(63),
          WhitelistingTextInputFormatter(RegExp("[01]"))
        ],
        decoration: InputDecoration(
          labelText: "Binary",
          contentPadding: insets,
        ),
      ),

      // Bottom padding
      SizedBox(height: 30.0),
      ColorConverter(),
    ];

    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: ListView(
        //Flutter UI bug: this makes the selection beginning caret impossible to drag.
        //Could be solved using a Poisitioned?
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: _lvList,
      ),
    );
  }

  void convert(int lastChange, String val) {
    /* lastChange passes the last edited textfield.
     * 0 = decimal
     * 1 = hex
     * 2 = binary (lol.)
     */

    if (val == "") {
      dec.text = "";
      hex.text = "";
      bin.text = "";
      return;
    }

    int convN;
    switch (lastChange) {
      case 0:
        convN = int.tryParse(val);
        if (convN == null) {
          //tryParse returns null when parsed source exceeds 64 bit int limit
          convN = 9223372036854775807;
          dec.text = convN.toString();
        }

        hex.text = convN.toRadixString(16).toUpperCase();
        bin.text = convN.toRadixString(2);
        break;
      case 1:
        convN = int.tryParse(val, radix: 16);
        if (convN == null) {
          convN = 9223372036854775807;
          hex.text = convN.toRadixString(16).toUpperCase();
        }
        dec.text = convN.toString();
        bin.text = convN.toRadixString(2);
        break;
      case 2:
        convN = int.tryParse(val, radix: 2);
        //No need for checks here, max possible input in bin's TextField is 63 ones which is max 64 bit int vlaue
        dec.text = convN.toString();
        hex.text = convN.toRadixString(16).toUpperCase();
        break;
      default:
        debugPrint("Boo! How did this happen?!");
        break;
    }
  }
}
