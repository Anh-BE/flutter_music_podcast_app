import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';
import '../models/models_music.dart';
import '../colors/app_colors.dart';

class ManageAlbumsScreen extends StatefulWidget {
  const ManageAlbumsScreen({super.key});

  @override
  State<ManageAlbumsScreen> createState() => _ManageAlbumsScreenState();
}

class _ManageAlbumsScreenState extends State<ManageAlbumsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  void _confirmDelete(BuildContext context, AlbumModel album) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        content: Text('Bạn có chắc chắn muốn xóa album "${album.title}" không?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _supabaseService.deleteAlbum(album.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa album thành công!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAlbumForm({AlbumModel? album}) {
    showDialog(
      context: context,
      builder: (context) => AlbumFormDialog(album: album, supabaseService: _supabaseService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý Album', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
          ),
        ),
        child: StreamBuilder<List<AlbumModel>>(
          stream: _supabaseService.getAlbumsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
            }

            final albums = snapshot.data ?? [];
            
            if (albums.isEmpty) {
              return const Center(
                child: Text('Chưa có album nào trong hệ thống.', style: TextStyle(color: Colors.white54, fontSize: 16)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        album.imageUrlAlbum,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.album, color: Colors.white),
                      ),
                    ),
                    title: Text(album.title, style: const TextStyle(color: Color.fromARGB(221, 247, 246, 246)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Ca sĩ: ${album.artistAlbum} (ID: ${album.id})', style: const TextStyle(color: Color.fromARGB(137, 245, 244, 244)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                          onPressed: () => _showAlbumForm(album: album),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, album),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAlbumForm(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class AlbumFormDialog extends StatefulWidget {
  final AlbumModel? album;
  final SupabaseService supabaseService;

  const AlbumFormDialog({super.key, this.album, required this.supabaseService});

  @override
  State<AlbumFormDialog> createState() => _AlbumFormDialogState();
}

class _AlbumFormDialogState extends State<AlbumFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _imageUrlController;
  
  PlatformFile? _imageFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.album?.title ?? '');
    _artistController = TextEditingController(text: widget.album?.artistAlbum ?? '');
    _imageUrlController = TextEditingController(text: widget.album?.imageUrlAlbum ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      setState(() {
        _imageFile = result.files.single;
        _imageUrlController.text = _imageFile!.name;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final artist = _artistController.text.trim();
      String imageUrl = _imageUrlController.text.trim();

      if (_imageFile != null) {
        final fileName = 'images/album_${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
        final uploadedUrl = await widget.supabaseService.uploadFileToStorage(
          'music_assets', fileName, 
          fileBytes: _imageFile!.bytes,
          file: _imageFile!.bytes == null && _imageFile!.path != null ? File(_imageFile!.path!) : null,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          throw Exception('Tải ảnh lên thất bại. Hãy kiểm tra lại cấu hình Supabase Storage.');
        }
      }

      if (widget.album == null) {
        await widget.supabaseService.addAlbum(
          title: title,
          artistAlbum: artist,
          imageUrlAlbum: imageUrl,
        );
      } else {
        await widget.supabaseService.updateAlbum(widget.album!.id, {
          'title': title,
          'artist_album': artist,
          'imageURl_album': imageUrl,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.album == null ? 'Thêm Album thành công!' : 'Cập nhật thành công!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.album != null;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditing ? 'Sửa Album' : 'Thêm Album Mới', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField(controller: _titleController, label: 'Tên Album', icon: Icons.album),
              _buildTextField(controller: _artistController, label: 'Tên Ca sĩ/Nghệ sĩ', icon: Icons.person),
              _buildFilePickerField(controller: _imageUrlController, label: 'Link Ảnh (Hoặc Chọn File)', icon: Icons.image, onPick: _pickImage),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditing ? 'Lưu Thay Đổi' : 'Thêm Album', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        validator: isRequired ? (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập thông tin này' : null : null,
      ),
    );
  }

  Widget _buildFilePickerField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onPick,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTextField(
              controller: controller,
              label: label,
              icon: icon,
              isRequired: true,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(icon: const Icon(Icons.upload_file, color: Colors.white), onPressed: onPick),
          ),
        ],
      ),
    );
  }
}