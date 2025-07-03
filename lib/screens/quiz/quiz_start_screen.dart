import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/class_model.dart'; // Ganti 'myapp'
import '../../utils/app_routes.dart';   // Ganti 'myapp'

class QuizStartScreen extends StatelessWidget {
  const QuizStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data kelas yang dikirim dari halaman sebelumnya
    final ClassModel? classItem = Get.arguments as ClassModel?;

    return Scaffold(
      backgroundColor: const Color(0xFFFDEBEE), // Warna pink muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Spacer untuk mendorong konten ke bawah
            const Spacer(),

            // Tombol "Are You Ready?"
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman mengerjakan kuis, kirim data kelas
                Get.toNamed(AppRoutes.quizTaking, arguments: classItem);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Are You Ready ?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const Spacer(),

            // Ilustrasi di bagian bawah
            Image.asset(
              'assets/images/areyou.png', // Pastikan Anda punya gambar ini
              height: Get.height * 0.35, // 35% dari tinggi layar
            ),
          ],
        ),
      ),
    );
  }
}