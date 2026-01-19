import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ArEaringScreen(),
  ));
}

class ArEaringScreen extends StatefulWidget {
  const ArEaringScreen({super.key});

  @override
  State<ArEaringScreen> createState() => _ArEaringScreenState();
}

class _ArEaringScreenState extends State<ArEaringScreen> {
  CameraController? _controller;
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: false, 
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  
  bool _isBusy = false;
  List<Face> _faces = [];
  ui.Image? _earringImage;
  String _debugStatus = "Starting Camera...";

  @override
  void initState() {
    super.initState();
    _loadImage(); 
    _initializeCamera();
  }

  Future<void> _loadImage() async {
    try {
      // Make sure 'ear1.png' assets folder mein majood ho
      final ByteData data = await rootBundle.load('assets/earrings/ear1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      setState(() {
        _earringImage = fi.image;
      });
      debugPrint("✅ Earring Image Loaded");
    } catch (e) {
      debugPrint("❌ Error loading earring image: $e");
    }
  }

  // 🔥 UPDATED INITIALIZATION LOGIC (For Infinix Fix)
  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _debugStatus = "Permission Denied");
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _debugStatus = "No Camera Found");
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera, 
        ResolutionPreset.medium, // 👈 KEY FIX: High se Medium kiya
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      _controller!.startImageStream((CameraImage image) {
        if (!_isBusy) {
          _isBusy = true;
          _processImage(image);
        }
      });

      setState(() {}); 

    } catch (e) {
      setState(() => _debugStatus = "Error: $e");
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _processImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isBusy = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        setState(() {
          _faces = faces;
        });
      }
    } catch (e) {
      debugPrint("Error detecting faces: $e");
    }
    _isBusy = false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(_debugStatus, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(_controller!)),
          ),
          
          if (_earringImage != null)
            CustomPaint(
              painter: FacePainter(
                faces: _faces,
                imageSize: Size(
                  _controller!.value.previewSize!.height,
                  _controller!.value.previewSize!.width,
                ),
                earringImage: _earringImage!,
                cameraLensDirection: _controller!.description.lensDirection,
              ),
            ),
            
           Positioned(
             bottom: 50,
             left: 0, 
             right: 0,
             child: Column(
               children: [
                 const Text(
                   "AR Earring Try-On 💎", 
                   style: TextStyle(
                     color: Colors.white, 
                     fontSize: 22, 
                     fontWeight: FontWeight.bold, 
                     shadows: [Shadow(blurRadius: 10, color: Colors.black)]
                   )
                 ),
                 // Debug Text to check if faces are detected
                 Text(
                   "Faces: ${_faces.length}", 
                   style: const TextStyle(color: Colors.green, fontSize: 14)
                 ),
               ],
             ),
           )
        ],
      ),
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotation.rotation0deg;
    } else if (Platform.isAndroid) {
      var rotationCompensation = 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      
      switch (rotationCompensation) {
        case 90: rotation = InputImageRotation.rotation90deg; break;
        case 180: rotation = InputImageRotation.rotation180deg; break;
        case 270: rotation = InputImageRotation.rotation270deg; break;
        default: rotation = InputImageRotation.rotation0deg;
      }
    }
    
    if (rotation == null) return null;

    final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format, 
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}

// --- ✨ EARING PAINTER ✨ ---
class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final ui.Image earringImage;
  final CameraLensDirection cameraLensDirection;

  FacePainter({
    required this.faces,
    required this.imageSize,
    required this.earringImage,
    required this.cameraLensDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    for (final face in faces) {
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];
      final faceContour = face.contours[FaceContourType.face];

      if (leftEye != null && rightEye != null && faceContour != null) {
        
        final double dy = (rightEye.position.y - leftEye.position.y).toDouble();
        final double dx = (rightEye.position.x - leftEye.position.x).toDouble();
        final double angle = atan2(dy, dx); 

        final double eyeDistance = sqrt(dx*dx + dy*dy);
        
        double earringSize = eyeDistance * 1.6 * scaleX; 
        if(earringSize > 220) earringSize = 220; 
        if(earringSize < 40) earringSize = 40;   

        final bool isFrontAndroid = Platform.isAndroid && cameraLensDirection == CameraLensDirection.front;

        Offset leftEyePos = Offset(
          leftEye.position.x.toDouble() * scaleX, 
          leftEye.position.y.toDouble() * scaleY
        );
        
        Offset rightEyePos = Offset(
          rightEye.position.x.toDouble() * scaleX, 
          rightEye.position.y.toDouble() * scaleY
        );

        if (isFrontAndroid) {
          leftEyePos = Offset(size.width - leftEyePos.dx, leftEyePos.dy);
          rightEyePos = Offset(size.width - rightEyePos.dx, rightEyePos.dy);
        }

        // Width (Distance): 1.9
        final double xOffset = eyeDistance * 1.9 * scaleX; 
        
        // Height (Drop): 1.1 
        final double yDrop = eyeDistance * 1.1 * scaleY;

        final Offset leftEarPos = _rotatePoint(
          center: leftEyePos, 
          point: Offset(leftEyePos.dx - xOffset, leftEyePos.dy + yDrop), 
          angle: angle
        );

        final Offset rightEarPos = _rotatePoint(
          center: rightEyePos, 
          point: Offset(rightEyePos.dx + xOffset, rightEyePos.dy + yDrop), 
          angle: angle
        );

        _drawRotatedEarring(canvas, leftEarPos, earringSize, angle);
        _drawRotatedEarring(canvas, rightEarPos, earringSize, angle);
      }
    }
  }

  Offset _rotatePoint({required Offset center, required Offset point, required double angle}) {
    double cosA = cos(angle);
    double sinA = sin(angle);
    
    double dx = point.dx - center.dx;
    double dy = point.dy - center.dy;

    double newX = center.dx + (dx * cosA - dy * sinA);
    double newY = center.dy + (dx * sinA + dy * cosA);

    return Offset(newX, newY);
  }

  void _drawRotatedEarring(Canvas canvas, Offset position, double size, double angle) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    paintImage(
      canvas: canvas,
      rect: Rect.fromCenter(
        center: Offset.zero,
        width: size,
        height: size,
      ),
      image: earringImage,
      fit: BoxFit.contain,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}


