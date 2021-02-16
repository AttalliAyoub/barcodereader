import 'dart:async';
// import 'dart:async';
// import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'interfaces.dart';
// import 'package:hanoti/services/pushNotification.dart';
// import 'package:hanoti/services/resp.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screen/screen.dart';

export 'package:camera/camera.dart' show ResolutionPreset;
export 'interfaces.dart';

// class Barcodereader {
//   static const MethodChannel _channel = const MethodChannel('barcodereader');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }

typedef CloseAcinot = void Function(Barcode barcode);

typedef BarcodereaderChild = Widget Function(Function tap);

class Barcodereader extends StatefulWidget {
  final CameraController controller;
  final CloseAcinot closeAcinot;
  Barcodereader(this.controller, this.closeAcinot, {Key key})
      : assert(controller?.value != null),
        super(key: key);

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  static Widget widget({
    Key key,
    Color closedColor = Colors.white,
    Color openColor = Colors.white,
    double closedElevation = 1.0,
    double openElevation = 4.0,
    ShapeBorder closedShape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0))),
    ShapeBorder openShape = const RoundedRectangleBorder(),
    @required BarcodereaderChild closedBuilder,
    @required CloseAcinot closeAcinot,
    // Widget loading,
    bool tappable = true,
    ResolutionPreset resolution = ResolutionPreset.medium,
    Duration transitionDuration = const Duration(milliseconds: 300),
    ContainerTransitionType transitionType = ContainerTransitionType.fade,
  }) {
    CameraController controller;
    // String path = '';
    return OpenContainer<Barcode>(
      closedBuilder: (context, action) {
        controller?.dispose();
        controller = null;
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
        assert(controller?.value != null);
        return Barcodereader(
          controller,
          // path,
          (baarcode) => action(returnValue: baarcode),
        );
      },
      useRootNavigator: false,
      closedColor: closedColor,
      closedElevation: closedElevation,
      onClosed: closeAcinot,
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
      if (_cameras == null || (_cameras?.isEmpty ?? true))
        _cameras = await availableCameras();
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
    final _controller = CameraController(
      camearDes,
      resolution,
      enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.
      // autoFocusMode: AutoFocusMode.auto,
      // flashMode: FlashMode.off,
    );
    await _controller.initialize();
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

  num angle = 0.0;
  StreamSubscription<NativeDeviceOrientation> sub;

  // BarcodereaderState() {
  //   path = widget.path;
  // }

  @override
  void initState() {
    super.initState();
    Screen.keepOn(true);
    role();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    sub = NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen(listenToOrontation);
  }

  void listenToOrontation(NativeDeviceOrientation data) {
    switch (data) {
      case NativeDeviceOrientation.landscapeLeft:
        angle = pi / 2;
        break;
      case NativeDeviceOrientation.landscapeRight:
        angle = -pi / 2;
        break;
      case NativeDeviceOrientation.portraitUp:
        angle = 0.0;
        break;
      case NativeDeviceOrientation.portraitDown:
        angle = pi;
        break;
      default:
        angle = 0;
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    // final f1 = File(path);
    // final n = path.contains('barcode1');
    // path = path.replaceAll('barcode${n ? 1 : 2}', 'barcode${n ? 2 : 1}');
    // final f2 = File(path);
    // [f1, f2].forEach((f) {
    //   try {
    //     f.exists().then((v) => v ? f.delete() : null);
    //   } catch (err) {}
    // });

    sub?.cancel();
    timer?.cancel();
    _dispose();
    super.dispose();
  }

  void _dispose() async {
    await widget.controller.dispose();
    await Future.wait([
      Screen.keepOn(false),
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values),
    ]);
  }

  // void _initCameras() async {
  //   // hasFlash = await widget.controller.hasFlash;
  //   // flash = widget.controller.flashMode != FlashMode.off;
  //   flash = false;
  //   // widget.controller.setFlashMode(!flash ? FlashMode.torch : FlashMode.off);
  //   setState(() {});
  // }

  Widget _rotate({Widget child}) {
    return Transform.rotate(child: child, angle: angle);
  }

  showSnackBar(String str) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(str),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
      ),
    ));
  }

  _flash() async {
    // final status = await widget.controller.hasFlash;
    // if (status)
    //   widget.controller
    //       .setFlash(mode: !flash ? FlashMode.torch : FlashMode.off);
    // flash = !flash;
    widget.controller.setFlashMode(!flash ? FlashMode.torch : FlashMode.off);
    flash = !flash;
    setState(() {});
  }

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
            overflow: Overflow.clip,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: height,
                      width: width,
                      child: CameraPreview(widget.controller),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: IconButton(
                        color: Colors.white,
                        icon: _rotate(
                          child: Icon(flash ? Icons.flash_on : Icons.flash_off),
                        ),
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
                          widget.closeAcinot(null);
                        }),
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
            ],
          );
        }));
  }

  final BehaviorSubject<AlignmentGeometry> align =
      BehaviorSubject<AlignmentGeometry>.seeded(Alignment.topCenter);

  Timer timer;

  void role() {
    timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      // _captureImage();
      if (align.value == Alignment.topCenter) {
        align.add(Alignment.bottomCenter);
      } else {
        align.add(Alignment.topCenter);
      }
      if (!tacking && widget.controller.value.isInitialized && mounted)
        camearStream();
    });
  }

  // String path;
  bool tacking = false;

  void camearStream() async {
    tacking = true;
    // try {
    //   final f = File(path);
    //   f.exists().then((v) => v ? f.delete() : null);
    // } catch (err) {}
    // final n = path.contains('barcode1');
    // path = path.replaceAll('barcode${n ? 1 : 2}', 'barcode${n ? 2 : 1}');
    if (!mounted) return;
    final file = await widget.controller.takePicture();
    try {
      final data = await _CHANNEL
          .invokeMapMethod<String, dynamic>('barcode', {'path': file.path});
      if (data != null) {
        final barcode = Barcode(data);
        widget.closeAcinot(barcode);
      }
    } catch (err) {
      print({'err': err});
    }
    tacking = false;
  }

  // treatBarcode(Barcode barcode) {
  //   final Rect boundingBox = barcode.boundingBox;
  //   final List<Offset> cornerPoints = barcode.cornerPoints;
  //   final String rawValue = barcode.rawValue;
  //   final BarcodeValueType valueType = barcode.valueType;
  //   // See API reference for complete list of supported types
  //   switch (valueType) {
  //     case BarcodeValueType.wifi:
  //       final String ssid = barcode.wifi.ssid;
  //       final String password = barcode.wifi.password;
  //       final BarcodeWiFiEncryptionType type = barcode.wifi.encryptionType;
  //       break;
  //     case BarcodeValueType.url:
  //       final String title = barcode.url.title;
  //       final String url = barcode.url.url;
  //       break;
  //     case BarcodeValueType.unknown:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.contactInfo:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.email:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.isbn:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.phone:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.product:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.sms:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.text:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.geographicCoordinates:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.calendarEvent:
  //       // TODO: Handle this case.
  //       break;
  //     case BarcodeValueType.driverLicense:
  //       // TODO: Handle this case.
  //       break;
  //   }
  // }

}
