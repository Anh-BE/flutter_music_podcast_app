import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';
import '../models/models_music.dart';
import '../colors/app_colors.dart';

class ManagePodcardsScreen extends StatefulWidget {
  const ManagePodcardsScreen({super.key});

  @override
  State<ManagePodcardsScreen> createState() => _ManagePodcardsScreenState();
}

class _ManagePodcardsScreenState extends State<ManagePodcardsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  void _confirmDelete(BuildContext context, PodCardModel podcast) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        content: Text('Bạn có chắc chắn muốn xóa podcast "${podcast.title}" không?', style: const TextStyle(color: Colors.white70)),
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
                await _supabaseService.deletePodcard(podcast.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa podcast thành công!'), backgroundColor: Colors.green),
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

  void _showPodcastForm({PodCardModel? podcast}) {
    showDialog(
      context: context,
      builder: (context) => PodcastFormDialog(podcast: podcast, supabaseService: _supabaseService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý Podcard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: StreamBuilder<List<PodCardModel>>(
          stream: _supabaseService.getPodcardStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
            }

            final podcasts = snapshot.data ?? [];
            
            if (podcasts.isEmpty) {
              return const Center(
                child: Text('Chưa có podcast nào trong hệ thống.', style: TextStyle(color: Colors.white54, fontSize: 16)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: podcasts.length,
              itemBuilder: (context, index) {
                final podcast = podcasts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        podcast.imagePodcardUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.podcasts, color: Colors.white),
                      ),
                    ),
                    title: Text(podcast.title, style: const TextStyle(color: Color.fromARGB(221, 247, 246, 246)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(podcast.author, style: const TextStyle(color: Color.fromARGB(137, 245, 244, 244)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                          onPressed: () => _showPodcastForm(podcast: podcast),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, podcast),
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
        onPressed: () => _showPodcastForm(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class PodcastFormDialog extends StatefulWidget {
  final PodCardModel? podcast;
  final SupabaseService supabaseService;

  const PodcastFormDialog({super.key, this.podcast, required this.supabaseService});

  @override
  State<PodcastFormDialog> createState() => _PodcastFormDialogState();
}

class _PodcastFormDialogState extends State<PodcastFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _imageUrlController;
  late TextEditingController _audioUrlController;
  late TextEditingController _durationController;
  
  PlatformFile? _imageFile;
  PlatformFile? _audioFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.podcast?.title ?? '');
    _authorController = TextEditingController(text: widget.podcast?.author ?? '');
    _imageUrlController = TextEditingController(text: widget.podcast?.imagePodcardUrl ?? '');
    _audioUrlController = TextEditingController(text: widget.podcast?.linkPodcardUrl ?? '');
    _durationController = TextEditingController(text: widget.podcast != null ? widget.podcast!.duration.toString() : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _audioUrlController.dispose();
    _durationController.dispose();
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

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.audio, withData: true);
    if (result != null) {
      setState(() {
        _audioFile = result.files.single;
        _audioUrlController.text = _audioFile!.name;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final author = _authorController.text.trim();
      String imageUrl = _imageUrlController.text.trim();
      String audioUrl = _audioUrlController.text.trim();
      final duration = int.tryParse(_durationController.text.trim()) ?? 0;

      if (_imageFile != null) {
        final fileName = 'images/pod_${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
        final uploadedUrl = await widget.supabaseService.uploadFileToStorage(
          'music_assets', fileName, 
          fileBytes: _imageFile!.bytes,
          file: _imageFile!.bytes == null && _imageFile!.path != null ? File(_imageFile!.path!) : null,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          throw Exception('Tải ảnh lên thất bại.');
        }
      }

      if (_audioFile != null) {
        final fileName = 'audio/pod_${DateTime.now().millisecondsSinceEpoch}_${_audioFile!.name}';
        final uploadedUrl = await widget.supabaseService.uploadFileToStorage(
          'music_assets', fileName, 
          fileBytes: _audioFile!.bytes,
          file: _audioFile!.bytes == null && _audioFile!.path != null ? File(_audioFile!.path!) : null,
        );
        if (uploadedUrl != null) {
          audioUrl = uploadedUrl;
        } else {
          throw Exception('Tải file podcast lên thất bại.');
        }
      }

      if (widget.podcast == null) {
        await widget.supabaseService.addPodcard(
          title: title,
          author: author,
          imagePodcardUrl: imageUrl,
          linkPodcardUrl: audioUrl,
          duration: duration,
        );
      } else {
        await widget.supabaseService.updatePodcard(widget.podcast!.id, {
          'title': title,
          'author': author,
          'image_podcard_URL': imageUrl,
          'link_podcard_URL': audioUrl,
          'duration': duration,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.podcast == null ? 'Thêm podcast thành công!' : 'Cập nhật thành công!'), backgroundColor: Colors.green),
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
    final isEditing = widget.podcast != null;

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
              Text(isEditing ? 'Sửa Podcast' : 'Thêm Podcast Mới', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField(controller: _titleController, label: 'Tên Podcast', icon: Icons.podcasts),
              _buildTextField(controller: _authorController, label: 'Tác giả', icon: Icons.person),
              _buildFilePickerField(controller: _imageUrlController, label: 'Link Ảnh (Hoặc Chọn File)', icon: Icons.image, onPick: _pickImage),
              _buildFilePickerField(controller: _audioUrlController, label: 'Link Audio (Hoặc Chọn File)', icon: Icons.link, onPick: _pickAudio),
              _buildTextField(controller: _durationController, label: 'Thời lượng (Tính bằng Giây)', icon: Icons.timer, isNumber: true),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditing ? 'Lưu Thay Đổi' : 'Thêm Podcast', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isNumber = false, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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