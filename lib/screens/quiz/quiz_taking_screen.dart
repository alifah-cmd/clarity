import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/quiz_model.dart';

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizTakingScreen({super.key, required this.quiz});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<String, String> _selectedAnswers = {};

  bool _isAnswered = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestionsAndAnswers();
  }

  Future<void> _fetchQuestionsAndAnswers() async {
    try {
      final questionsResponse = await _supabase
          .from('questions')
          .select()
          .eq('quiz_id', widget.quiz.id);

      final List<Question> loadedQuestions = [];
      for (final qMap in questionsResponse) {
        final answersResponse = await _supabase
            .from('answers')
            .select()
            .eq('question_id', qMap['id']);
        
        final List<Answer> answers = (answersResponse as List)
            .map((aMap) => Answer.fromMap(aMap))
            .toList();
        
        answers.shuffle();
        loadedQuestions.add(Question.fromMap(qMap, answers));
      }
      
      loadedQuestions.shuffle();

      setState(() {
        _questions = loadedQuestions;
        _isLoading = false;
      });

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat soal kuis: ${e.toString()}');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectAnswer(String questionId, String answerId) {
    if (!_isAnswered) {
      setState(() {
        _selectedAnswers[questionId] = answerId;
      });
    }
  }

  void _answerQuestion() {
    final questionId = _questions[_currentQuestionIndex].id;
    if (_selectedAnswers[questionId] == null) {
      Get.snackbar('Peringatan', 'Silakan pilih jawaban terlebih dahulu.');
      return;
    }

    setState(() {
      _isAnswered = true;
      final selectedAnswerId = _selectedAnswers[questionId];
      final correctAnswer = _questions[_currentQuestionIndex].answers.firstWhere((a) => a.isCorrect);
      if (correctAnswer.id == selectedAnswerId) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }
  Future<void> _finishQuiz() async {
    try {
      await _supabase.from('quiz_attempts').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'quiz_id': widget.quiz.id,
        'score': _score,
        'total_questions': _questions.length,
      });
    } catch (e) {
     // Get.snackbar('Peringatan', 'Gagal menyimpan skor, periksa koneksi Anda.');
     // debugPrint("Error menyimpan skor: ${e.toString()}");
    } finally {
      Get.defaultDialog(
        title: 'Kuis Selesai!',
        middleText: 'Skor Anda: $_score dari ${_questions.length} soal.',
        textConfirm: 'OK',
        onConfirm: () => Get.close(2),
        barrierDismissible: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: Text(widget.quiz.title)), body: const Center(child: CircularProgressIndicator()));
    }
    if (_questions.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(widget.quiz.title)), body: const Center(child: Text('Kuis ini belum memiliki soal.')));
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[300]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Soal ${_currentQuestionIndex + 1} dari ${_questions.length}', style: Get.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(currentQuestion.text, style: Get.textTheme.headlineSmall),
            const SizedBox(height: 24),
            ...currentQuestion.answers.map((answer) => _buildAnswerOption(currentQuestion, answer)),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedAnswers[currentQuestion.id] == null ? null : (_isAnswered ? _nextQuestion : _answerQuestion),
              child: Text(_isAnswered ? 'Selanjutnya' : 'Jawab'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(Question question, Answer answer) {
    final isSelected = _selectedAnswers[question.id] == answer.id;
    Color? tileColor;

    if (_isAnswered) {
      if (answer.isCorrect) {
        tileColor = Colors.green;
      } else if (isSelected) {
        tileColor = Colors.red;
      }
    } else if (isSelected) {
      tileColor = Colors.cyan;
    }

    return Card(
      color: tileColor,
      child: ListTile(
        title: Text(answer.text),
        onTap: () => _selectAnswer(question.id, answer.id),
      ),
    );
  }
}
