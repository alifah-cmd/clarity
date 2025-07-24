import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../models/class_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/task_card.dart';
import '../../widgets/class_card_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final String currentMonthYear = DateFormat('MMMM, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFDEBEE),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFFDEBEE),
              pinned: true,
              centerTitle: true,
              title: Text(
                currentMonthYear,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: [
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.search),
                  icon: const Icon(Icons.search, color: Colors.black, size: 28),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.notesList),
                    icon: const Icon(Icons.description, color: Colors.black54),
                    label: const Text('Notes', style: TextStyle(color: Colors.black54)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F7FA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
            _buildHorizontalDateSelector(),
            
            SliverToBoxAdapter(
              child: Container(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5),
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E2FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Activities",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<List<dynamic>>(
                      stream: _supabaseService.getCombinedScheduleStream(_selectedDate), 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final schedule = snapshot.data ?? [];

                        if (schedule.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'Tidak ada jadwal untuk hari ini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: schedule.map((item) {
                            if (item is Task) {
                              return TaskCard(
                                task: item,
                                onToggleComplete: (taskId, isCompleted) {
                                  _supabaseService.updateTaskStatus(taskId, isCompleted);
                                },
                              );
                            } else if (item is ClassModel) {
                              return ClassCardHome(classModel: item);
                            }
                            return const SizedBox.shrink();
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalDateSelector() {
    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 30,
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple[300] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
