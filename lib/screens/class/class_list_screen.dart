import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/class_model.dart'; 
import '../../services/supabase_service.dart'; 
import '../../utils/app_routes.dart'; 
import '../../widgets/custom_input_field.dart'; 

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // Fungsi untuk menampilkan pop-up dan menangani pembuatan kelas baru
  void _showCreateClassPopup() {
    final classNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false; // State lokal untuk loading di dalam dialog

    Get.dialog(
      AlertDialog(
        title: const Text('Buat Kelas Baru'),
        content: Form(
          key: formKey,
          child: CustomInputField(
            controller: classNameController,
            labelText: 'Nama Mata Kuliah',
            validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          StatefulBuilder(
            builder: (context, setDialogState) {
              return ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setDialogState(() => isLoading = true);
                    try {
                      // Simpan kelas baru ke database
                      await _supabaseService.addClass({
                        'class_name': classNameController.text.trim(),
                        // Anda bisa menambahkan field lain di sini jika ada formnya
                      });
                      
                      Get.back(); // Tutup dialog
                      // Langsung navigasi ke halaman buat kuis dengan mengirim nama kelas
                      Get.toNamed(
                        AppRoutes.quizForm,
                        arguments: {'className': classNameController.text.trim()},
                      );
                    } catch (e) {
                      Get.snackbar('Error', 'Gagal membuat kelas: ${e.toString()}');
                    } finally {
                       setDialogState(() => isLoading = false);
                    }
                  }
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lanjutkan'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2FF),
      appBar: AppBar(
        title: const Text('CLASS', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Tombol "Make Your Quiz"
            SizedBox(
              width: Get.width * 0.7,
              child: ElevatedButton(
                onPressed: _showCreateClassPopup, // Tombol ini juga membuka pop-up
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57373),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Make Your Quiz',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // TOMBOL BARU "TAMBAHKAN KELAS"
            SizedBox(
              width: Get.width * 0.7,
              child: OutlinedButton.icon(
                onPressed: _showCreateClassPopup,
                icon: const Icon(Icons.add),
                label: const Text('Tambahkan Kelas'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Daftar kelas dari database
            Expanded(
              child: StreamBuilder<List<ClassModel>>(
                stream: _supabaseService.getClassesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Tampilan jika tidak ada kelas
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Tambahkan Kelas Anda",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final classes = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classItem = classes[index];
                      return _buildClassCard(classItem);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassModel classItem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman konfirmasi sebelum mengerjakan kuis
          Get.toNamed(AppRoutes.quizStart, arguments: classItem);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Anda bisa menambahkan waktu jika ada datanya
              // Text('${classItem.startTime} - ${classItem.endTime}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              // const SizedBox(height: 8),
              Text(
                classItem.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if(classItem.programStudy != null) ...[
                const SizedBox(height: 4),
                Text(classItem.programStudy!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
