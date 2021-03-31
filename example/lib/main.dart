import 'package:flutter/material.dart';
import 'package:barcodereader/barcodereader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Barcode barcode;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Barcodereader.widget(
                useMlVision: false,
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                closedBuilder: (open) {
                  return FlatButton(
                    height: 60,
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: open,
                    textColor: Colors.white,
                    child: Text('Open Scanner'),
                  );
                },
                closeAcinot: (barcode) {
                  setState(() {
                    this.barcode = barcode;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('$barcode'),
            ],
          ),
        ),
      ),
    );
  }
}
