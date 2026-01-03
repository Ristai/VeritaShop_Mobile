import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_service.dart';
import '../../data/repositories/review_repository.dart';
import '../widgets/custom_button.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ReviewRepository _reviewRepository = ReviewRepository();
  final ImagePicker _imagePicker = ImagePicker();
  int _rating = 5;
  bool _isSubmitting = false;
  String _submitStatusText = '';

  // Image state
  final List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _imageBytes = {}; // Cache for web preview
  static const int _maxImages = 5;

  @override
  void dispose() {
    _reviewController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showImageSourcePicker() {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: colors.primaryText),
                title: Text('Chọn từ thư viện', style: TextStyle(color: colors.primaryText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primaryText),
                title: Text('Chụp ảnh', style: TextStyle(color: colors.primaryText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1200,
          maxHeight: 1200,
        );
        if (images.isNotEmpty) {
          final remainingSlots = _maxImages - _selectedImages.length;
          final imagesToAdd = images.take(remainingSlots).toList();
          // Load bytes for preview on web
          for (final img in imagesToAdd) {
            _imageBytes[img.path] = await img.readAsBytes();
          }
          setState(() {
            _selectedImages.addAll(imagesToAdd);
          });
          if (images.length > remainingSlots && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chỉ thêm được $remainingSlots ảnh. Đã đạt giới hạn $_maxImages ảnh.'),
                backgroundColor: kYellowColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        final image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1200,
          maxHeight: 1200,
        );
        if (image != null) {
          // Load bytes for preview on web
          _imageBytes[image.path] = await image.readAsBytes();
          setState(() {
            _selectedImages.add(image);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: ${e.toString()}'),
            backgroundColor: kRedColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    final path = _selectedImages[index].path;
    setState(() {
      _selectedImages.removeAt(index);
      _imageBytes.remove(path);
    });
  }

  Future<List<String>?> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    try {
      final imageDataList = <Map<String, dynamic>>[];
      for (final image in _selectedImages) {
        // Use cached bytes if available, otherwise read from file
        final bytes = _imageBytes[image.path] ?? await image.readAsBytes();
        imageDataList.add({
          'bytes': bytes,
          'filename': image.name,
        });
      }

      final response = await ApiService.instance.uploadImages(imageDataList);
      if (response['success'] == true && response['data'] != null) {
        final images = response['data']['images'] as List;
        return images.map((img) => img['url'] as String).toList();
      }
      return null;
    } catch (e) {
      print('Upload images error: $e');
      return null;
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          backgroundColor: kRedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitStatusText = _selectedImages.isNotEmpty ? 'Đang tải ảnh lên...' : 'Đang gửi đánh giá...';
    });

    try {
      // Upload images first if any
      List<String>? imageUrls;
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages();
        if (imageUrls == null) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
              _submitStatusText = '';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể tải ảnh lên. Vui lòng thử lại.'),
                backgroundColor: kRedColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
        if (mounted) {
          setState(() {
            _submitStatusText = 'Đang gửi đánh giá...';
          });
        }
      }

      final review = await _reviewRepository.createReview(
        productId: widget.productId,
        rating: _rating,
        text: _reviewController.text.trim(),
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        images: imageUrls,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitStatusText = '';
        });

        if (review != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi đánh giá thành công!'),
              backgroundColor: kGreenColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, review);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể gửi đánh giá. Vui lòng thử lại.'),
              backgroundColor: kRedColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitStatusText = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: kRedColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text('Viết đánh giá', style: TextStyle(color: colors.primaryText)),
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductInfo(colors),
            const SizedBox(height: 24),
            _buildRatingSection(colors),
            const SizedBox(height: 24),
            _buildTitleInput(colors),
            const SizedBox(height: 24),
            _buildReviewInput(colors),
            const SizedBox(height: 24),
            _buildImageSection(colors),
            const SizedBox(height: 32),
            if (_isSubmitting && _submitStatusText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: Text(
                    _submitStatusText,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ),
              ),
            CustomButton(
              text: _isSubmitting ? _submitStatusText : 'Gửi đánh giá',
              onPressed: _isSubmitting ? null : _submitReview,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: colors.border,
                child: Icon(Icons.image, color: colors.secondaryText),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Đánh giá sản phẩm này',
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá của bạn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: kYellowColor,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(),
            style: TextStyle(
              color: _getRatingColor(),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Tuyệt vời';
      default:
        return '';
    }
  }

  Color _getRatingColor() {
    if (_rating <= 2) return kRedColor;
    if (_rating == 3) return kYellowColor;
    return kGreenColor;
  }

  Widget _buildTitleInput(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiêu đề (tùy chọn)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: _titleController,
            maxLength: 100,
            style: TextStyle(color: colors.primaryText),
            decoration: InputDecoration(
              hintText: 'Tiêu đề đánh giá...',
              hintStyle: TextStyle(color: colors.secondaryText),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: colors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewInput(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nội dung đánh giá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 5,
            maxLength: 500,
            style: TextStyle(color: colors.primaryText),
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm này...',
              hintStyle: TextStyle(color: colors.secondaryText),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: colors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(AppColors colors) {
    final bool canAddMore = _selectedImages.length < _maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thêm hình ảnh (tùy chọn)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.primaryText,
              ),
            ),
            Text(
              '${_selectedImages.length}/$_maxImages',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              if (canAddMore)
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: kAccentColor, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          'Thêm ảnh',
                          style: TextStyle(
                            color: kAccentColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Selected images
              ...List.generate(_selectedImages.length, (index) {
                final imagePath = _selectedImages[index].path;
                final bytes = _imageBytes[imagePath];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: bytes != null
                            ? Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: colors.card,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        if (!canAddMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Đã đạt giới hạn $_maxImages ảnh',
              style: TextStyle(
                color: kYellowColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
