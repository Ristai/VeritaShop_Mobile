const Notification = require('../models/Notification');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

// @desc    Get user's notifications
// @route   GET /api/notifications
const getNotifications = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, type } = req.query;

    const query = { user: req.user._id };
    if (type && ['order', 'promo', 'system'].includes(type)) {
      query.type = type;
    }

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const [notifications, total, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Notification.countDocuments(query),
      Notification.countDocuments({ user: req.user._id, isRead: false }),
    ]);

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, {
      notifications,
      unreadCount,
    }, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Mark notification as read
// @route   PATCH /api/notifications/:id
const markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return errorResponse(res, 'Không tìm thấy thông báo', 404, 'NOTIFICATION_NOT_FOUND');
    }

    return successResponse(res, notification, 'Đã đánh dấu đã đọc');
  } catch (error) {
    next(error);
  }
};

// @desc    Mark all notifications as read
// @route   PATCH /api/notifications/read-all
const markAllAsRead = async (req, res, next) => {
  try {
    const result = await Notification.updateMany(
      { user: req.user._id, isRead: false },
      { isRead: true }
    );

    return successResponse(res, {
      modifiedCount: result.modifiedCount,
    }, 'Đã đánh dấu tất cả đã đọc');
  } catch (error) {
    next(error);
  }
};

// @desc    Delete notification
// @route   DELETE /api/notifications/:id
const deleteNotification = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!notification) {
      return errorResponse(res, 'Không tìm thấy thông báo', 404, 'NOTIFICATION_NOT_FOUND');
    }

    return successResponse(res, null, 'Đã xóa thông báo');
  } catch (error) {
    next(error);
  }
};

// @desc    Create notification (internal use)
// Helper function to be used by other controllers
const createNotification = async ({ userId, type, title, message, data = null }) => {
  try {
    const notification = await Notification.create({
      user: userId,
      type,
      title,
      message,
      data,
    });
    return notification;
  } catch (error) {
    console.error('Failed to create notification:', error);
    return null;
  }
};

// @desc    Create notification via API (admin only)
// @route   POST /api/notifications
const createNotificationAPI = async (req, res, next) => {
  try {
    const { userId, type, title, message, data } = req.body;

    if (!userId || !type || !title || !message) {
      return errorResponse(res, 'Thiếu thông tin bắt buộc', 400, 'MISSING_FIELDS');
    }

    if (!['order', 'promo', 'system'].includes(type)) {
      return errorResponse(res, 'Loại thông báo không hợp lệ', 400, 'INVALID_TYPE');
    }

    const notification = await Notification.create({
      user: userId,
      type,
      title,
      message,
      data,
    });

    return successResponse(res, notification, 'Đã tạo thông báo', 201);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  createNotification,
  createNotificationAPI,
};
