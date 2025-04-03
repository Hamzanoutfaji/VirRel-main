import 'package:flutter/material.dart';
import 'package:myapp/screens/home/modelsScreen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final String reps;
  final String sets;
  final List<String> steps;
  final String youtubeLink;
  final String modelPath;

  const ExerciseDetailScreen({
    Key? key,
    required this.name,
    required this.description,
    required this.reps,
    required this.sets,
    required this.steps,
    required this.youtubeLink,
    required this.modelPath,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  YoutubePlayerController? _controller;
  bool _isLoading = false;
  bool _videoError = false;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Extract YouTube video ID from the link
    _videoId = _extractVideoId(widget.youtubeLink);
    
    // Check if we have a valid video ID
    if (_videoId == null || _videoId!.isEmpty) {
      setState(() {
        _videoError = true;
        _isLoading = false;
      });
      return;
    }
    
    // Initialize YouTube player controller with immediate playback
    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        hideControls: false,
        hideThumbnail: false,
      ),
    )..addListener(_controllerListener);
  }

  void _controllerListener() {
    // Update loading state based on player state
    if (_controller?.value.isReady == true && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_controllerListener);
    _controller?.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;
    
    try {
      // Use the built-in YouTube Player Flutter utility to extract video ID
      return YoutubePlayer.convertUrlToId(url);
    } catch (e) {
      // Fallback to manual extraction if the utility fails
      // Handle various YouTube URL formats
      RegExp regExp = RegExp(
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
        caseSensitive: false,
      );
      
      Match? match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
      
      // If the url is just the video ID
      if (url.length > 5 && url.length <= 15 && RegExp(r'^[A-Za-z0-9_\-]{5,15}$').hasMatch(url)) {
        return url;
      }
    }
    
    return null;
  }

  Widget _buildYoutubePlayer() {
    if (_controller == null) return Container();
    
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          setState(() {
            _isLoading = false;
          });
        },
      ),
      builder: (context, player) {
        return player;
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 220,
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Failed to load YouTube video",
              style: TextStyle(color: Colors.red),
            ),
            TextButton(
              child: const Text("Try Again"),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _videoError = false;
                  _controller?.dispose();
                  _controller = null;
                });
                _initializePlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 220,
      color: Colors.black12,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading video..."),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YouTube Video Player
            _videoError 
                ? _buildErrorWidget() 
                : (_controller == null || _isLoading)
                    ? _buildLoadingWidget()
                    : _buildYoutubePlayer(),
            
            // 3D View Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  print("Opening 3D Model: ${widget.modelPath}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModelsScreen(modelPath: widget.modelPath),
                    ),
                  );
                },
                icon: const Icon(Icons.view_in_ar),
                label: const Text("View in 3D"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Steps:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...widget.steps.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${idx + 1}. ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Text(step)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Reps and Sets
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoColumn('Sets', widget.sets),
                      const SizedBox(width: 20),
                      _buildInfoColumn('Reps', widget.reps),
                    ],
                  ),
                ),
              ),
            ),
            
            // Help text for video interaction
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Video Controls",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "• Tap play/pause to control video\n"
                        "• Drag progress bar to seek\n"
                        "• Double tap to enter/exit fullscreen",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset loading state to reload video
          setState(() {
            _isLoading = true;
            _videoError = false;
            _controller?.dispose();
            _controller = null;
          });
          _initializePlayer();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Reload video',
      ),
    );
  }
}