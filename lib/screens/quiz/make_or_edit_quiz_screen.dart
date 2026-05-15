import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clarity/models/quiz_models.dart'; 
import 'package:clarity/services/supabase_service.dart'; 

class QuestionFormControllers {
  final TextEditingController question;
  final List<TextEditingController> answers;
  int correctIndex;

  
  String? existingQuestionId;
  final List<String?> existingAnswerIds;

  QuestionFormControllers({Question? existingQuestion})
      : question = TextEditingController(text: existingQuestion?.questionText ?? ''),
        answers = List.generate(
          4,
          (i) => TextEditingController(
              text: (existingQuestion != null && i < existingQuestion.answers.length)
                  ? existingQuestion.answers[i].answerText
                  : ''),
        ),
        correctIndex = (existingQuestion != null)
            ? existingQuestion.answers.indexWhere((a) => a.isCorrect)
            : 0,
        existingQuestionId = existingQuestion?.id,
        existingAnswerIds = List.generate(
          4,
          (i) => (existingQuestion != null && i < existingQuestion.answers.length)
              ? existingQuestion.answers[i].id
              : null,
        );

  void dispose() {
    question.dispose();
    for (var controller in answers) {
      controller.dispose();
    }
  }
}

class MakeOrEditQuizScreen extends StatefulWidget {
  final String classId;
  final String? quizId; 

  bool get isEditMode => quizId != null;

  const MakeOrEditQuizScreen({super.key, required this.classId, this.quizId});

  @override
  State<MakeOrEditQuizScreen> createState() => _MakeOrEditQuizScreenState();
}

class _MakeOrEditQuizScreenState extends State<MakeOrEditQuizScreen> {
  final _supabase = Supabase.instance.client;
  final _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final _quizTitleController = TextEditingController();
  List<QuestionFormControllers> _questionControllers = [];
  bool _isLoading = false;
  bool _isFetchingData = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _loadExistingQuizData();
    } else {
      setState(() {
        _questionControllers = [QuestionFormControllers()];
        _isFetchingData = false;
      });
    }
  }

  Future<void> _loadExistingQuizData() async {
    try {
      final quizDetails = await _supabaseService.getQuizDetails(widget.quizId!);
      _quizTitleController.text = quizDetails.title;
      _questionControllers = quizDetails.questions!
          .map((q) => QuestionFormControllers(existingQuestion: q))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kuis: $e');
    } finally {
      if (mounted) setState(() => _isFetchingData = false);
    }
  }

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

  Future<void> _saveOrUpdateQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.isEditMode) {
        await _updateQuiz();
      } else {
        await _saveNewQuiz();
      }

      Get.back(result: true);
      Get.snackbar(
        'Sukses', 
        'Kuis berhasil disimpan!',
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

  Future<void> _saveNewQuiz() async {
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

      final answersData = List.generate(qc.answers.length, (i) => {
        'question_id': questionId,
        'answer_text': qc.answers[i].text,
        'is_correct': qc.correctIndex == i,
      });
      await _supabase.from('answers').insert(answersData);
    }
  }

  Future<void> _updateQuiz() async {
    await _supabase.from('quizzes').update({'title': _quizTitleController.text}).eq('id', widget.quizId!);

    final questionsResponse = await _supabase.from('questions').select('id').eq('quiz_id', widget.quizId!);
    final questionIds = (questionsResponse as List).map((q) => q['id'] as String).toList();
    if (questionIds.isNotEmpty) {
      await _supabase.from('answers').delete().in_('question_id', questionIds);
    }
    await _supabase.from('questions').delete().eq('quiz_id', widget.quizId!);
    for (final qc in _questionControllers) {
      final questionData = {
        'quiz_id': widget.quizId!,
        'question_text': qc.question.text,
      };
      final questionResponse = await _supabase.from('questions').insert(questionData).select().single();
      final questionId = questionResponse['id'];

      final answersData = List.generate(qc.answers.length, (i) => {
        'question_id': questionId,
        'answer_text': qc.answers[i].text,
        'is_correct': qc.correctIndex == i,
      });
      await _supabase.from('answers').insert(answersData);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? 'Edit Kuis' : 'Buat Kuis Baru')),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                onPressed: _isLoading ? null : _saveOrUpdateQuiz,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.save_alt_rounded),
                label: Text(widget.isEditMode ? 'Update Kuis' : 'Simpan Kuis'),
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
