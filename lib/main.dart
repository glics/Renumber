import 'package:flutter/material.dart';
import 'package:renumber/converter.dart';

void main() => runApp(Renumber());

class Renumber extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refind',
      home: Home(title: 'Refind'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key k, this.title}) : super(key: k);

  final String title;

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          primaryColor: Colors.deepPurple,
          // Only used by ListViews's overscroll tint
          accentColor: Colors.transparent),
      child: MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Renumber",
          style: TextStyle(color: Colors.black, fontFamily: "Raleway"),
        ),
      ),
      body: Container(
        foregroundDecoration: null,
        alignment: Alignment.topLeft,
        /* HexaRow is in a Stack inside the ConverterLayout,
           which also contains the ColorConverter in a ListView */
        child: ConverterLayout(),
      ),
    );
  }
}
