import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ReceiptScanner extends StatefulWidget {
  const ReceiptScanner({Key? key}) : super(key: key);

  @override
  _ReceiptScannerState createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner> {
  CameraController? _controller;
  bool _isDetecting = false;
  List<dynamic>? _recognitions;
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() {});
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }

  // Run the model inference on a captured image
  Future<void> _scanReceipt() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isDetecting = true);
    final image = await _controller!.takePicture();

    // Convert the image to a format suitable for the model
    // You may need to preprocess the image depending on your model's input requirements.
    var input = await _processImage(image); // Placeholder function for image preprocessing

    var output = List.filled(1, 0);  // Adjust output size based on your model
    _interpreter?.run(input, output);

    setState(() {
      _recognitions = output;
      _isDetecting = false;
    });
  }

  // Process the image (e.g., resize, normalize, etc.)
  Future<List<dynamic>> _processImage(XFile image) async {
    // Implement image preprocessing (e.g., resize to match model input shape)
    // This function is just a placeholder and needs proper implementation.
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        CameraPreview(_controller!),
        ElevatedButton(
          onPressed: _scanReceipt,
          child: _isDetecting
              ? const CircularProgressIndicator()
              : const Text('Scan Receipt'),
        ),
        if (_recognitions != null)
          Expanded(
            child: ListView.builder(
              itemCount: _recognitions!.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(_recognitions![i].toString()), // Adjust based on output
                subtitle: Text('Confidence: ${_recognitions![i]}'), // Adjust based on output
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter?.close();  // Close the interpreter when done
    super.dispose();
  }
}
