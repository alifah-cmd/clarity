import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clarity/models/quiz_models.dart'; 
import 'package:clarity/services/supabase_service.dart'; 
import 'make_or_edit_quiz_screen.dart'; 

class QuizListScreen extends StatefulWidget {
  final String classId;
  final String className;

  const QuizListScreen({super.key, required this.classId, required this.className});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture = _supabaseService.getQuizzesForClass(widget.classId);
    setState(() {});
  }

  Future<void> _deleteQuiz(String quizId) async {
    final confirm = await Get.defaultDialog<bool>(
      title: "Hapus Kuis?",
      middleText: "Apakah Anda yakin ingin menghapus kuis ini secara permanen?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirm == true) {
      try {
        await _supabaseService.deleteQuiz(quizId);
        Get.snackbar('Sukses', 'Kuis berhasil dihapus.');
        _loadQuizzes();
      } catch (e) {
        Get.snackbar('Error', 'Gagal menghapus kuis: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kuis - ${widget.className}'),
      ),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada kuis yang dibuat.'));
          }

          final quizzes = snapshot.data!;
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () async {
                          final result = await Get.to(() => MakeOrEditQuizScreen(
                                classId: widget.classId,
                                quizId: quiz.id, 
                              ));
                          if (result == true) {
                            _loadQuizzes();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteQuiz(quiz.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => MakeOrEditQuizScreen(classId: widget.classId));
          if (result == true) {
            _loadQuizzes();
          }
        },
        label: const Text('Buat Kuis Baru'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
