import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;

  const EditProfileScreen({super.key, required this.initialName});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profileImage');

      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() => _imageFile = file);
        }
      }
    } catch (e) {
      _showError('Failed to load profile data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', trimmedName);

      if (_imageFile != null) {
        await prefs.setString('profileImage', _imageFile!.path);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, trimmedName);
    } catch (e) {
      _showError('Failed to save profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = join(directory.path,
            'profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final savedImage = await File(pickedFile.path).copy(imagePath);

        setState(() => _imageFile = savedImage);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', savedImage.path);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to change profile picture',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _saveProfile(context),
                      icon: const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
