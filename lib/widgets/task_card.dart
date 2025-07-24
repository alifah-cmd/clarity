import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/supabase_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({super.key, required this.task, required Null Function(dynamic taskId, dynamic isCompleted) onToggleComplete});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _isCompleted;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  void _onCheckboxChanged(bool? value) {
    if (value == null) return;
    
    setState(() {
      _isCompleted = value;
    });
    try {
      _supabaseService.updateTaskStatus(widget.task.id, value);
    } catch (e) {
      setState(() {
        _isCompleted = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui tugas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _isCompleted ? Colors.grey[300] : Colors.pink[50];
    final textColor = _isCompleted ? Colors.grey[600] : Colors.black;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        leading: Checkbox(
          value: _isCompleted,
          onChanged: _onCheckboxChanged,
          activeColor: Colors.deepPurple[400],
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.grey, width: 2),
        ),
        title: Text(
          widget.task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            decoration: _isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          '${widget.task.startTime} - ${widget.task.endTime}',
          style: TextStyle(
            color: textColor,
            decoration: _isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
