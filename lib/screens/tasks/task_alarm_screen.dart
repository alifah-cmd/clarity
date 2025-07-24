
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart'; 

class TaskAlarmScreen extends StatelessWidget {
  final Task? task;
  
  const TaskAlarmScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final displayTask = task ?? Task(
      id: 'dummy_id',
      userId: 'dummy_user',
      title: 'Read a Chapter of a Book',
      deadline: DateTime.now(),
      startTime: '09:00',
      endTime: '10:00',
    );

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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Image.asset('assets/images/alr.png', height: 200), 
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyan[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '${displayTask.startTime} - ${displayTask.endTime}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayTask.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('1 hour', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                
                Get.snackbar('Snooze', 'Alarm ditunda 1 menit.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Tambah 1 menit', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Stop', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}