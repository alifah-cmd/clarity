import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_routes.dart';

class QuizStartScreen extends StatelessWidget {
  const QuizStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Quiz quiz = Get.arguments as Quiz;

    return Scaffold(
      backgroundColor: const Color(0xFFFDEBEE), 
      appBar: AppBar(
        title: Text(quiz.title), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.quizTaking, arguments: quiz);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Are You Ready ?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
              Image.asset(
              'assets/images/areyou.png',
              height: Get.height * 0.35,
            ),
          ],
        ),
      ),
    );
  }
}
