import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/class_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
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
  bool _hasSearched = false; 

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _supabaseService.searchAllItems(query);
      setState(() {
        _results = results;
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal melakukan pencarian: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari jadwal, kelas, catatan...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Text('Mulai ketik untuk mencari.', style: TextStyle(color: Colors.grey)),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text('Tidak ada hasil ditemukan.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];

        if (item is Task) {
          return _buildTaskTile(item);
        } else if (item is ClassModel) {
          return _buildClassTile(item);
        } else if (item is Note) {
          return _buildNoteTile(item);
        }
        return const SizedBox.shrink();
      },
    );
  }
  Widget _buildTaskTile(Task task) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline, color: Colors.purple),
      title: Text(task.title),
      subtitle: const Text('Jadwal'),
      onTap: () {
      },
    );
  }
  Widget _buildClassTile(ClassModel classModel) {
    return ListTile(
      leading: const Icon(Icons.school_outlined, color: Colors.blue),
      title: Text(classModel.name),
      subtitle: Text('Kelas: ${classModel.dayOfWeek}, ${classModel.startTime}'),
      onTap: () {
        Get.toNamed(AppRoutes.classDetail, arguments: classModel);
      },
    );
  }
  Widget _buildNoteTile(Note note) {
    return ListTile(
      leading: const Icon(Icons.description_outlined, color: Colors.orange),
      title: Text(note.title),
      subtitle: const Text('Catatan'),
      onTap: () {
        Get.toNamed(AppRoutes.noteForm, arguments: note);
      },
    );
  }
}
