import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_input_field.dart';
import '../../models/user_profile_model.dart';
import '../../services/supabase_service.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'dart:io'; // Import for File

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
  File? _pickedImage; // To store the picked image file

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
    setState(() {
      _isLoading = true;
    });
    try {
      final UserProfile profile = await _supabaseService.getProfile();
      // Ensure currentUser is not null before accessing its email
      final currentUserEmail = Supabase.instance.client.auth.currentUser?.email;

      _nameController.text = profile.fullName;
      _avatarUrl = profile.avatarUrl;
      _emailController.text = currentUserEmail ?? ''; // Handle null email gracefully
    } catch (e) {
      Get.snackbar(
        'Error Loading Profile',
        'Failed to load profile data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // You might want to navigate back or show a persistent error here
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? newAvatarUrl = _avatarUrl;
      if (_pickedImage != null) {
        // Assuming 'avatars' is your storage bucket name
        newAvatarUrl = await _supabaseService.uploadImage(_pickedImage!, 'avatars');
      }

      await _supabaseService.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: newAvatarUrl,
      );
      Get.snackbar('Success', 'Profile updated successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
      // Reload profile to reflect new avatar URL if it was changed
      await _loadProfile();
    } catch (e) {
      Get.snackbar('Error Updating Profile', 'Failed to update profile: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        // Temporarily update avatarUrl to show the new image immediately
        _avatarUrl = image.path; // This will show the local file path, but NetworkImage needs a URL
      });
      // The actual upload and URL update will happen when _updateProfile is called
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEBEE),
      appBar: AppBar(
        title: const Text('My Account',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onTap: _pickImage, // Allow tapping to change picture
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFE8E2FF),
                      backgroundImage: _pickedImage != null // Show picked image first
                          ? FileImage(_pickedImage!) as ImageProvider<Object>?
                          : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                      child: (_pickedImage == null && _avatarUrl == null)
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage, // Button to change picture
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
                  // Email made non-editable
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Change Password',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}