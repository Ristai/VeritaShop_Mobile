const express = require('express');
const router = express.Router();
const multer = require('multer');
const {
  uploadImage,
  uploadImages,
  uploadAvatar,
  deleteImage,
} = require('../controllers/uploadController');
const { auth } = require('../middleware/auth');

// Configure multer for memory storage
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  // Accept images only
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Chỉ chấp nhận file ảnh (jpg, png, gif, webp)'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max
  },
});

// Error handler for multer
const handleMulterError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'FILE_TOO_LARGE',
          message: 'File quá lớn. Tối đa 5MB',
        },
      });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'TOO_MANY_FILES',
          message: 'Quá nhiều file. Tối đa 5 file',
        },
      });
    }
    return res.status(400).json({
      success: false,
      error: {
        code: 'UPLOAD_ERROR',
        message: err.message,
      },
    });
  }
  
  if (err.message.includes('file ảnh')) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'INVALID_FILE_TYPE',
        message: err.message,
      },
    });
  }
  
  next(err);
};

// All upload routes require authentication
router.use(auth);

// Single image upload
router.post('/image', upload.single('image'), handleMulterError, uploadImage);

// Multiple images upload (max 5)
router.post('/images', upload.array('images', 5), handleMulterError, uploadImages);

// Avatar upload
router.post('/avatar', upload.single('avatar'), handleMulterError, uploadAvatar);

// Delete image
router.delete('/image/:publicId(*)', deleteImage);

module.exports = router;
