// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // untuk format jam
import 'package:myapp/widgets/custom_input_field.dart';

class QuestionFormControllers {
  final TextEditingController question;
  final List<TextEditingController> answers;
  int correctIndex;

  QuestionFormControllers()
      : question = TextEditingController(),
        answers = [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ],
        correctIndex = 0;
}

class QuizFormScreen extends StatefulWidget {
  const QuizFormScreen({super.key});

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _className;

  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<QuestionFormControllers> _questionControllers = [
    QuestionFormControllers()
  ];

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map<String, dynamic>) {
      _className = Get.arguments['className'];
    }
  }

  void _addQuestion() {
    setState(() {
      _questionControllers.add(QuestionFormControllers());
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _saveQuiz() {
    FocusScope.of(context).unfocus();

    if (_className == null || _className!.isEmpty) {
      Get.snackbar('Error', 'Nama Mata Kuliah tidak boleh kosong.');
      return;
    }

    if (_selectedDay == null) {
      Get.snackbar('Error', 'Pilih hari.');
      return;
    }

    if (_startTime == null || _endTime == null) {
      Get.snackbar('Error', 'Pilih jam mulai & selesai.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Isi semua field soal dan jawaban.');
      return;
    }

    for (final qc in _questionControllers) {
      if (qc.correctIndex < 0 || qc.correctIndex >= qc.answers.length) {
        Get.snackbar('Error', 'Setiap soal harus punya jawaban benar.');
        return;
      }
    }

    // Contoh insert payload ke backend / Supabase
    final payload = {
      'class_name': _className,
      'day_of_week': _selectedDay,
      'start_time': _startTime!.format(context),
      'end_time': _endTime!.format(context),
      'questions': _questionControllers.map((qc) => {
            'question': qc.question.text,
            'answers': qc.answers.map((a) => a.text).toList(),
            'correct_index': qc.correctIndex,
          }).toList(),
    };

    debugPrint('Payload: $payload');

    Get.snackbar('Sukses', 'Kuis disimpan! (Simulasi)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      appBar: AppBar(
        title: Text(
          'Buat Kuis - ${_className ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Hari',
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                'Senin',
                'Selasa',
                'Rabu',
                'Kamis',
                'Jumat',
                'Sabtu',
                'Minggu'
              ]
                  .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                  .toList(),
              value: _selectedDay,
              onChanged: (val) {
                setState(() {
                  _selectedDay = val;
                });
              },
              validator: (val) =>
                  val == null ? 'Pilih hari terlebih dahulu' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickStartTime,
                    child: Text(_startTime == null
                        ? 'Pilih Jam Mulai'
                        : 'Mulai: ${_startTime!.format(context)}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickEndTime,
                    child: Text(_endTime == null
                        ? 'Pilih Jam Selesai'
                        : 'Selesai: ${_endTime!.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _questionControllers.length,
              (index) => _buildQuestionCard(index),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Soal'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveQuiz,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Kuis'),
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
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Soal ${index + 1}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CustomInputField(
              controller: controllers.question,
              labelText: 'Tulis pertanyaan di sini',
              validator: (val) =>
                  val == null || val.isEmpty ? 'Pertanyaan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            const Text('Pilihan Jawaban (pilih yang benar):'),
            ...List.generate(controllers.answers.length, (answerIndex) {
              return Row(
                children: [
                  Radio<int>(
                    value: answerIndex,
                    groupValue: controllers.correctIndex,
                    onChanged: (value) {
                      setState(() {
                        controllers.correctIndex = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: CustomInputField(
                      controller: controllers.answers[answerIndex],
                      labelText:
                          'Jawaban ${String.fromCharCode(65 + answerIndex)}',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Jawaban tidak boleh kosong' : null,
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
