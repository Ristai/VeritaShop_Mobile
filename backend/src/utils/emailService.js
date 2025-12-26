const nodemailer = require('nodemailer');

// Create transporter
const createTransporter = () => {
  // For production, use actual SMTP settings
  if (process.env.NODE_ENV === 'production') {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });
  }
  
  // For development, use ethereal email (fake SMTP)
  return nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    auth: {
      user: process.env.ETHEREAL_USER || 'test@ethereal.email',
      pass: process.env.ETHEREAL_PASS || 'testpass',
    },
  });
};

// Format price to Vietnamese currency
const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(price);
};

// Format date to Vietnamese format
const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

// Generate order confirmation email HTML
const generateOrderConfirmationHTML = (order, user) => {
  const itemsHTML = order.items.map(item => `
    <tr>
      <td style="padding: 12px; border-bottom: 1px solid #eee;">
        <div style="display: flex; align-items: center;">
          <img src="${item.image}" alt="${item.name}" style="width: 60px; height: 60px; object-fit: cover; border-radius: 8px; margin-right: 12px;">
          <div>
            <strong>${item.name}</strong><br>
            <span style="color: #666; font-size: 13px;">Màu: ${item.color?.name || 'N/A'}</span>
          </div>
        </div>
      </td>
      <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: center;">${item.quantity}</td>
      <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;">${formatPrice(item.price)}</td>
      <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right; font-weight: bold;">${formatPrice(item.price * item.quantity)}</td>
    </tr>
  `).join('');

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Xác nhận đơn hàng - VeritaShop</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff;">
    <!-- Header -->
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
      <h1 style="color: #ffffff; margin: 0; font-size: 28px;">🛍️ VeritaShop</h1>
      <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0;">Đặt hàng thành công!</p>
    </div>

    <!-- Content -->
    <div style="padding: 30px;">
      <!-- Greeting -->
      <p style="font-size: 16px; color: #333;">Xin chào <strong>${user.name}</strong>,</p>
      <p style="color: #666; line-height: 1.6;">
        Cảm ơn bạn đã đặt hàng tại VeritaShop! Đơn hàng của bạn đã được tiếp nhận và đang được xử lý.
      </p>

      <!-- Order Info Box -->
      <div style="background-color: #f8f9fa; border-radius: 12px; padding: 20px; margin: 20px 0;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px;">
          <div>
            <p style="margin: 0; color: #666; font-size: 13px;">Mã đơn hàng</p>
            <p style="margin: 5px 0 0 0; font-size: 18px; font-weight: bold; color: #667eea;">#${order.orderNumber}</p>
          </div>
          <div style="text-align: right;">
            <p style="margin: 0; color: #666; font-size: 13px;">Ngày đặt</p>
            <p style="margin: 5px 0 0 0; font-size: 14px; color: #333;">${formatDate(order.createdAt)}</p>
          </div>
        </div>
        <div style="border-top: 1px dashed #ddd; padding-top: 15px;">
          <p style="margin: 0; color: #666; font-size: 13px;">Trạng thái</p>
          <span style="display: inline-block; background-color: #fff3cd; color: #856404; padding: 4px 12px; border-radius: 20px; font-size: 13px; margin-top: 5px;">
            ⏳ ${order.statusText || 'Chờ xác nhận'}
          </span>
        </div>
      </div>

      <!-- Shipping Address -->
      <div style="margin: 25px 0;">
        <h3 style="color: #333; margin-bottom: 10px; font-size: 16px;">📍 Địa chỉ giao hàng</h3>
        <div style="background-color: #f8f9fa; border-radius: 8px; padding: 15px;">
          <p style="margin: 0; font-weight: bold;">${order.shippingAddress.fullName}</p>
          <p style="margin: 5px 0 0 0; color: #666;">${order.shippingAddress.phone}</p>
          <p style="margin: 5px 0 0 0; color: #666;">
            ${order.shippingAddress.streetAddress}, ${order.shippingAddress.ward}, 
            ${order.shippingAddress.district}, ${order.shippingAddress.province}
          </p>
        </div>
      </div>

      <!-- Order Items -->
      <div style="margin: 25px 0;">
        <h3 style="color: #333; margin-bottom: 15px; font-size: 16px;">📦 Chi tiết đơn hàng</h3>
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="padding: 12px; text-align: left; font-weight: 600; color: #666;">Sản phẩm</th>
              <th style="padding: 12px; text-align: center; font-weight: 600; color: #666;">SL</th>
              <th style="padding: 12px; text-align: right; font-weight: 600; color: #666;">Đơn giá</th>
              <th style="padding: 12px; text-align: right; font-weight: 600; color: #666;">Thành tiền</th>
            </tr>
          </thead>
          <tbody>
            ${itemsHTML}
          </tbody>
        </table>
      </div>

      <!-- Order Summary -->
      <div style="background-color: #f8f9fa; border-radius: 12px; padding: 20px; margin: 25px 0;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
          <span style="color: #666;">Tạm tính</span>
          <span>${formatPrice(order.subtotal)}</span>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
          <span style="color: #666;">Phí vận chuyển</span>
          <span>${order.shippingFee === 0 ? 'Miễn phí' : formatPrice(order.shippingFee)}</span>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
          <span style="color: #666;">Thuế (10%)</span>
          <span>${formatPrice(order.tax)}</span>
        </div>
        ${order.discount ? `
        <div style="display: flex; justify-content: space-between; margin-bottom: 10px; color: #28a745;">
          <span>Giảm giá</span>
          <span>-${formatPrice(order.discount)}</span>
        </div>
        ` : ''}
        <div style="border-top: 2px solid #ddd; padding-top: 15px; margin-top: 10px; display: flex; justify-content: space-between;">
          <span style="font-size: 18px; font-weight: bold;">Tổng cộng</span>
          <span style="font-size: 20px; font-weight: bold; color: #667eea;">${formatPrice(order.total)}</span>
        </div>
      </div>

      <!-- Payment Method -->
      <div style="margin: 25px 0;">
        <h3 style="color: #333; margin-bottom: 10px; font-size: 16px;">💳 Phương thức thanh toán</h3>
        <p style="margin: 0; padding: 15px; background-color: #f8f9fa; border-radius: 8px;">
          ${order.paymentMethod === 'COD' ? '💵 Thanh toán khi nhận hàng (COD)' : order.paymentMethod}
        </p>
      </div>

      ${order.note ? `
      <!-- Note -->
      <div style="margin: 25px 0;">
        <h3 style="color: #333; margin-bottom: 10px; font-size: 16px;">📝 Ghi chú</h3>
        <p style="margin: 0; padding: 15px; background-color: #fff3cd; border-radius: 8px; color: #856404;">
          ${order.note}
        </p>
      </div>
      ` : ''}

      <!-- CTA -->
      <div style="text-align: center; margin: 30px 0;">
        <a href="${process.env.APP_URL || 'https://veritashop.vn'}/orders/${order._id}" 
           style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; padding: 14px 30px; border-radius: 8px; text-decoration: none; font-weight: bold;">
          Xem chi tiết đơn hàng
        </a>
      </div>

      <!-- Help -->
      <div style="border-top: 1px solid #eee; padding-top: 20px; margin-top: 30px;">
        <p style="color: #666; font-size: 14px; text-align: center;">
          Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi qua:<br>
          📧 Email: support@veritashop.vn | 📞 Hotline: 1900 xxxx
        </p>
      </div>
    </div>

    <!-- Footer -->
    <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
      <p style="margin: 0; color: #999; font-size: 12px;">
        © 2024 VeritaShop. All rights reserved.<br>
        Bạn nhận được email này vì đã đặt hàng tại VeritaShop.
      </p>
    </div>
  </div>
</body>
</html>
  `;
};

// Send order confirmation email
const sendOrderConfirmationEmail = async (order, user) => {
  try {
    const transporter = createTransporter();
    
    const mailOptions = {
      from: `"VeritaShop" <${process.env.SMTP_FROM || 'noreply@veritashop.vn'}>`,
      to: user.email,
      subject: `✅ Xác nhận đơn hàng #${order.orderNumber} - VeritaShop`,
      html: generateOrderConfirmationHTML(order, user),
    };

    const info = await transporter.sendMail(mailOptions);
    
    console.log(`Order confirmation email sent to ${user.email}: ${info.messageId}`);
    
    // For development, log preview URL
    if (process.env.NODE_ENV !== 'production') {
      console.log(`Preview URL: ${nodemailer.getTestMessageUrl(info)}`);
    }
    
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Error sending order confirmation email:', error);
    return { success: false, error: error.message };
  }
};

// Send order status update email
const sendOrderStatusUpdateEmail = async (order, user, newStatus) => {
  try {
    const transporter = createTransporter();
    
    const statusMessages = {
      confirmed: { emoji: '✅', text: 'Đã xác nhận', color: '#28a745' },
      processing: { emoji: '🔄', text: 'Đang xử lý', color: '#17a2b8' },
      shipping: { emoji: '🚚', text: 'Đang giao hàng', color: '#fd7e14' },
      delivered: { emoji: '📦', text: 'Đã giao hàng', color: '#28a745' },
      cancelled: { emoji: '❌', text: 'Đã hủy', color: '#dc3545' },
    };
    
    const status = statusMessages[newStatus] || { emoji: '📋', text: newStatus, color: '#666' };
    
    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Cập nhật đơn hàng - VeritaShop</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px;">
    <h1 style="color: #667eea; text-align: center;">🛍️ VeritaShop</h1>
    
    <p>Xin chào <strong>${user.name}</strong>,</p>
    
    <p>Đơn hàng <strong>#${order.orderNumber}</strong> của bạn đã được cập nhật trạng thái:</p>
    
    <div style="text-align: center; padding: 30px; background-color: #f8f9fa; border-radius: 12px; margin: 20px 0;">
      <span style="font-size: 48px;">${status.emoji}</span>
      <p style="font-size: 24px; font-weight: bold; color: ${status.color}; margin: 15px 0 0 0;">
        ${status.text}
      </p>
    </div>
    
    <p style="text-align: center;">
      <a href="${process.env.APP_URL || 'https://veritashop.vn'}/orders/${order._id}" 
         style="display: inline-block; background-color: #667eea; color: #ffffff; padding: 12px 24px; border-radius: 8px; text-decoration: none;">
        Xem chi tiết đơn hàng
      </a>
    </p>
    
    <p style="color: #666; font-size: 14px; text-align: center; margin-top: 30px;">
      Cảm ơn bạn đã mua sắm tại VeritaShop!
    </p>
  </div>
</body>
</html>
    `;
    
    const mailOptions = {
      from: `"VeritaShop" <${process.env.SMTP_FROM || 'noreply@veritashop.vn'}>`,
      to: user.email,
      subject: `${status.emoji} Đơn hàng #${order.orderNumber} - ${status.text}`,
      html,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`Order status update email sent to ${user.email}: ${info.messageId}`);
    
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Error sending order status update email:', error);
    return { success: false, error: error.message };
  }
};

module.exports = {
  sendOrderConfirmationEmail,
  sendOrderStatusUpdateEmail,
};
