import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String phone;
  String? imageUrl;
  bool isLoading = false;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    name = widget.user.name;
    phone = widget.user.phone;
    imageUrl = widget.user.profileImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => imageFile = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (imageFile == null) return imageUrl;
    
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_profiles')
        .child('${widget.user.id}.jpg');
    
    await ref.putFile(imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final uploadedImageUrl = await _uploadImage();
      
      final updatedUser = UserModel(
        id: widget.user.id,
        name: name,
        email: widget.user.email,
        phone: phone,
        role: widget.user.role,
        profileImage: uploadedImageUrl,
        fcmToken: widget.user.fcmToken,
        createdAt: widget.user.createdAt,
      );

      await ref.read(currentUserProvider.notifier).updateProfile(updatedUser);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: imageFile != null 
                        ? FileImage(imageFile!) as ImageProvider
                        : (imageUrl != null 
                            ? NetworkImage(imageUrl!) 
                            : null),
                    child: imageUrl == null && imageFile == null
                        ? Text(
                            name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        color: Colors.white,
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => 
                    val?.isEmpty == true ? 'Name is required' : null,
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => 
                    val?.isEmpty == true ? 'Phone is required' : null,
                onChanged: (val) => phone = val,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}