import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:barcodereader/interfaces.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
export 'package:camera/camera.dart' show ResolutionPreset;

import 'behavior_subject/behavior_subject.dart';
export 'formats.dart' show Format, format2String;
export 'interfaces.dart' show Barcode;

Uint8List concatenatePlanes(List<Plane> planes) {
  final allBytes = WriteBuffer();
  planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

typedef CloseAction = void Function(List<Barcode>? barcodes);

typedef BarcodereaderChild = Widget Function(VoidCallback tap);

class Barcodereader extends StatefulWidget {
  final CameraController controller;
  final CloseAction closeAction;
  Barcodereader(this.controller, this.closeAction, {Key? key})
      :
        // assert(controller.value != null),
        super(key: key);

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  static Widget widget({
    Key? key,
    Color closedColor = Colors.white,
    Color openColor = Colors.white,
    double closedElevation = 1.0,
    double openElevation = 4.0,
    ShapeBorder closedShape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0))),
    ShapeBorder openShape = const RoundedRectangleBorder(),
    required BarcodereaderChild closedBuilder,
    required CloseAction closeAction,
    // Widget loading,
    bool tappable = true,
    ResolutionPreset resolution = ResolutionPreset.medium,
    Duration transitionDuration = const Duration(milliseconds: 300),
    ContainerTransitionType transitionType = ContainerTransitionType.fade,
  }) {
    late CameraController controller;
    // String path = '';
    return OpenContainer<List<Barcode>>(
      closedBuilder: (context, action) {
        return closedBuilder(() async {
          controller = await _controller(resolution);
          // final p = await getTemporaryDirectory();
          // path = '${p.path}/barcode1.png';
          // for (final f in [File(path), File('${p.path}/barcode2.png')]) {
          //   try {
          //     await f.exists().then((v) => v ? f.delete() : null);
          //   } catch (err) {}
          // }
          action();
        });
      },
      openBuilder: (context, action) {
        // assert(controller?.value != null);
        return Barcodereader(
          controller,
          (baarcode) => action(returnValue: baarcode),
        );
      },
      useRootNavigator: false,
      closedColor: closedColor,
      closedElevation: closedElevation,
      onClosed: closeAction,
      closedShape: closedShape,
      key: key,
      openColor: openColor,
      openElevation: openElevation,
      openShape: openShape,
      tappable: tappable,
      transitionDuration: transitionDuration,
      transitionType: transitionType,
    );
  }

  static List<CameraDescription> _cameras = [];

  static Future<void> _initCams() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
    } catch (err) {
      print(err);
    }
  }

  static Future<CameraController> _controller(
      [ResolutionPreset resolution = ResolutionPreset.medium]) async {
    // onPressed(TapDownDetails tap) async {
    // defaultTargetPlatform == TargetPlatform.android
    //     ? ResolutionPreset.medium
    //     : ResolutionPreset.low;
    // CustomMultiImagepicker2
    await _initCams();
    final camearDes =
        _cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    // camearDes.
    final _controller = CameraController(
      camearDes,
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller.initialize();
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    await _controller.setFocusMode(FocusMode.locked);
    return _controller;
  }

  @override
  BarcodereaderState createState() {
    return BarcodereaderState();
  }
}

class BarcodereaderState extends State<Barcodereader> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool flash = false, hasFlash = false;
  static const _CHANNEL = const MethodChannel('com.ayoub.barcodereader');
  // static final mlBarcodeDetector = MLVision.GoogleMlKit.vision.barcodeScanner();

  @override
  void initState() {
    super.initState();
    widget.controller.startImageStream(_streamLisnner);
    // Screen.keepOn(true);
    Wakelock.enable();
    role();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    timer.cancel();
    align.close();
    _dispose();
    super.dispose();
  }

  void _dispose() async {
    try {
      await widget.controller.stopImageStream();
    } catch (err) {
      print(err);
    }
    await widget.controller.setFlashMode(FlashMode.off);
    await widget.controller.dispose();
    await Future.wait([
      // Screen.keepOn(false),
      Wakelock.disable(),
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values),
    ]);
  }

  // Widget _rotate({Widget child}) {
  //   final angle = widget.controller.description.sensorOrientation * pi / 180;
  //   return Transform.rotate(child: child, angle: angle);
  // }

  showSnackBar(String str) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(str),
      action: SnackBarAction(
        label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ));
  }

  _flash() async {
    widget.controller.setFlashMode(!flash ? FlashMode.torch : FlashMode.off);
    flash = !flash;
    setState(() {});
  }

  Future focuseFuture = Future.delayed(const Duration(milliseconds: 500));
  TapDownDetails focuseTap = TapDownDetails(globalPosition: Offset.zero);

  @override
  Widget build(BuildContext context) {
    final sizeo = MediaQuery.of(context).size;
    final widtho = sizeo.width;
    final heighto = sizeo.height;
    final mino = min(widtho, heighto);
    // final size = widget.controller.value.previewSize;
    final height = max(sizeo.width, sizeo.height);
    final width = min(sizeo.width, sizeo.height);
    return Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            // overflow: Overflow.clip,
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      height: height,
                      width: width,
                      child: CameraPreview(widget.controller),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: StreamBuilder(
                  stream: align,
                  initialData: align.value,
                  builder: (_, AsyncSnapshot<AlignmentGeometry> snap) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: mino * .9,
                      height: mino * .9 / 2,
                      alignment: snap.data,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Container(
                        color: Colors.red,
                        width: mino * .9,
                        height: 3,
                      ),
                    );
                  },
                ),
              ),
              FutureBuilder(
                future: focuseFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Positioned(
                      left: focuseTap.globalPosition.dx,
                      top: focuseTap.globalPosition.dy,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    );
                  }
                  return Text('');
                },
              ),

              GestureDetector(
                onTapDown: (details) {
                  final size = MediaQuery.of(context).size;
                  // print({
                  //   'width': MediaQuery.of(context).size.width,
                  //   'height': MediaQuery.of(context).size.height,
                  //   'globalPosition': details.globalPosition,
                  //   'x': details.globalPosition.dx,
                  // });
                  widget.controller.setFocusPoint(
                    Offset(
                      details.globalPosition.dx / size.width,
                      details.globalPosition.dy / size.height,
                    ),
                  );
                  setState(() {
                    focuseTap = details;
                    focuseFuture =
                        Future.delayed(const Duration(milliseconds: 500));
                  });
                },
              ),
              // IconButton(
              //   color: Colors.white,
              //   icon: Icon(Icons.camera),
              //   onPressed: isTacking ? null : _captureImage,
              // ),
              // IconButton(
              //   color: Colors.white,
              //   icon: Icon(Icons.switch_camera),
              //   onPressed: _swithcCam,

              // ),

              Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: IconButton(
                        color: Colors.white,
                        // icon: _rotate(
                        //   child: Icon(flash ? Icons.flash_on : Icons.flash_off),
                        // ),
                        icon: Icon(flash ? Icons.flash_on : Icons.flash_off),
                        onPressed: _flash),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          widget.closeAction(null);
                        }),
                  ),
                ),
              ),
            ],
          );
        }));
  }

  final align = BehaviorSubject<AlignmentGeometry>.seeded(Alignment.topCenter);

  late Timer timer;

  void role() {
    timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      if (align.value == Alignment.topCenter) {
        align.add(Alignment.bottomCenter);
      } else {
        align.add(Alignment.topCenter);
      }
    });
  }

  bool tacking = false;
  bool closed = false;

  void _streamLisnner(CameraImage image) async {
    if (tacking) return;
    tacking = true;
    if (!mounted) return;
    try {
      final barcodes = await _CHANNEL.invokeListMethod<Map>('barcode', {
        'width': image.width,
        'height': image.height,
        'bytes': image.planes.first.bytes,
        // 'bytes': concatenatePlanes(image.planes),
        // 'bytes': rotate(image.planes.first),
      }).then((value) {
        try {
          if (value == null) return null;
          return List.from(value).map((e) => Barcode.fromMap(e)).toList();
        } catch (err) {
          return null;
        }
      });
      if (barcodes?.isNotEmpty ?? false) {
        if (!closed) {
          widget.closeAction(barcodes);
          closed = true;
          widget.controller.stopImageStream();
        }
      }
    } catch (err) {
      print({'err': err});
    }
    await Future.delayed(const Duration(milliseconds: 500));
    tacking = false;
  }
}
