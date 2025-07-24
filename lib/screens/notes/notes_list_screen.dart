import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart'; 
import '../../services/supabase_service.dart'; 
import '../../utils/app_routes.dart'; 
import '../../widgets/note_card.dart'; 

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  void _showDeleteConfirmation(Note note) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${note.title}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back(); 
              try {
                await _supabaseService.deleteNote(note.id);
                Get.snackbar(
                  'Sukses',
                  'Catatan berhasil dihapus.',
                  backgroundColor: Colors.green,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus catatan.',
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEBEE),
      appBar: AppBar(
        title: const Text(
          'NOTE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () {
             
            },
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: _supabaseService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum punya catatan.\nTekan tombol + untuk membuat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8, 
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () {
                  Get.toNamed(AppRoutes.noteForm, arguments: note);
                },
                onLongPress: () {
                  _showDeleteConfirmation(note);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.noteForm),
        backgroundColor: const Color(0xFFE57373),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
