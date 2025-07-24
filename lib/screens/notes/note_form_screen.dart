import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart'; 
import '../../services/supabase_service.dart'; 

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  Note? _existingNote;
  bool get _isEditMode => _existingNote != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Note) {
      _existingNote = Get.arguments;
      _titleController.text = _existingNote!.title;
      _contentController.text = _existingNote!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });

    try {
      final noteData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
      };

      if (_isEditMode) {
        await _supabaseService.updateNote(_existingNote!.id, noteData);
      } else {
        await _supabaseService.addNote(noteData);
      }

      Get.back();
      Get.snackbar(
        'Sukses',
        'Catatan berhasil disimpan.',
        backgroundColor: Colors.green,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading 
                  ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Page Title',
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null, 
                  expands: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Tulis catatan Anda di sini...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}