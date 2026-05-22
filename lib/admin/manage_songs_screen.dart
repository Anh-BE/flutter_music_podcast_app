import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';
import '../models/models_music.dart';
import '../colors/app_colors.dart';

class ManageSongsScreen extends StatefulWidget {
  const ManageSongsScreen({super.key});

  @override
  State<ManageSongsScreen> createState() => _ManageSongsScreenState();
}

class _ManageSongsScreenState extends State<ManageSongsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // Hàm hiển thị hộp thoại xác nhận XÓA
  void _confirmDelete(BuildContext context, BaiHatModel song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        content: Text('Bạn có chắc chắn muốn xóa bài hát "${song.title}" không?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // Đóng hộp thoại
              try {
                await _supabaseService.deleteSong(song.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa bài hát thành công!'), backgroundColor: Colors.green),
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

  // Hàm hiển thị FORM Thêm hoặc Cập nhật
  void _showSongForm({BaiHatModel? song}) {
    showDialog(
      context: context,
      builder: (context) => SongFormDialog(song: song, supabaseService: _supabaseService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quản lý Bài hát', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: StreamBuilder<List<BaiHatModel>>(
          stream: _supabaseService.getSongsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
            }

            final songs = snapshot.data ?? [];
            
            if (songs.isEmpty) {
              return const Center(
                child: Text('Chưa có bài hát nào trong hệ thống.', style: TextStyle(color: Colors.white54, fontSize: 16)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        song.imageURl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                    title: Text(song.title, style: const TextStyle(color: Color.fromARGB(221, 247, 246, 246)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(song.artist, style: const TextStyle(color: Color.fromARGB(137, 245, 244, 244)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút Sửa
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                          onPressed: () => _showSongForm(song: song),
                        ),
                        // Nút Xóa
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, song),
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
      // Nút Thêm mới góc dưới màn hình
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showSongForm(), // Truyền null báo hiệu là Thêm mới
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ==============================================================
// COMPONENT FORM THÊM / CẬP NHẬT BÀI HÁT
// ==============================================================
class SongFormDialog extends StatefulWidget {
  final BaiHatModel? song;
  final SupabaseService supabaseService;

  const SongFormDialog({super.key, this.song, required this.supabaseService});

  @override
  State<SongFormDialog> createState() => _SongFormDialogState();
}

class _SongFormDialogState extends State<SongFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _imageUrlController;
  late TextEditingController _audioUrlController;
  late TextEditingController _durationController;
  late TextEditingController _albumIdController;
  
  PlatformFile? _imageFile;
  PlatformFile? _audioFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nếu có dữ liệu song truyền vào -> Form Cập nhật, ngược lại là Thêm mới
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _imageUrlController = TextEditingController(text: widget.song?.imageURl ?? '');
    _audioUrlController = TextEditingController(text: widget.song?.audioURL ?? '');
    _durationController = TextEditingController(text: widget.song != null ? widget.song!.duration.inSeconds.toString() : '');
    // Giả sử có album -> không có thì để trống
    _albumIdController = TextEditingController(text: ''); 
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _imageUrlController.dispose();
    _audioUrlController.dispose();
    _durationController.dispose();
    _albumIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      setState(() {
        _imageFile = result.files.single;
        _imageUrlController.text = _imageFile!.name; // Hiển thị tạm tên file lên màn hình
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.audio, withData: true);
    if (result != null) {
      setState(() {
        _audioFile = result.files.single;
        _audioUrlController.text = _audioFile!.name; // Hiển thị tạm tên file lên màn hình
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
      String audioUrl = _audioUrlController.text.trim();
      final duration = int.tryParse(_durationController.text.trim()) ?? 0;
      final albumId = int.tryParse(_albumIdController.text.trim()); // Có thể null

      // 1. Upload ảnh nếu có chọn file
      if (_imageFile != null) {
        final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
        // Thay 'music_files' bằng tên bucket mà bạn thiết lập trên Supabase Storage
        final uploadedUrl = await widget.supabaseService.uploadFileToStorage(
          'music_assets', fileName, 
          fileBytes: _imageFile!.bytes,
          file: _imageFile!.bytes == null && _imageFile!.path != null ? File(_imageFile!.path!) : null,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          throw Exception('Tải ảnh lên thất bại. Hãy kiểm tra lại Policy trên Supabase Storage.');
        }
      }

      // 2. Upload mp3 nếu có chọn file
      if (_audioFile != null) {
        final fileName = 'audio/${DateTime.now().millisecondsSinceEpoch}_${_audioFile!.name}';
        // Thay 'music_files' bằng tên bucket mà bạn thiết lập trên Supabase Storage
        final uploadedUrl = await widget.supabaseService.uploadFileToStorage(
          'music_assets', fileName, 
          fileBytes: _audioFile!.bytes,
          file: _audioFile!.bytes == null && _audioFile!.path != null ? File(_audioFile!.path!) : null,
        );
        if (uploadedUrl != null) {
          audioUrl = uploadedUrl;
        } else {
          throw Exception('Tải nhạc lên thất bại. Hãy kiểm tra lại Policy trên Supabase Storage.');
        }
      }

      if (widget.song == null) {
        // Thêm mới
        await widget.supabaseService.addSong(
          title: title,
          artist: artist,
          imageUrl: imageUrl,
          audioUrl: audioUrl,
          duration: duration,
          albumId: albumId,
        );
      } else {
        // Cập nhật
        await widget.supabaseService.updateSong(widget.song!.id, {
          'title': title,
          'artist': artist,
          'imageURl': imageUrl,
          'audioURL': audioUrl,
          'duration': duration,
          if (albumId != null) 'album_id': albumId, // Chỉ update album nếu có nhập
        });
      }

      if (mounted) {
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.song == null ? 'Thêm bài hát thành công!' : 'Cập nhật thành công!'), backgroundColor: Colors.green),
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
    final isEditing = widget.song != null;

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
              Text(isEditing ? 'Sửa Bài Hát' : 'Thêm Bài Hát Mới', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField(controller: _titleController, label: 'Tên bài hát', icon: Icons.music_note),
              _buildTextField(controller: _artistController, label: 'Ca sĩ', icon: Icons.person),
              _buildFilePickerField(controller: _imageUrlController, label: 'Link Ảnh (Hoặc Chọn File)', icon: Icons.image, onPick: _pickImage),
              _buildFilePickerField(controller: _audioUrlController, label: 'Link Nhạc (Hoặc Chọn File)', icon: Icons.link, onPick: _pickAudio),
              _buildTextField(controller: _durationController, label: 'Thời lượng (Tính bằng Giây)', icon: Icons.timer, isNumber: true),
              _buildTextField(controller: _albumIdController, label: 'ID Album (Tùy chọn)', icon: Icons.album, isNumber: true, isRequired: false),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditing ? 'Lưu Thay Đổi' : 'Thêm Bài Hát', style: const TextStyle(color: Colors.white, fontSize: 16)),
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
            height: 55, // Cân đối độ cao nút với TextField
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