import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile_model.dart';
import '../../models/task_model.dart';
import '../../models/note_model.dart';
import '../../models/class_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile> getProfile() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromMap(data);
  }

  Future<void> registerUser({required String fullName}) async {
    final userId = _client.auth.currentUser!.id;

    final result = await _client
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (result == null) {
      await _client.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
      });
    }
  }

  Future<void> updateProfile({required String fullName, String? avatarUrl}) async {
    final userId = _client.auth.currentUser!.id;
    final updates = {
      'full_name': fullName,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<String> uploadImage(File file, String bucketName) async {
    final userId = _client.auth.currentUser!.id;
    final fileExtension = file.path.split('.').last;
    final fileName = '$userId/avatar.$fileExtension';

    await _client.storage.from(bucketName).upload(
      fileName,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
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
}
