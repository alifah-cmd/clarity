import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class QuestionFormControllers {
  final TextEditingController question;
  final List<TextEditingController> answers;
  int correctIndex;
  QuestionFormControllers() : question = TextEditingController(), answers = List.generate(4, (_) => TextEditingController()), correctIndex = 0;
  void dispose() {
    question.dispose();
    for (var controller in answers) {
      controller.dispose();
    }
  }
}

class MakeQuizScreen extends StatefulWidget {
  final String classId;
  const MakeQuizScreen({super.key, required this.classId});

  @override
  State<MakeQuizScreen> createState() => _MakeQuizScreenState();
}

class _MakeQuizScreenState extends State<MakeQuizScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _quizTitleController = TextEditingController();
  final List<QuestionFormControllers> _questionControllers = [QuestionFormControllers()];
  bool _isLoading = false;

  @override
  void dispose() {
    _quizTitleController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() => setState(() => _questionControllers.add(QuestionFormControllers()));
  void _removeQuestion(int index) => setState(() {
    _questionControllers[index].dispose();
    _questionControllers.removeAt(index);
  });
  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final quizData = {
        'class_id': widget.classId,
        'user_id': _supabase.auth.currentUser!.id,
        'title': _quizTitleController.text,
      };
      final quizResponse = await _supabase.from('quizzes').insert(quizData).select().single();
      final quizId = quizResponse['id'];

      for (final qc in _questionControllers) {
        final questionData = {
          'quiz_id': quizId,
          'question_text': qc.question.text,
        };
        final questionResponse = await _supabase.from('questions').insert(questionData).select().single();
        final questionId = questionResponse['id'];

        final List<Map<String, dynamic>> answersData = [];
        for (int i = 0; i < qc.answers.length; i++) {
          answersData.add({
            'question_id': questionId,
            'answer_text': qc.answers[i].text,
            'is_correct': qc.correctIndex == i,
          });
        }
        await _supabase.from('answers').insert(answersData);
      }

      Get.back();
      Get.snackbar(
        'Sukses', 
        'Kuis berhasil disimpan secara permanen!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error', 
        'Gagal menyimpan kuis: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Kuis Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _quizTitleController,
              decoration: const InputDecoration(labelText: 'Judul Kuis'),
              validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null,
            ),
            const SizedBox(height: 20),
            const Divider(),
            ...List.generate(_questionControllers.length, (i) => _buildQuestionCard(i)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add), label: const Text('Tambah Soal'))),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveQuiz,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.save_alt_rounded),
                label: const Text('Simpan Kuis'),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF08A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final controllers = _questionControllers[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Soal ${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_questionControllers.length > 1)
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeQuestion(index)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controllers.question,
              decoration: const InputDecoration(labelText: 'Tulis pertanyaan di sini'),
              maxLines: 3,
              minLines: 1,
              validator: (v) => v!.isEmpty ? 'Pertanyaan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            const Text('Pilihan Jawaban (pilih satu yang benar):'),
            const SizedBox(height: 8),
            ...List.generate(controllers.answers.length, (answerIndex) {
              return Row(
                children: [
                  Radio<int>(
                    value: answerIndex,
                    groupValue: controllers.correctIndex,
                    onChanged: (value) => setState(() => controllers.correctIndex = value!),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: controllers.answers[answerIndex],
                      decoration: InputDecoration(labelText: 'Jawaban ${String.fromCharCode(65 + answerIndex)}'),
                      validator: (v) => v!.isEmpty ? 'Jawaban tidak boleh kosong' : null,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
