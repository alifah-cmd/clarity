import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../../models/class_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
import '../../models/search_history_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _supabaseService = SupabaseService();
  
  List<dynamic> _results = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounce; 

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _supabaseService.searchAllItems(query);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      Get.snackbar('Error', 'Gagal melakukan pencarian: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _saveHistoryAndSearch(String query) {
    if (query.trim().isNotEmpty) {
      _supabaseService.addSearchHistory(query.trim());
      _performSearch(query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); 
    super.dispose();
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _saveHistoryAndSearch,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }
    return _buildSearchHistory();
  }

  Widget _buildSearchHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<SearchHistory>>(
              stream: _supabaseService.getSearchHistoryStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(child: Text('No recent searches to display')),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(item.keyword),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => _supabaseService.deleteSearchHistory(item.id),
                        ),
                        onTap: () {
                          _searchController.text = item.keyword;
                          _onSearchChanged(item.keyword); 
                            },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Tidak ada hasil ditemukan.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];

        if (item is Task) return _buildTaskTile(item);
        if (item is ClassModel) return _buildClassTile(item);
        if (item is Note) return _buildNoteTile(item);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTaskTile(Task task) => ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.purple),
        title: Text(task.title),
        subtitle: const Text('Jadwal'),
      );
  Widget _buildClassTile(ClassModel classModel) => ListTile(
        leading: const Icon(Icons.school_outlined, color: Colors.blue),
        title: Text(classModel.name),
        subtitle: Text('Kelas: ${classModel.dayOfWeek}, ${classModel.startTime}'),
        onTap: () => Get.toNamed(AppRoutes.classDetail, arguments: classModel),
      );
  Widget _buildNoteTile(Note note) => ListTile(
        leading: const Icon(Icons.description_outlined, color: Colors.orange),
        title: Text(note.title),
        subtitle: const Text('Catatan'),
        onTap: () => Get.toNamed(AppRoutes.noteForm, arguments: note),
      );
}
