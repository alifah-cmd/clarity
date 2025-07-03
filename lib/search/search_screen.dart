// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/models/note_model.dart';
import 'package:myapp/models/search_history_model.dart';
import 'package:myapp/models/task_model.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/widgets/task_card.dart';
import 'package:myapp/widgets/note_card.dart';
import 'package:myapp/utils/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  // State untuk menampung hasil pencarian
  Future<Map<String, List<dynamic>>>? _searchResultsFuture;

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    
    // Panggil fungsi search dari service dan simpan Future-nya
    setState(() {
      _searchResultsFuture = _supabaseService.searchItems(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks, notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 32),
            
            // Tampilkan hasil pencarian ATAU riwayat pencarian
            Expanded(
              child: _searchResultsFuture == null
                  ? _buildRecentSearches()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan riwayat pencarian
  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Searches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<SearchHistory>>(
            // MENGGUNAKAN FUNGSI DARI SERVICE
            stream: _supabaseService.getRecentSearchesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return _buildEmptyState('No recent searches to display');
              }
              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(history[index].keyword),
                    onTap: () {
                      _searchController.text = history[index].keyword;
                      _performSearch(history[index].keyword);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan hasil pencarian
  Widget _buildSearchResults() {
    return FutureBuilder<Map<String, List<dynamic>>>(
      // MENGGUNAKAN FUNGSI DARI SERVICE
      future: _searchResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildEmptyState('Error: ${snapshot.error}');
        }
        
        final tasks = snapshot.data?['tasks'] as List<Task>? ?? [];
        final notes = snapshot.data?['notes'] as List<Note>? ?? [];

        if (tasks.isEmpty && notes.isEmpty) {
          return _buildEmptyState('No results found for "${_searchController.text}"');
        }

        return ListView(
          children: [
            if (tasks.isNotEmpty) ...[
              const Text('Tasks Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...tasks.map((task) => TaskCard(task: task, onToggleComplete: (taskId, isCompleted) {  },)),
              const SizedBox(height: 24),
            ],
            if (notes.isNotEmpty) ...[
              const Text('Notes Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...notes.map((note) => NoteCard(note: note, onTap: (){
                Get.toNamed(AppRoutes.noteForm, arguments: note);
              }, onLongPress: (){})),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

extension on SupabaseService {
  Future<Map<String, List>>? searchItems(String trim) {
    return null;
  }
  
  getRecentSearchesStream() {}
}
