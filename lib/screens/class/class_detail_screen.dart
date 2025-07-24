import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/class_model.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_routes.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;
  const ClassDetailScreen({super.key, required this.classModel});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final _supabase = Supabase.instance.client;
  Stream<List<Quiz>> _getQuizzesStream() {
    debugPrint("Mendengarkan kuis untuk class_id: ${widget.classModel.id}");

    return _supabase
        .from('quizzes')
        .stream(primaryKey: ['id'])
        .eq('class_id', widget.classModel.id) 
        .map((listOfMaps) {
          debugPrint("Data kuis dari Supabase: $listOfMaps");
          return listOfMaps
              .map((map) => Quiz.fromMap(map, [])) 
              .toList();
        });
  }

  void _navigateToMakeQuiz() {
    Get.toNamed(AppRoutes.makeQuiz, arguments: widget.classModel.id);
  }

  void _navigateToQuizStart(Quiz quiz) {
    Get.toNamed(AppRoutes.quizStart, arguments: quiz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFCBF1F5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Text('${widget.classModel.startTime} - ${widget.classModel.endTime}'),
                  const SizedBox(height: 12),
                  Text(widget.classModel.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.classModel.programStudy ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _navigateToMakeQuiz,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF08A8A), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Make Your Quiz', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Text("Daftar Kuis:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Quiz>>(
                stream: _getQuizzesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada kuis yang dibuat.'));
                  }
                  
                  final quizzes = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (ctx, index) {
                      final quiz = quizzes[index];
                      return QuizCardWithScore(quiz: quiz, onTap: () => _navigateToQuizStart(quiz));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class QuizCardWithScore extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;
  
  const QuizCardWithScore({super.key, required this.quiz, required this.onTap});

  Future<Map<String, int>?> _getLastAttempt() async {
    try {
      final response = await Supabase.instance.client
          .from('quiz_attempts')
          .select('score, total_questions')
          .eq('quiz_id', quiz.id)
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return {'score': response['score'], 'total': response['total_questions']};
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: FutureBuilder<Map<String, int>?>(
        future: _getLastAttempt(),
        builder: (context, snapshot) {
          String subtitle = 'Klik untuk memulai';
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final attempt = snapshot.data!;
            subtitle = 'Skor terakhir: ${attempt['score']}/${attempt['total']}';
          }

          return ListTile(
            leading: const Icon(Icons.quiz_outlined, color: Colors.cyan),
            title: Text(quiz.title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: onTap,
          );
        },
      ),
    );
  }
}
