import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../../models/class_model.dart';
import '../../utils/app_routes.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final _supabase = Supabase.instance.client;

  Stream<List<ClassModel>> _getClassesStream() {
    return _supabase
        .from('classes')
        .stream(primaryKey: ['id']) 
        .map((maps) => maps.map((map) => ClassModel.fromMap(map)).toList());
  }

  Future<void> _addClass(ClassModel newClass) async {
    try {
      final dataToInsert = newClass.toMap();
      dataToInsert.remove('id');
      dataToInsert['user_id'] = _supabase.auth.currentUser?.id;

      await _supabase.from('classes').insert(dataToInsert);

      Get.snackbar('Sukses', 'Kelas berhasil ditambahkan!');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan kelas: ${e.toString()}');
    }
  }

  void _showAddClassDialog() {
    final formKey = GlobalKey<FormState>();
    final classNameController = TextEditingController();
    final programStudyController = TextEditingController();
    String? selectedDay;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tambahkan Kelas Baru'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: classNameController,
                      decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
                      validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    TextFormField(
                      controller: programStudyController,
                      decoration: const InputDecoration(labelText: 'Program Studi'),
                      validator: (value) => value == null || value.isEmpty ? 'Prodi tidak boleh kosong' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      hint: const Text('Pilih Hari'),
                      items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu']
                          .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDay = value;
                        });
                      },
                      validator: (value) => value == null ? 'Pilih hari' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (pickedTime != null) {
                                setDialogState(() {
                                  startTime = pickedTime;
                                });
                              }
                            },
                            child: Text(startTime == null ? 'Jam Mulai' : startTime!.format(context)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (pickedTime != null) {
                                setDialogState(() {
                                  endTime = pickedTime;
                                });
                              }
                            },
                            child: Text(endTime == null ? 'Jam Selesai' : endTime!.format(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() && startTime != null && endTime != null) {
                    final newClass = ClassModel(
                      id: '', 
                      userId: '', 
                      name: classNameController.text,
                      programStudy: programStudyController.text,
                      dayOfWeek: selectedDay!,
                      startTime: startTime!.format(context),
                      endTime: endTime!.format(context),
                    );
                    _addClass(newClass);
                    Get.back();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToClassDetail(ClassModel classModel) {
    Get.toNamed(AppRoutes.classDetail, arguments: classModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASS', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _showAddClassDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF08A8A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tambahkan Kelas',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<ClassModel>>(
              stream: _getClassesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final classes = snapshot.data ?? [];

                if (classes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Belum ada kelas.\nSilakan tambahkan kelas baru.', textAlign: TextAlign.center),
                    ),
                  );
                }

                final Map<String, List<ClassModel>> groupedClasses = {};
                for (var cls in classes) {
                  (groupedClasses[cls.dayOfWeek] ??= []).add(cls);
                }
                final sortedDays = groupedClasses.keys.toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedDays.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    final dayClasses = groupedClasses[day]!;
                    return _buildDaySection(day, dayClasses);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(String day, List<ClassModel> dayClasses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: dayClasses.length,
          itemBuilder: (context, index) {
            final classItem = dayClasses[index];
            final color = index % 2 == 0 ? const Color(0xFFCBF1F5) : const Color(0xFFFFE3E1);
            
            return ClassCard(
              classModel: classItem,
              color: color,
              onTap: () => _navigateToClassDetail(classItem),
            );
          },
        ),
      ],
    );
  }
}

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final Color color;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${classModel.startTime} - ${classModel.endTime}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              classModel.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              classModel.programStudy ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
