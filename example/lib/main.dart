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
  List<Barcode> barcodes;
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
                resolution: ResolutionPreset.high,
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                closedBuilder: (open) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(color: Colors.white),
                      onSurface: Theme.of(context).primaryColor,
                      minimumSize: Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: open,
                    child: Text('Open Scanner Kotlin'),
                  );
                },
                closeAction: (barcode) {
                  setState(() {
                    this.barcodes = barcode;
                  });
                },
              ),
              SizedBox(height: 20),
              for (final barcode in barcodes ?? <Barcode>[])
                Text('${barcode.map}'),
            ],
          ),
        ),
      ),
    );
  }
}
