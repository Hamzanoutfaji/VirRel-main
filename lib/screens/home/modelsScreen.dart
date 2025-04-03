import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ModelsScreen extends StatefulWidget {
  final String modelPath;

  const ModelsScreen({super.key, required this.modelPath});

  @override
  _ModelsScreenState createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  final Flutter3DController controller = Flutter3DController();
  List<String> availableAnimations = [];
  List<String> availableTextures = [];
  String? chosenAnimation;
  String? chosenTexture;
  bool isPlaying = false;
  bool modelLoadError = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadModel();
    });
  }

  Future<void> loadModel() async {
    setState(() {
      isLoading = true;
      modelLoadError = false;
    });

    try {
      // Now fetch animations and textures
      await fetchModelData();
      
      setState(() {
        isLoading = false;
        modelLoadError = false;
      });
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        isLoading = false;
        modelLoadError = true;
      });
    }
  }

  Future<void> fetchModelData() async {
    try {
      availableAnimations = await controller.getAvailableAnimations();
      availableTextures = await controller.getAvailableTextures();

      print('Fetched Animations: $availableAnimations');
      print('Fetched Textures: $availableTextures');

      setState(() {
        chosenAnimation = availableAnimations.isNotEmpty ? availableAnimations.first : null;
        chosenTexture = availableTextures.isNotEmpty ? availableTextures.first : null;
      });

      if (chosenAnimation != null) {
        controller.playAnimation(animationName: chosenAnimation!);
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      print('Error fetching model data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadModel,
          ),
          if (!modelLoadError && !isLoading)
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (isPlaying) {
                  controller.pauseAnimation();
                } else if (chosenAnimation != null) {
                  controller.playAnimation(animationName: chosenAnimation!);
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading 3D model...'),
                    ],
                  ),
                )
              : modelLoadError 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Failed to load model: ${widget.modelPath}', 
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadModel,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : Flutter3DViewer(
                    controller: controller,
                    src: widget.modelPath,
                  ),
                ),
          if (!modelLoadError && !isLoading && availableAnimations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Animation: '),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: chosenAnimation,
                      items: availableAnimations.map((animation) {
                        return DropdownMenuItem(
                          value: animation,
                          child: Text(animation, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          chosenAnimation = value;
                        });
                        if (chosenAnimation != null) {
                          controller.playAnimation(animationName: chosenAnimation!);
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (!modelLoadError && !isLoading && availableTextures.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Texture: '),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: chosenTexture,
                      items: availableTextures.map((texture) {
                        return DropdownMenuItem(
                          value: texture,
                          child: Text(texture, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          chosenTexture = value;
                        });
                        if (chosenTexture != null) {
                          controller.setTexture(textureName: chosenTexture!);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (!modelLoadError && !isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // For now, we'll just reset the animation as a fallback
                      controller.resetAnimation();
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text("Reset View"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.resetAnimation();
                      setState(() {
                        isPlaying = false;
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text("Reset Animation"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}