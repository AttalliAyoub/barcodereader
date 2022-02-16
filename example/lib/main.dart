import 'package:flutter/material.dart';
import 'package:barcodereader/barcodereader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Barcode>? barcodes;

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
                      textStyle: const TextStyle(color: Colors.white),
                      onSurface: Theme.of(context).primaryColor,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: open,
                    child: const Text('Open Scanner Kotlin'),
                  );
                },
                closeAction: (barcode) {
                  setState(() {
                    barcodes = barcode;
                  });
                },
              ),
              const SizedBox(height: 20),
              for (final barcode in barcodes ?? <Barcode>[])
                Text('${barcode.map}'),
            ],
          ),
        ),
      ),
    );
  }
}
