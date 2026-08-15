import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageString;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final IconData? fallbackIcon;

  const ProfileAvatar({
    super.key,
    this.imageString,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fallbackIcon,
  });

  static ImageProvider? getImageProvider(String? picture) {
    if (picture == null || picture.trim().isEmpty) return null;
    final trimmed = picture.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        final base64Str =
            commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
        final bytes = base64Decode(base64Str);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    // Attempt decoding if it looks like raw base64
    if (trimmed.length > 50 &&
        !trimmed.contains(' ') &&
        !trimmed.contains('\n')) {
      try {
        final bytes = base64Decode(trimmed);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = getImageProvider(imageString);
    final effectiveBgColor =
        backgroundColor ?? AppTheme.primaryDark.withValues(alpha: 0.1);
    final effectiveTextColor = textColor ?? AppTheme.primaryDark;

    String initial = '';
    if (name != null && name!.trim().isNotEmpty) {
      initial = name!.trim()[0].toUpperCase();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBgColor,
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null ? (_, _) {} : null,
      child: imageProvider == null
          ? (initial.isNotEmpty
              ? Text(
                  initial,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize ?? (radius * 0.8),
                  ),
                )
              : Icon(
                  fallbackIcon ?? Icons.person,
                  color: effectiveTextColor,
                  size: radius * 1.1,
                ))
          : null,
    );
  }
}

class ProfileImagePicker extends StatefulWidget {
  final String? initialImage;
  final String? name;
  final double radius;
  final ValueChanged<String?> onImageChanged;

  const ProfileImagePicker({
    super.key,
    this.initialImage,
    this.name,
    this.radius = 44,
    required this.onImageChanged,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  String? _currentImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialImage;
  }

  @override
  void didUpdateWidget(covariant ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImage != widget.initialImage) {
      setState(() {
        _currentImage = widget.initialImage;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        final String base64String =
            'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _currentImage = base64String;
        });
        widget.onImageChanged(base64String);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture or pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _showUrlInputDialog() async {
    final textController = TextEditingController(
      text: (_currentImage != null && _currentImage!.startsWith('http'))
          ? _currentImage
          : '',
    );

    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/avatar.jpg',
            labelText: 'Image URL',
            isDense: true,
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(textController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() {
        _currentImage = url;
      });
      widget.onImageChanged(url);
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final hasImage =
            _currentImage != null && _currentImage!.trim().isNotEmpty;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Capture a new photo right now',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  title: const Text(
                    'Upload from Gallery / Files',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Select an image file from your device',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  title: const Text(
                    'Enter Web Image URL',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Paste a direct link to an image',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showUrlInputDialog();
                  },
                ),
                if (hasImage) ...[
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _currentImage = null;
                      });
                      widget.onImageChanged('');
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              ProfileAvatar(
                imageString: _currentImage,
                name: widget.name,
                radius: widget.radius,
                fontSize: widget.radius * 0.75,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: AppTheme.primaryDark,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _showImageSourceModal,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: _showImageSourceModal,
          icon: const Icon(Icons.cloud_upload_outlined, size: 16),
          label: Text(
            (_currentImage != null && _currentImage!.trim().isNotEmpty)
                ? 'Change Profile Photo'
                : 'Upload / Capture Photo',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryDark,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
