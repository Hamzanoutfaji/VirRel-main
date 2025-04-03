import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_detail_screen.dart';

class StrengthTrainingScreen extends StatelessWidget {
  const StrengthTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Strength Training")),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('exercises')
            .where('category', isEqualTo: 'Strength')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exercises found'));
          }

          // Data fetched successfully
          var exercises = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              var ex = exercises[index].data() as Map;
              
              // Get YouTube link
              String youtubeLink = ex['youtube_link'] ?? '';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text(ex['Exercise_name'] ?? 'No Name'),
                  subtitle: Text(
                    ex['target muscle'] != null 
                        ? 'Target: ${ex['target muscle']}' 
                        : 'No target information'
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Extract steps array or provide empty list if missing
                    List<String> steps = [];
                    if (ex['steps'] != null) {
                      if (ex['steps'] is List) {
                        steps = List<String>.from(ex['steps']);
                      }
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(
                          name: ex['Exercise_name'] ?? 'Unknown',
                          description: ex['description'] ?? 'No description',
                          reps: ex['reps']?.toString() ?? 'Not available',
                          sets: ex['sets']?.toString() ?? 'Not available',
                          steps: steps,
                          youtubeLink: youtubeLink,
                          modelPath: ex['model_path'] ?? 'assets/images/default_model',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}