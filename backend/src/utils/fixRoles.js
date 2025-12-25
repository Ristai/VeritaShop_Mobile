require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');

const fixRoles = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB Connected');

    // Cập nhật tất cả user chưa có role thành 'customer'
    const updateResult = await User.updateMany(
      { role: { $exists: false } },
      { $set: { role: 'customer' } }
    );
    console.log(`Updated ${updateResult.modifiedCount} users with role='customer'`);

    // Kiểm tra và tạo admin user nếu chưa có
    const existingAdmin = await User.findOne({ email: 'admin@veritashop.com' });
    if (!existingAdmin) {
      await User.create({
        name: 'Admin VeritaShop',
        email: 'admin@veritashop.com',
        password: 'Admin@123',
        role: 'admin',
        isActive: true
      });
      console.log('Created admin user: admin@veritashop.com / Admin@123');
    } else {
      // Đảm bảo admin có role đúng
      if (existingAdmin.role !== 'admin') {
        existingAdmin.role = 'admin';
        await existingAdmin.save();
        console.log('Updated existing admin user role to admin');
      } else {
        console.log('Admin user already exists with correct role');
      }
    }

    // Hiển thị danh sách users
    const users = await User.find().select('name email role isActive');
    console.log('\nAll users:');
    users.forEach(u => console.log(`  ${u.email} - role: ${u.role}, active: ${u.isActive}`));

    await mongoose.connection.close();
    console.log('\nDone!');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
};

fixRoles();
