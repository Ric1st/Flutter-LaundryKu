import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class TakePhotoScreen extends StatefulWidget {
  final String orderId;

  const TakePhotoScreen({super.key, required this.orderId});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await [Permission.camera, Permission.storage].request();
  }

  Future<void> _pickFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _uploadPhoto() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    try {
      final photoUrl = await context.read<OrderProvider>().uploadLaundryPhoto(
        orderId: widget.orderId,
        imageFile: _image!,
      );

      await context.read<OrderProvider>().updateOrderStatus(
        orderId: widget.orderId,
        status: 'processing',
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto berhasil diupload')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload gagal: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ambil Foto Laundry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5E60CE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(child: _image == null ? _emptyPreview() : _imagePreview()),

            const SizedBox(height: 20),

            if (_image == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _iconButton(
                    icon: Icons.photo,
                    label: 'Galeri',
                    onTap: _pickFromGallery,
                  ),
                  _iconButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: _pickFromCamera,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _image = null),
                      child: const Text('Ulangi'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadPhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E60CE),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:
                          _isUploading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Upload',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade100,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text('Belum ada foto', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(_image!, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF5E60CE),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
