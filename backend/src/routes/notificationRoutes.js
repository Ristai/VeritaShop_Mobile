const express = require('express');
const router = express.Router();
const {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  createNotificationAPI,
} = require('../controllers/notificationController');
const { auth } = require('../middleware/auth');
const { adminAuth } = require('../middleware/adminAuth');

// All notification routes require authentication
router.use(auth);

// User routes
router.get('/', getNotifications);
router.patch('/read-all', markAllAsRead);
router.patch('/:id', markAsRead);
router.delete('/:id', deleteNotification);

// Admin route to create notifications
router.post('/', adminAuth, createNotificationAPI);

module.exports = router;
