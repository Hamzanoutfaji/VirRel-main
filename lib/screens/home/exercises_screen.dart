import 'package:flutter/material.dart';
import '../../widgets/exercise_card.dart';
import 'strength_training_screen.dart';
import 'stretching_screen.dart';
import 'yoga_screen.dart';

class ExercisesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exercises = [
    {
      "title": "Strength Training",
      "icon": Icons.fitness_center,
      "screen": StrengthTrainingScreen(),
    },
    {
      "title": "Stretching",
      "icon": Icons.accessibility_new,
      "screen": StretchingScreen(),
    },
    {
      "title": "Yoga",
      "icon": Icons.self_improvement,
      "screen": YogaScreen(),
    },
  ];

  ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Exercises",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ExerciseCard(
              title: exercise["title"],
              icon: exercise["icon"],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => exercise["screen"]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
