import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santa Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Santa Tracker'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Align(
          child: Padding(
            child: Material(
              child: SizedBox(
                  height: 48.0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Somewhere, OH",
                        style: Theme.of(context).textTheme.body2),
                  )),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.horizontal(
                      start: Radius.circular(24.0),
                      end: Radius.circular(24.0))),
            ),
            padding: EdgeInsets.only(bottom: 16.0),
          ),
          alignment: Alignment.bottomCenter,
        ));
  }
}
