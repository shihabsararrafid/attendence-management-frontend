// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// Future<void> _sendImageToBackend(File imageFile) async {
//   final url = 'YOUR_BACKEND_URL'; // Replace with your backend API endpoint

//   final request = http.MultipartRequest('POST', Uri.parse(url));
//   request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

//   try {
//     final response = await request.send();

//     if (response.statusCode == 200) {
//       print('Image uploaded successfully');
//     } else {
//       print('Image upload failed with status ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error uploading image: $e');
//   }
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _cameraController;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.high,
//     );

//     await _cameraController.initialize();
//     if (!mounted) {
//       return;
//     }

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraController.value.isInitialized) {
//       return Container();
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Camera Screen'),
//       ),
//       body: Center(
//         child: CameraPreview(_cameraController),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _takePicture,
//         child: Icon(Icons.camera),
//       ),
//     );
//   }

//   void _takePicture() async {
//     try {
//       final XFile? image = await _cameraController.takePicture();

//       if (image != null) {
//         // Send the captured image to your backend
//         await _sendImageToBackend(File(image.path));
//       }
//     } catch (e) {
//       print('Error taking picture: $e');
//     }
//   }
// }
