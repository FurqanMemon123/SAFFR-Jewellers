import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera Error: $e");
  }
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ArChainScreen(),
  ));
}

class ArChainScreen extends StatefulWidget {
  const ArChainScreen({super.key});

  @override
  State<ArChainScreen> createState() => _ArChainScreenState();
}

class _ArChainScreenState extends State<ArChainScreen> {
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
  ui.Image? _chainImage; // Variable renamed for Chain

  @override
  void initState() {
    super.initState();
    _loadImage(); 
    _initializeCamera();
  }

  Future<void> _loadImage() async {
    try {
      // 🔥 Yahan Chain ki image load kar rahe hain
      // Make sure pubspec.yaml mein yeh path added ho
      final ByteData data = await rootBundle.load('assets/earrings/Chain.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      setState(() {
        _chainImage = fi.image;
      });
    } catch (e) {
      debugPrint("Error loading chain image: $e");
    }
  }
Future<void> _initializeCamera() async {
    debugPrint("--- Camera Init Started ---");
    
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint("❌ Permission Denied");
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("❌ No Cameras Found");
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // 🔥 CHANGE IS HERE: Resolution ko 'medium' kiya hai
      _controller = CameraController(
        frontCamera, 
        ResolutionPreset.medium, // 👈 High se Medium kiya (Important for Infinix)
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      
      // 🔥 Initialize hotay hi state update karo
      if (mounted) {
        setState(() {}); 
      }

      _controller!.startImageStream((CameraImage image) {
        if (!_isBusy) {
          _isBusy = true;
          _processImage(image);
        }
      });

      debugPrint("✅ Camera Initialized & Streaming");

    } catch (e) {
      debugPrint("❌ Camera Error: $e");
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
      setState(() {
        _faces = faces;
      });
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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
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
          
          if (_chainImage != null)
            CustomPaint(
              // 🔥 Used ChainPainter here
              painter: ChainPainter( 
                faces: _faces,
                imageSize: Size(
                  _controller!.value.previewSize!.height,
                  _controller!.value.previewSize!.width,
                ),
                chainImage: _chainImage!,
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
                   "AR Chain Try-On ⛓️", 
                   style: TextStyle(
                     color: Colors.white, 
                     fontSize: 22, 
                     fontWeight: FontWeight.bold, 
                     shadows: [Shadow(blurRadius: 10, color: Colors.black)]
                   )
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
// --- ⛓️ UPDATED CHAIN PAINTER (Bigger Size) ⛓️ ---
class ChainPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final ui.Image chainImage;
  final CameraLensDirection cameraLensDirection;

  ChainPainter({
    required this.faces,
    required this.imageSize,
    required this.chainImage,
    required this.cameraLensDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    for (final face in faces) {
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

      if (leftEye != null && rightEye != null) {
        
        // 1. Rotation Angle
        final double dy = (rightEye.position.y - leftEye.position.y).toDouble();
        final double dx = (rightEye.position.x - leftEye.position.x).toDouble();
        final double angle = atan2(dy, dx); 

        // 2. Eye Center
        Offset centerEyePos = Offset(
          (leftEye.position.x + rightEye.position.x) / 2 * scaleX,
          (leftEye.position.y + rightEye.position.y) / 2 * scaleY,
        );

        if (Platform.isAndroid && cameraLensDirection == CameraLensDirection.front) {
          centerEyePos = Offset(size.width - centerEyePos.dx, centerEyePos.dy);
        }

        // 3. Chain Sizing & Positioning Logic
        double faceHeight = face.boundingBox.height * scaleY;
        double faceWidth = face.boundingBox.width * scaleX;

        // --- 🔥 SIZE CHANGES HERE 🔥 ---
        
        // Width: 1.2 se barha kar 1.6 kar diya (Zyada chora/bara dikhega)
        double chainWidth = faceWidth * 1.6; 
        
        // Height: Width ke hisaab se adjust ki (taaki shape kharab na ho)
        double chainHeight = chainWidth * 1.1; 

        // --- POSITION (Drop) ---
        // Agar chain bari hone ki wajah se face pe chad rahi ho, 
        // toh 1.1 ko 1.3 kar dena
        double verticalDrop = faceHeight * 1.1; 

        // 4. Calculate Final Neck Position
        Offset neckPos = _rotatePoint(
          center: centerEyePos,
          point: Offset(centerEyePos.dx, centerEyePos.dy + verticalDrop),
          angle: angle
        );

        // 5. Draw Chain
        _drawRotatedChain(canvas, neckPos, chainWidth, chainHeight, angle);
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

  void _drawRotatedChain(Canvas canvas, Offset position, double width, double height, double angle) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    final Rect rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    paintImage(
      canvas: canvas,
      rect: rect,
      image: chainImage,
      fit: BoxFit.contain,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(ChainPainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}