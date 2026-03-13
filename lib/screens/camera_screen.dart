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
  int currentCameraIndex = 0;
  FlashMode currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();

    if (cameras.isEmpty) {
      throw Exception("No hay cámaras disponibles");
    }

    _initializeCamera(currentCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    _cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    cameraValue = _cameraController.initialize();

    try {
      await cameraValue;

      // Intenta aplicar el flash actual a la nueva cámara.
      // En algunas cámaras frontales puede no estar soportado.
      await _cameraController.setFlashMode(currentFlashMode);

      if (mounted) {
        setState(() {});
      }
    } on CameraException catch (e) {
      debugPrint("Error al inicializar cámara: ${e.description}");
    }
  }

  Future<void> _toggleFlash() async {
    try {
      if (!_cameraController.value.isInitialized) return;

      // Alterna entre apagado y torch
      final FlashMode newMode = currentFlashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;

      await _cameraController.setFlashMode(newMode);

      if (!mounted) return;
      setState(() {
        currentFlashMode = newMode;
      });
    } on CameraException catch (e) {
      debugPrint("Error al cambiar flash: ${e.description}");
    }
  }

  Future<void> _flipCamera() async {
    if (cameras.length < 2) return;
    if (isRecording) return;

    try {
      currentCameraIndex = (currentCameraIndex + 1) % cameras.length;

      await _cameraController.dispose();
      await _initializeCamera(currentCameraIndex);
    } on CameraException catch (e) {
      debugPrint("Error al cambiar cámara: ${e.description}");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (!_cameraController.value.isInitialized) {
                  return const Center(
                    child: Text(
                      'La cámara no está inicializada',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
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
                        onPressed: _toggleFlash,
                        icon: Icon(
                          currentFlashMode == FlashMode.off
                              ? Icons.flash_off
                              : Icons.flash_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onLongPress: () async {
                          try {
                            if (!_cameraController.value.isInitialized) return;
                            if (_cameraController.value.isRecordingVideo)
                              return;

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
                            if (!_cameraController.value.isRecordingVideo)
                              return;

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
                        onPressed: _flipCamera,
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
      if (!_cameraController.value.isInitialized) return;
      if (_cameraController.value.isTakingPicture) return;

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
