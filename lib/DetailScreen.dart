// ignore: file_names
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String selectedItem = '';

  late File pickedImage;
  // ignore: prefer_typing_uninitialized_variables
  var imageFile;

  var result = '';

  bool isImageLoaded = false;
  bool isFaceDetected = false;

  List<Rect> rect = [];

  getImageFromGallery() async {
    var tempStore = await ImagePicker().pickImage(source: ImageSource.gallery);

    imageFile = await tempStore!.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    setState(() {
      pickedImage = File(tempStore.path);
      isImageLoaded = true;
      isFaceDetected = false;

      imageFile = imageFile;
    });
  }

  readTextfromanImage() async {
    result = '';
    final inputImage = InputImage.fromFilePath(pickedImage.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final readText = await textRecognizer.processImage(inputImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            result = '$result ${word.text}';
          });
        }
      }
    }
  }

  decodeBarCode() async {
    result = '';
    final inputImage = InputImage.fromFilePath(pickedImage.path);
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
    final barCodes = await barcodeScanner.processImage(inputImage);

    for (Barcode readableCode in barCodes) {
      setState(() {
        result = readableCode.value!.toString();
      });
    }
  }

  Future labelsread() async {
    result = '';
    final inputImage = InputImage.fromFilePath(pickedImage.path);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final labels = await imageLabeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      setState(() {
        result = '$result $text     $confidence\n';
      });
    }
  }

  Future detectFace() async {
    result = '';
    final inputImage = InputImage.fromFilePath(pickedImage.path);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final faces = await faceDetector.processImage(inputImage);

    if (rect.isNotEmpty) {
      rect = <Rect>[];
    }

    for (Face face in faces) {
      rect.add(face.boundingBox);
    }

    setState(() {
      isFaceDetected = true;
    });
  }

  void detectMLFeature(String selectedFeature) {
    switch (selectedFeature) {
      case 'Text Scanner':
        readTextfromanImage();
        break;
      case 'Barcode Scanner':
        decodeBarCode();
        break;
      case 'Label Scanner':
        labelsread();
        break;
      case 'Face Detection':
        detectFace();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedItem = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedItem),
        actions: [
          ElevatedButton(
            onPressed: getImageFromGallery,
            child: const Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          isImageLoaded && !isFaceDetected
              ? Center(
                  child: Container(
                    height: 250.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage), fit: BoxFit.cover)),
                  ),
                )
              : isImageLoaded && isFaceDetected
                  ? Center(
                      child: FittedBox(
                        child: SizedBox(
                          width: imageFile.width.toDouble(),
                          height: imageFile.height.toDouble(),
                          child: CustomPaint(
                            painter:
                                FacePainter(rect: rect, imageFile: imageFile),
                          ),
                        ),
                      ),
                    )
                  : Container(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(result),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          detectMLFeature(selectedItem);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Rect> rect;
  // ignore: prefer_typing_uninitialized_variables
  var imageFile;

  FacePainter({required this.rect, required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    for (Rect rectange in rect) {
      canvas.drawRect(
        rectange,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
