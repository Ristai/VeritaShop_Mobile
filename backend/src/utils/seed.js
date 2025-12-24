require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product');
const Coupon = require('../models/Coupon');

const phones = [
  // iPhone
  {
    name: 'iPhone 15 Pro Max 256GB',
    brand: 'iPhone',
    description: 'iPhone 15 Pro Max với chip A17 Pro mạnh mẽ nhất, khung titan cao cấp, camera 48MP với nhiều cải tiến đột phá. Màn hình Super Retina XDR 6.7 inch, hỗ trợ ProMotion 120Hz.',
    price: 29990000,
    originalPrice: 34990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max_3.png',
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max-titan-xanh_1.jpg',
    ],
    specs: {
      ram: '8GB',
      rom: '256GB',
      chip: 'A17 Pro',
      battery: '4422mAh',
      screen: '6.7 inch Super Retina XDR OLED',
      camera: '48MP + 12MP + 12MP',
    },
    colors: [
      { name: 'Titan Đen', code: '#1a1a1a' },
      { name: 'Titan Trắng', code: '#f5f5f0' },
      { name: 'Titan Xanh', code: '#394c6d' },
      { name: 'Titan Tự Nhiên', code: '#837f7a' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 50,
    rating: 4.9,
    reviewCount: 234,
    isFeatured: true,
    tags: ['Apple', 'Premium', 'Hot', '5G', 'ProMax'],
  },
  {
    name: 'iPhone 15 Pro 128GB',
    brand: 'iPhone',
    description: 'iPhone 15 Pro với chip A17 Pro, khung titan, camera 48MP. Màn hình 6.1 inch Super Retina XDR, hỗ trợ ProMotion 120Hz và Always-On Display.',
    price: 23990000,
    originalPrice: 28990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro_3.png',
    ],
    specs: {
      ram: '8GB',
      rom: '128GB',
      chip: 'A17 Pro',
      battery: '3274mAh',
      screen: '6.1 inch Super Retina XDR OLED',
      camera: '48MP + 12MP + 12MP',
    },
    colors: [
      { name: 'Titan Đen', code: '#1a1a1a' },
      { name: 'Titan Trắng', code: '#f5f5f0' },
      { name: 'Titan Xanh', code: '#394c6d' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 35,
    rating: 4.8,
    reviewCount: 189,
    isFeatured: true,
    tags: ['Apple', 'Premium', '5G', 'Pro'],
  },
  {
    name: 'iPhone 15 128GB',
    brand: 'iPhone',
    description: 'iPhone 15 với thiết kế Dynamic Island, chip A16 Bionic, camera 48MP. Cổng USB-C tiện lợi, màn hình 6.1 inch Super Retina XDR.',
    price: 19990000,
    originalPrice: 22990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15_1.png',
    ],
    specs: {
      ram: '6GB',
      rom: '128GB',
      chip: 'A16 Bionic',
      battery: '3349mAh',
      screen: '6.1 inch Super Retina XDR OLED',
      camera: '48MP + 12MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Xanh', code: '#c9e3e6' },
      { name: 'Hồng', code: '#f4d4d0' },
      { name: 'Vàng', code: '#f5f0d0' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 45,
    rating: 4.7,
    reviewCount: 156,
    isFeatured: false,
    tags: ['Apple', '5G', 'Dynamic Island'],
  },

  // Samsung
  {
    name: 'Samsung Galaxy S24 Ultra 256GB',
    brand: 'Samsung',
    description: 'Galaxy S24 Ultra với chip Snapdragon 8 Gen 3, S Pen tích hợp, camera 200MP zoom quang 10x. Màn hình Dynamic AMOLED 2X 6.8 inch, khung titan cao cấp.',
    price: 26990000,
    originalPrice: 33990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s24-ultra_2_.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Snapdragon 8 Gen 3',
      battery: '5000mAh',
      screen: '6.8 inch Dynamic AMOLED 2X',
      camera: '200MP + 12MP + 50MP + 10MP',
    },
    colors: [
      { name: 'Xám Titan', code: '#8a8a8a' },
      { name: 'Đen Titan', code: '#1a1a1a' },
      { name: 'Tím Titan', code: '#a0a0c0' },
      { name: 'Vàng Titan', code: '#d4c49a' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 40,
    rating: 4.9,
    reviewCount: 312,
    isFeatured: true,
    tags: ['Samsung', 'Premium', 'Hot', '5G', 'S Pen', 'AI'],
  },
  {
    name: 'Samsung Galaxy S24+ 256GB',
    brand: 'Samsung',
    description: 'Galaxy S24+ với chip Exynos 2400, màn hình Dynamic AMOLED 2X 6.7 inch, camera 50MP chụp đêm xuất sắc. Tích hợp Galaxy AI thông minh.',
    price: 22990000,
    originalPrice: 26990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s24-plus_1_.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Exynos 2400',
      battery: '4900mAh',
      screen: '6.7 inch Dynamic AMOLED 2X',
      camera: '50MP + 12MP + 10MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Xám', code: '#c0c0c0' },
      { name: 'Tím', code: '#c8bfe7' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 30,
    rating: 4.7,
    reviewCount: 145,
    isFeatured: true,
    tags: ['Samsung', '5G', 'AI'],
  },
  {
    name: 'Samsung Galaxy Z Fold5 256GB',
    brand: 'Samsung',
    description: 'Galaxy Z Fold5 với màn hình gập 7.6 inch, chip Snapdragon 8 Gen 2. Thiết kế gập độc đáo, đa nhiệm mạnh mẽ với Flex Mode.',
    price: 36990000,
    originalPrice: 40990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-fold-5_1__2.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Snapdragon 8 Gen 2',
      battery: '4400mAh',
      screen: '7.6 inch Dynamic AMOLED 2X (Gập)',
      camera: '50MP + 12MP + 10MP',
    },
    colors: [
      { name: 'Xanh Icy', code: '#b8d4e3' },
      { name: 'Đen Phantom', code: '#1a1a1a' },
      { name: 'Kem', code: '#f5f0e6' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 15,
    rating: 4.6,
    reviewCount: 89,
    isFeatured: true,
    tags: ['Samsung', 'Premium', 'Foldable', '5G'],
  },

  // Xiaomi
  {
    name: 'Xiaomi 14 Ultra 512GB',
    brand: 'Xiaomi',
    description: 'Xiaomi 14 Ultra với camera Leica chuyên nghiệp, chip Snapdragon 8 Gen 3. Màn hình AMOLED 6.73 inch 2K, sạc nhanh 90W.',
    price: 23990000,
    originalPrice: 29990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-14-ultra_1__2.png',
    ],
    specs: {
      ram: '16GB',
      rom: '512GB',
      chip: 'Snapdragon 8 Gen 3',
      battery: '5000mAh',
      screen: '6.73 inch AMOLED 2K',
      camera: '50MP Leica + 50MP + 50MP + 50MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Trắng', code: '#f5f5f5' },
    ],
    condition: 'new',
    warranty: '18 tháng',
    stock: 25,
    rating: 4.8,
    reviewCount: 98,
    isFeatured: true,
    tags: ['Xiaomi', 'Premium', 'Leica', '5G'],
  },
  {
    name: 'Xiaomi 14 256GB',
    brand: 'Xiaomi',
    description: 'Xiaomi 14 với camera Leica, chip Snapdragon 8 Gen 3. Màn hình AMOLED 6.36 inch, thiết kế nhỏ gọn cao cấp.',
    price: 15990000,
    originalPrice: 18990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-14.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Snapdragon 8 Gen 3',
      battery: '4610mAh',
      screen: '6.36 inch AMOLED',
      camera: '50MP Leica + 50MP + 50MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Trắng', code: '#f5f5f5' },
      { name: 'Xanh Jade', code: '#00a86b' },
    ],
    condition: 'new',
    warranty: '18 tháng',
    stock: 35,
    rating: 4.7,
    reviewCount: 127,
    isFeatured: false,
    tags: ['Xiaomi', 'Leica', '5G'],
  },
  {
    name: 'Redmi Note 13 Pro+ 5G 256GB',
    brand: 'Xiaomi',
    description: 'Redmi Note 13 Pro+ với camera 200MP, chip Dimensity 7200 Ultra, sạc nhanh 120W. Màn hình AMOLED cong 6.67 inch.',
    price: 9490000,
    originalPrice: 11490000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-13-pro-plus-5g_2_.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Dimensity 7200 Ultra',
      battery: '5000mAh',
      screen: '6.67 inch AMOLED cong',
      camera: '200MP + 8MP + 2MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Tím', code: '#9370db' },
      { name: 'Trắng', code: '#f5f5f5' },
    ],
    condition: 'new',
    warranty: '18 tháng',
    stock: 60,
    rating: 4.6,
    reviewCount: 234,
    isFeatured: true,
    tags: ['Xiaomi', 'Redmi', '5G', 'Hot', '200MP'],
  },

  // OPPO
  {
    name: 'OPPO Find X7 Ultra 256GB',
    brand: 'OPPO',
    description: 'OPPO Find X7 Ultra với camera Hasselblad kép periscope, chip Dimensity 9300. Màn hình AMOLED 6.82 inch 2K, sạc nhanh 100W.',
    price: 24990000,
    originalPrice: 29990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-x7-ultra.png',
    ],
    specs: {
      ram: '16GB',
      rom: '256GB',
      chip: 'Dimensity 9300',
      battery: '5000mAh',
      screen: '6.82 inch AMOLED 2K',
      camera: '50MP Hasselblad + 50MP + 50MP + 50MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Nâu Da', code: '#8b4513' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 20,
    rating: 4.7,
    reviewCount: 67,
    isFeatured: true,
    tags: ['OPPO', 'Premium', 'Hasselblad', '5G'],
  },
  {
    name: 'OPPO Reno11 5G 256GB',
    brand: 'OPPO',
    description: 'OPPO Reno11 5G với chip Dimensity 7050, camera chân dung 50MP. Màn hình AMOLED 6.7 inch 120Hz, thiết kế mỏng nhẹ.',
    price: 10490000,
    originalPrice: 12490000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-reno-11-5g.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Dimensity 7050',
      battery: '4600mAh',
      screen: '6.7 inch AMOLED 120Hz',
      camera: '50MP + 32MP + 8MP',
    },
    colors: [
      { name: 'Xanh Biển', code: '#0077be' },
      { name: 'Xám', code: '#808080' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 45,
    rating: 4.5,
    reviewCount: 178,
    isFeatured: false,
    tags: ['OPPO', 'Reno', '5G'],
  },

  // Vivo
  {
    name: 'Vivo X100 Pro 256GB',
    brand: 'Vivo',
    description: 'Vivo X100 Pro với camera ZEISS chuyên nghiệp, chip Dimensity 9300. Màn hình AMOLED 6.78 inch cong, sạc nhanh 100W.',
    price: 22990000,
    originalPrice: 27990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-x100-pro.png',
    ],
    specs: {
      ram: '16GB',
      rom: '256GB',
      chip: 'Dimensity 9300',
      battery: '5400mAh',
      screen: '6.78 inch AMOLED cong',
      camera: '50MP ZEISS + 50MP + 50MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Cam', code: '#ff7f50' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 18,
    rating: 4.7,
    reviewCount: 89,
    isFeatured: true,
    tags: ['Vivo', 'Premium', 'ZEISS', '5G'],
  },
  {
    name: 'Vivo V30 5G 256GB',
    brand: 'Vivo',
    description: 'Vivo V30 5G với camera chân dung ZEISS, chip Snapdragon 7 Gen 3. Màn hình AMOLED cong 6.78 inch, thiết kế thời trang.',
    price: 11990000,
    originalPrice: 13990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v30-5g_4_.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Snapdragon 7 Gen 3',
      battery: '5000mAh',
      screen: '6.78 inch AMOLED cong',
      camera: '50MP + 50MP',
    },
    colors: [
      { name: 'Đen', code: '#1a1a1a' },
      { name: 'Tím', code: '#800080' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 35,
    rating: 4.5,
    reviewCount: 112,
    isFeatured: false,
    tags: ['Vivo', 'ZEISS', '5G'],
  },

  // Other brands
  {
    name: 'Google Pixel 8 Pro 256GB',
    brand: 'Other',
    description: 'Google Pixel 8 Pro với chip Tensor G3, camera AI tiên tiến nhất. Màn hình LTPO OLED 6.7 inch 120Hz, 7 năm cập nhật Android.',
    price: 23990000,
    originalPrice: 26990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/o/google-pixel-8-pro.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Google Tensor G3',
      battery: '5050mAh',
      screen: '6.7 inch LTPO OLED 120Hz',
      camera: '50MP + 48MP + 48MP',
    },
    colors: [
      { name: 'Obsidian', code: '#1a1a1a' },
      { name: 'Porcelain', code: '#f5f5f0' },
      { name: 'Bay', code: '#87ceeb' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 12,
    rating: 4.8,
    reviewCount: 56,
    isFeatured: true,
    tags: ['Google', 'Pixel', 'AI', '5G'],
  },
  {
    name: 'OnePlus 12 256GB',
    brand: 'Other',
    description: 'OnePlus 12 với chip Snapdragon 8 Gen 3, camera Hasselblad. Màn hình AMOLED 6.82 inch 2K 120Hz, sạc nhanh 100W.',
    price: 18990000,
    originalPrice: 22990000,
    images: [
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/o/n/oneplus-12.png',
    ],
    specs: {
      ram: '12GB',
      rom: '256GB',
      chip: 'Snapdragon 8 Gen 3',
      battery: '5400mAh',
      screen: '6.82 inch AMOLED 2K',
      camera: '50MP Hasselblad + 48MP + 64MP',
    },
    colors: [
      { name: 'Đen Silky', code: '#1a1a1a' },
      { name: 'Xanh Flowy', code: '#4169e1' },
    ],
    condition: 'new',
    warranty: '12 tháng',
    stock: 22,
    rating: 4.7,
    reviewCount: 78,
    isFeatured: false,
    tags: ['OnePlus', 'Hasselblad', '5G'],
  },
];

const seedProducts = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB Connected');

    // Clear existing products
    await Product.deleteMany({});
    console.log('Cleared existing products');

    // Insert new products
    const createdProducts = await Product.insertMany(phones);
    console.log(`Seeded ${createdProducts.length} products`);

    // Show summary
    const summary = await Product.aggregate([
      { $group: { _id: '$brand', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);
    console.log('\nProducts by brand:');
    summary.forEach(b => console.log(`  ${b._id}: ${b.count}`));

    // Seed coupons
    await Coupon.deleteMany({});
    console.log('\nCleared existing coupons');

    const coupons = [
      {
        code: 'WELCOME10',
        description: 'Giảm 10% cho khách hàng mới',
        discountType: 'percentage',
        discountValue: 10,
        maxDiscountAmount: 500000,
        minOrderAmount: 1000000,
        usageLimit: 1000,
        usagePerUser: 1,
        startDate: new Date(),
        endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        isActive: true,
      },
      {
        code: 'SALE20',
        description: 'Giảm 20% tối đa 1 triệu',
        discountType: 'percentage',
        discountValue: 20,
        maxDiscountAmount: 1000000,
        minOrderAmount: 5000000,
        usageLimit: 500,
        usagePerUser: 2,
        startDate: new Date(),
        endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        isActive: true,
      },
      {
        code: 'FREESHIP',
        description: 'Miễn phí vận chuyển',
        discountType: 'fixed',
        discountValue: 30000,
        minOrderAmount: 500000,
        usageLimit: null,
        usagePerUser: 5,
        startDate: new Date(),
        endDate: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
        isActive: true,
      },
      {
        code: 'IPHONE500K',
        description: 'Giảm 500K khi mua iPhone',
        discountType: 'fixed',
        discountValue: 500000,
        minOrderAmount: 15000000,
        usageLimit: 100,
        usagePerUser: 1,
        startDate: new Date(),
        endDate: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000),
        isActive: true,
        applicableBrands: ['iPhone'],
      },
      {
        code: 'SAMSUNG300K',
        description: 'Giảm 300K khi mua Samsung',
        discountType: 'fixed',
        discountValue: 300000,
        minOrderAmount: 10000000,
        usageLimit: 100,
        usagePerUser: 1,
        startDate: new Date(),
        endDate: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000),
        isActive: true,
        applicableBrands: ['Samsung'],
      },
      {
        code: 'NEWYEAR2025',
        description: 'Giảm 15% mừng năm mới 2025',
        discountType: 'percentage',
        discountValue: 15,
        maxDiscountAmount: 2000000,
        minOrderAmount: 3000000,
        usageLimit: 200,
        usagePerUser: 1,
        startDate: new Date('2025-01-01'),
        endDate: new Date('2025-01-31'),
        isActive: true,
      },
    ];

    const createdCoupons = await Coupon.insertMany(coupons);
    console.log(`Seeded ${createdCoupons.length} coupons`);

    await mongoose.connection.close();
    console.log('\nDatabase seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Seed error:', error);
    process.exit(1);
  }
};

seedProducts();
