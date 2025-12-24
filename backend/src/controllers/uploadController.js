const cloudinary = require('../config/cloudinary');
const User = require('../models/User');
const { successResponse, errorResponse } = require('../utils/response');

// @desc    Upload single image to Cloudinary
// @route   POST /api/upload/image
const uploadImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return errorResponse(res, 'Vui lòng chọn ảnh để upload', 400, 'NO_FILE');
    }

    // Upload to Cloudinary
    const result = await new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: 'veritashop/images',
          resource_type: 'image',
          transformation: [
            { width: 1200, height: 1200, crop: 'limit' },
            { quality: 'auto' },
            { fetch_format: 'auto' },
          ],
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      uploadStream.end(req.file.buffer);
    });

    return successResponse(res, {
      url: result.secure_url,
      publicId: result.public_id,
      width: result.width,
      height: result.height,
      format: result.format,
      size: result.bytes,
    }, 'Upload ảnh thành công');
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    return errorResponse(res, 'Lỗi upload ảnh', 500, 'UPLOAD_ERROR');
  }
};

// @desc    Upload multiple images to Cloudinary
// @route   POST /api/upload/images
const uploadImages = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return errorResponse(res, 'Vui lòng chọn ảnh để upload', 400, 'NO_FILES');
    }

    const uploadPromises = req.files.map(file => {
      return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder: 'veritashop/images',
            resource_type: 'image',
            transformation: [
              { width: 1200, height: 1200, crop: 'limit' },
              { quality: 'auto' },
              { fetch_format: 'auto' },
            ],
          },
          (error, result) => {
            if (error) reject(error);
            else resolve({
              url: result.secure_url,
              publicId: result.public_id,
              width: result.width,
              height: result.height,
            });
          }
        );
        uploadStream.end(file.buffer);
      });
    });

    const results = await Promise.all(uploadPromises);

    return successResponse(res, {
      images: results,
      count: results.length,
    }, `Upload ${results.length} ảnh thành công`);
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    return errorResponse(res, 'Lỗi upload ảnh', 500, 'UPLOAD_ERROR');
  }
};

// @desc    Upload user avatar
// @route   POST /api/upload/avatar
const uploadAvatar = async (req, res, next) => {
  try {
    if (!req.file) {
      return errorResponse(res, 'Vui lòng chọn ảnh đại diện', 400, 'NO_FILE');
    }

    // Upload to Cloudinary with avatar-specific settings
    const result = await new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: 'veritashop/avatars',
          resource_type: 'image',
          transformation: [
            { width: 300, height: 300, crop: 'fill', gravity: 'face' },
            { quality: 'auto' },
            { fetch_format: 'auto' },
          ],
          public_id: `avatar_${req.user._id}`,
          overwrite: true,
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      uploadStream.end(req.file.buffer);
    });

    // Update user avatar in database
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { avatar: result.secure_url },
      { new: true }
    );

    return successResponse(res, {
      avatar: result.secure_url,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
      },
    }, 'Cập nhật ảnh đại diện thành công');
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    return errorResponse(res, 'Lỗi upload ảnh', 500, 'UPLOAD_ERROR');
  }
};

// @desc    Delete image from Cloudinary
// @route   DELETE /api/upload/image/:publicId
const deleteImage = async (req, res, next) => {
  try {
    const { publicId } = req.params;

    if (!publicId) {
      return errorResponse(res, 'Public ID không được cung cấp', 400, 'MISSING_PUBLIC_ID');
    }

    // Decode the publicId (it might be URL encoded)
    const decodedPublicId = decodeURIComponent(publicId);

    const result = await cloudinary.uploader.destroy(decodedPublicId);

    if (result.result === 'ok') {
      return successResponse(res, null, 'Xóa ảnh thành công');
    } else {
      return errorResponse(res, 'Không thể xóa ảnh', 400, 'DELETE_FAILED');
    }
  } catch (error) {
    console.error('Cloudinary delete error:', error);
    return errorResponse(res, 'Lỗi xóa ảnh', 500, 'DELETE_ERROR');
  }
};

module.exports = {
  uploadImage,
  uploadImages,
  uploadAvatar,
  deleteImage,
};
