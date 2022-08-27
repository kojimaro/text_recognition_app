import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ML Kitで文字認識'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (textScanning) const CircularProgressIndicator(),
            if (!textScanning && imageFile == null)
              Container(
                width: 300,
                height: 300,
                color: Colors.grey,
              ),
            if (imageFile != null) Image.file(File(imageFile!.path)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        // Foreground color
                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                        // Background color
                        primary: Theme.of(context).colorScheme.primary,
                      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('ギャラリー'),
                    )),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        // Foreground color
                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                        // Background color
                        primary: Theme.of(context).colorScheme.primary,
                      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                      onPressed: () {
                        getImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('カメラ'),
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              scannedText,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ))),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);

    RecognizedText recognisedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}
