import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../../utils/app_routes.dart';
import '../../widgets/custom_input_field.dart';
import '../../models/user_profile_model.dart';
import '../../services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  String? _avatarUrl;
  
  File? _pickedImageFile; 
  Uint8List? _pickedImageBytes; 
  String? _pickedImageExtension; 

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final UserProfile profile = await _supabaseService.getProfile();
      final currentUserEmail = Supabase.instance.client.auth.currentUser?.email;

      _nameController.text = profile.fullName;
      _avatarUrl = profile.avatarUrl;
      _emailController.text = currentUserEmail ?? '';
    } catch (e) {
      Get.snackbar('Error Loading Profile', 'Failed to load profile data: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      String? updatedAvatarUrl = _avatarUrl;

      if (kIsWeb && _pickedImageBytes != null) {
        updatedAvatarUrl = await _supabaseService.uploadImageBytes(_pickedImageBytes!, _pickedImageExtension!, 'avatars');
      } else if (!kIsWeb && _pickedImageFile != null) {
        updatedAvatarUrl = await _supabaseService.uploadImageFile(_pickedImageFile!, 'avatars');
      }

      await _supabaseService.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: updatedAvatarUrl,
      );

      Get.snackbar('Success', 'Profile updated successfully');
      await _loadProfile();

    } catch (e) {
      Get.snackbar('Error Updating Profile', 'Failed to update profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pickedImageFile = null;
          _pickedImageBytes = null;
        });
      }
    }
  }
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      _pickedImageExtension = image.name.split('.').last;
      if (kIsWeb) {
        _pickedImageBytes = await image.readAsBytes();
        _pickedImageFile = null; 
      } else {
        _pickedImageFile = File(image.path);
        _pickedImageBytes = null; 
      }
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEBEE),
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFE8E2FF),
                      backgroundImage: _pickedImageBytes != null
                          ? MemoryImage(_pickedImageBytes!) as ImageProvider
                          : _pickedImageFile != null
                              ? FileImage(_pickedImageFile!) as ImageProvider
                              : _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                      child: (_pickedImageFile == null && _pickedImageBytes == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Change Picture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1C4E9),
                      foregroundColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomInputField(
                    controller: _nameController,
                    labelText: 'Name',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoutes.changePassword),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB39DDB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[200],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
