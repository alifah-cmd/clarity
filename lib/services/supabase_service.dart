import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../models/user_profile_model.dart';
import '../../models/task_model.dart';
import '../../models/note_model.dart';
import '../../models/class_model.dart';
import '../../models/search_history_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> registerUser({required String fullName}) async {
    final userId = _client.auth.currentUser!.id;

    final result = await _client
        .from('users') 
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (result == null) {
      await _client.from('users').insert({ 
        'id': userId,
        'full_name': fullName,
      });
    }
  }

  Future<UserProfile> getProfile() async {
    final userId = _client.auth.currentUser!.id;
    final data =
        await _client.from('users').select().eq('id', userId).single();
    return UserProfile.fromMap(data);
  }
  Future<void> updateProfile({required String fullName, String? avatarUrl}) async {
    final userId = _client.auth.currentUser!.id;
    final updates = {
      'full_name': fullName,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('users').update(updates).eq('id', userId);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<String> uploadImageFile(File file, String bucketName) async {
    final userId = _client.auth.currentUser!.id;
    final fileExtension = file.path.split('.').last;
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _client.storage.from(bucketName).upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  Future<String> uploadImageBytes(Uint8List bytes, String fileExtension, String bucketName) async {
    final userId = _client.auth.currentUser!.id;
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _client.storage.from(bucketName).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: 'image/$fileExtension',
          ),
        );
        
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  Future<List<Task>> getTasks(DateTime date) async {
    final userId = _client.auth.currentUser!.id;
    final startOfDay = DateTime.utc(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .order('start_time', ascending: true);

    return (result as List).map((map) => Task.fromMap(map)).toList();
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    final userId = _client.auth.currentUser!.id;
    taskData['user_id'] = userId;

    if (taskData['deadline'] == null && taskData['start_time'] != null) {
      taskData['deadline'] = taskData['start_time'];
    }

    await _client.from('tasks').insert(taskData);
  }

  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    await _client.from('tasks').update({'is_completed': isCompleted}).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  Stream<List<Note>> getNotesStream() {
    final userId = _client.auth.currentUser!.id;
    return _client
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Note.fromMap(map)).toList());
  }

  Future<void> addNote(Map<String, dynamic> noteData) async {
    final userId = _client.auth.currentUser!.id;
    noteData['user_id'] = userId;
    await _client.from('notes').insert(noteData);
  }

  Future<void> updateNote(String noteId, Map<String, dynamic> noteData) async {
    await _client.from('notes').update(noteData).eq('id', noteId);
  }

  Future<void> deleteNote(String noteId) async {
    await _client.from('notes').delete().eq('id', noteId);
  }

  Stream<List<ClassModel>> getClassesStream() {
    final userId = _client.auth.currentUser!.id;
    return _client
        .from('classes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('class_name', ascending: true)
        .map((maps) => maps.map((map) => ClassModel.fromMap(map)).toList());
  }

  Future<void> addClass(Map<String, dynamic> classData) async {
    final userId = _client.auth.currentUser!.id;
    classData['user_id'] = userId;
    await _client.from('classes').insert(classData);
  }

  Future<List<dynamic>> searchAllItems(String query) async {
    if (query.isEmpty) {
      return []; 
    }

    final userId = _client.auth.currentUser!.id;
    final searchQuery = '%$query%'; 
    final tasksFuture = _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .ilike('title', searchQuery); 

    final classesFuture = _client
        .from('classes')
        .select()
        .eq('user_id', userId)
        .ilike('class_name', searchQuery);

    final notesFuture = _client
        .from('notes')
        .select()
        .eq('user_id', userId)
        .ilike('title', searchQuery);

    final results = await Future.wait([tasksFuture, classesFuture, notesFuture]);

    final List<Task> tasks = (results[0] as List).map((map) => Task.fromMap(map)).toList();
    final List<ClassModel> classes = (results[1] as List).map((map) => ClassModel.fromMap(map)).toList();
    final List<Note> notes = (results[2] as List).map((map) => Note.fromMap(map)).toList();

    final List<dynamic> combinedList = [...tasks, ...classes, ...notes];
    
    return combinedList;
  }

  Stream<List<dynamic>> getCombinedScheduleStream(DateTime date) {
    final userId = _client.auth.currentUser!.id;
    final startOfDay = DateTime.utc(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((taskMaps) async {
          final filteredTaskMaps = taskMaps.where((map) {
            if (map['start_time'] == null) return false;
            final startTime = DateTime.parse(map['start_time']);
            return startTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && startTime.isBefore(endOfDay);
          }).toList();

          final List<Task> tasks = filteredTaskMaps.map((map) => Task.fromMap(map)).toList();

          final String dayOfWeek = DateFormat('EEEE', 'id_ID').format(date);
          final classesResponse = await _client
              .from('classes')
              .select()
              .eq('user_id', userId)
              .eq('day_of_week', dayOfWeek);
          final List<ClassModel> classes = (classesResponse as List)
              .map((map) => ClassModel.fromMap(map))
              .toList();
          final List<dynamic> combinedList = [...tasks, ...classes];
          combinedList.sort((a, b) {
            DateTime? dateTimeA;
            DateTime? dateTimeB;
            if (a is Task) {
              dateTimeA = a.startTime != null ? DateTime.parse(a.startTime as String) : null;
            } else if (a is ClassModel) {
              final parts = a.startTime.split(':');
              dateTimeA = DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
            }
            if (b is Task) {
              dateTimeB = b.startTime != null ? DateTime.parse(b.startTime as String) : null;
            } else if (b is ClassModel) {
              final parts = b.startTime.split(':');
              dateTimeB = DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
            }
            if (dateTimeA == null && dateTimeB == null) return 0;
            if (dateTimeA == null) return 1;
            if (dateTimeB == null) return -1;
            return dateTimeA.compareTo(dateTimeB);
          });

          return combinedList;
        })
        .asyncMap((event) => event);
  
  }

  Stream<List<SearchHistory>> getSearchHistoryStream() {
    final userId = _client.auth.currentUser!.id;
    return _client
        .from('search_history')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('searched_at', ascending: false) 
        .limit(10)
        .map((maps) => maps.map((map) => SearchHistory.fromMap(map)).toList());
  }

  Future<void> addSearchHistory(String keyword) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('search_history').delete().match({
      'user_id': userId,
      'keyword': keyword,
    });
    await _client.from('search_history').insert({
      'user_id': userId,
      'keyword': keyword,
    });
  }

  Future<void> deleteSearchHistory(String id) async {
    await _client.from('search_history').delete().eq('id', id);
  }
}
