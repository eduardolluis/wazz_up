import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wazz_up/screens/camera_view.dart';
import 'package:wazz_up/screens/video_screen.dart';

List<CameraDescription> cameras = [];

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> cameraValue;
  bool isRecording = false;
  String? path;
  @override
  void initState() {
    super.initState();

    if (cameras.isEmpty) {
      throw Exception("No hay cámaras disponibles");
    }

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    cameraValue = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController);
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error al inicializar la cámara',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onLongPress: () async {
                          try {
                            await _cameraController.startVideoRecording();

                            if (!mounted) return;

                            setState(() {
                              isRecording = true;
                            });
                          } on CameraException catch (e) {
                            debugPrint(
                              "Error al iniciar video: ${e.description}",
                            );
                          }
                        },
                        onLongPressUp: () async {
                          try {
                            final XFile video = await _cameraController
                                .stopVideoRecording();

                            if (!mounted) return;

                            setState(() {
                              isRecording = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoScreen(path: video.path),
                              ),
                            );
                          } on CameraException catch (e) {
                            debugPrint(
                              "Error al detener video: ${e.description}",
                            );
                          }
                        },
                        onTap: () {
                          if (!isRecording) {
                            takePhoto(context);
                          }
                        },
                        child: Icon(
                          isRecording
                              ? Icons.radio_button_on
                              : Icons.panorama_fish_eye,
                          color: isRecording ? Colors.red : Colors.white,
                          size: isRecording ? 80 : 70,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Hold for video, tap for photo",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void takePhoto(BuildContext context) async {
    try {
      final navigator = Navigator.of(context);

      final XFile photo = await _cameraController.takePicture();

      if (!mounted) return;

      navigator.push(
        MaterialPageRoute(builder: (context) => CameraView(path: photo.path)),
      );
    } on CameraException catch (e) {
      debugPrint("Error al tomar foto: ${e.description}");
    }
  }
}
