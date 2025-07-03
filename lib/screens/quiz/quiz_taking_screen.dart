// lib/screens/quiz/quiz_taking_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/models/quiz_model.dart'; // Ganti 'myapp'
// import 'package:myapp/services/supabase_service.dart'; // Nanti dipakai untuk fetch data

class QuizTakingScreen extends StatefulWidget {
  const QuizTakingScreen({super.key});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  // Data dummy untuk simulasi
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswerId;
  bool _isAnswered = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadAndShuffleQuiz();
  }

  void _loadAndShuffleQuiz() {
   
    var dummyQuiz = _getDummyQuiz();
    
    // Acak urutan pertanyaan
    dummyQuiz.questions.shuffle();
    
    // Acak urutan jawaban untuk setiap pertanyaan
    for (var question in dummyQuiz.questions) {
      question.answers.shuffle();
    }

    setState(() {
      _questions = dummyQuiz.questions;
    });
  }

  void _answerQuestion() {
    if (_selectedAnswerId == null) {
      Get.snackbar('Peringatan', 'Silakan pilih jawaban terlebih dahulu.');
      return;
    }
    setState(() {
      _isAnswered = true;
      final selectedAnswer = _questions[_currentQuestionIndex]
          .answers
          .firstWhere((a) => a.id == _selectedAnswerId);
      if (selectedAnswer.isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerId = null;
      });
    } else {
      // Kuis selesai
      Get.defaultDialog(
        title: 'Kuis Selesai!',
        middleText: 'Skor Anda: $_score dari ${_questions.length}',
        textConfirm: 'OK',
        onConfirm: () {
          Get.back(); // Tutup dialog
          Get.back(); // Kembali ke halaman sebelum kuis
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(
        title: Text('Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 24),
            // Pertanyaan
            Text(
              currentQuestion.text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // Pilihan Jawaban
            // PERBAIKAN: Menghapus .toList() yang tidak perlu
            ...currentQuestion.answers.map((answer) {
              return _buildAnswerOption(answer);
            }),
            const Spacer(),
            // Tombol Submit/Next
            ElevatedButton(
              onPressed: _isAnswered ? _nextQuestion : _answerQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isAnswered ? 'Next' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(Answer answer) {
    bool isSelected = _selectedAnswerId == answer.id;
    Color? tileColor;

    if (_isAnswered) {
      if (answer.isCorrect) {
        tileColor = Colors.green[200]; // Jawaban benar selalu hijau
      } else if (isSelected) {
        tileColor = Colors.red[200]; // Jawaban salah yang dipilih menjadi merah
      }
    }

    return Card(
      color: tileColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: RadioListTile<String>(
        value: answer.id,
        groupValue: _selectedAnswerId,
        title: Text(answer.text),
        onChanged: _isAnswered ? null : (value) {
          setState(() {
            _selectedAnswerId = value;
          });
        },
      ),
    );
  }
  
  // Fungsi untuk data dummy
  Quiz _getDummyQuiz() {
    return Quiz(
        id: 'q1',
        classId: 'c1',
        title: 'General Knowledge',
        questions: [
          Question(id: 'qu1', text: 'What is the capital of France?', answers: [
            Answer(id: 'a1', text: 'Berlin', isCorrect: false),
            Answer(id: 'a2', text: 'Madrid', isCorrect: false),
            Answer(id: 'a3', text: 'Paris', isCorrect: true),
            Answer(id: 'a4', text: 'Rome', isCorrect: false),
          ]),
          Question(id: 'qu2', text: 'Which planet is known as the Red Planet?', answers: [
            Answer(id: 'b1', text: 'Earth', isCorrect: false),
            Answer(id: 'b2', text: 'Mars', isCorrect: true),
            Answer(id: 'b3', text: 'Jupiter', isCorrect: false),
            Answer(id: 'b4', text: 'Venus', isCorrect: false),
          ]),
           Question(id: 'qu3', text: 'What is the largest ocean on Earth?', answers: [
            Answer(id: 'c1', text: 'Atlantic', isCorrect: false),
            Answer(id: 'c2', text: 'Indian', isCorrect: false),
            Answer(id: 'c3', text: 'Arctic', isCorrect: false),
            Answer(id: 'c4', text: 'Pacific', isCorrect: true),
          ]),
        ]);
  }
}
