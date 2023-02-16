import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_genertor/drawingArea.dart';
import 'package:human_genertor/splashscreen.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DrawingArea> points = [];
  Widget? imageOutput;

  void saveToImage(List<DrawingArea> points) async {
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(0.0, 0.0)));
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawRect(Rect.fromLTRB(0, 0, 256, 256), paint2);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);

    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final listBytes = Uint8List.view(pngBytes!.buffer);

    // File file = await writeBytes(listBytes);
    String base64 = base64Encode(listBytes);
    fetchResponce(base64);
  }

  void fetchResponce(var base64Image) async {
    var data = {"Image": base64Image};

    print("Starting erequest");

    var url = Uri.parse('http://172.19.64.1:5000/predict');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'Keep-Alive',
    };
    var body = json.encode(data);
    try {
      var responce = await http.post(url, body: body, headers: headers);

      final Map<String, dynamic> responceData = json.decode(responce.body);
      String outputBytes = responceData['Image'];
      print(outputBytes.substring(2, outputBytes.length - 1));
      displayResponseImage(outputBytes.substring(2, outputBytes.length - 1));
    } catch (e) {
      print(" * ERROR HAS OCCURED");
      return null;
    }
  }

  void displayResponseImage(String bytes) async {
    Uint8List convertedBytes = base64Decode(bytes);

    setState(() {
      imageOutput = Container(
        width: 256,
        height: 256,
        child: Image.memory(
          convertedBytes,
          fit: BoxFit.cover,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(118, 35, 135, 2),
                  Color.fromRGBO(215, 64, 87, 2),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 256,
                    height: 256,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            spreadRadius: 1),
                      ],
                    ),
                    child: GestureDetector(
                      onPanDown: (details) {
                        setState(() {
                          points.add(
                            DrawingArea(
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0,
                                point: details.localPosition),
                          );
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          points.add(
                            DrawingArea(
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0,
                                point: details.localPosition),
                          );
                        });
                      },
                      onPanEnd: (details) {
                        saveToImage(points);
                        // setState(
                        //   () {
                        //     points.add(null);
                        //   },
                        // );
                      },
                      child: SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          child: CustomPaint(
                            painter: MyCustomPainter(points: points),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.layers_clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            points.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    child: Center(
                      child: Container(
                        height: 256,
                        width: 256,
                        child: imageOutput,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
