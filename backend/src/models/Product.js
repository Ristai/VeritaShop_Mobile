const mongoose = require('mongoose');

const specsSchema = new mongoose.Schema({
  ram: { type: String, required: true },        // "8GB"
  rom: { type: String, required: true },        // "256GB"
  chip: { type: String, required: true },       // "A17 Pro"
  battery: { type: String, required: true },    // "4422mAh"
  screen: { type: String, required: true },     // "6.7 inch OLED"
  camera: { type: String, required: true },     // "48MP + 12MP + 12MP"
}, { _id: false });

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Vui lòng nhập tên sản phẩm'],
    trim: true,
    maxlength: [200, 'Tên sản phẩm không quá 200 ký tự'],
  },
  brand: {
    type: String,
    required: [true, 'Vui lòng chọn hãng'],
    enum: {
      values: ['iPhone', 'Samsung', 'Xiaomi', 'OPPO', 'Vivo', 'Other'],
      message: 'Hãng không hợp lệ',
    },
  },
  description: {
    type: String,
    required: [true, 'Vui lòng nhập mô tả'],
    maxlength: [5000, 'Mô tả không quá 5000 ký tự'],
  },
  price: {
    type: Number,
    required: [true, 'Vui lòng nhập giá'],
    min: [0, 'Giá không được âm'],
  },
  originalPrice: {
    type: Number,
    min: [0, 'Giá gốc không được âm'],
  },
  images: [{
    type: String,
    required: true,
  }],
  specs: {
    type: specsSchema,
    required: [true, 'Vui lòng nhập thông số kỹ thuật'],
  },
  colors: [{
    name: { type: String, required: true },     // "Titan Đen"
    code: { type: String },                      // "#1a1a1a"
    image: { type: String },                     // URL ảnh màu
  }],
  condition: {
    type: String,
    enum: {
      values: ['new', 'likenew', 'used'],
      message: 'Tình trạng không hợp lệ',
    },
    default: 'new',
  },
  warranty: {
    type: String,
    default: '12 tháng',
  },
  stock: {
    type: Number,
    required: [true, 'Vui lòng nhập số lượng tồn kho'],
    min: [0, 'Số lượng không được âm'],
    default: 0,
  },
  rating: {
    type: Number,
    min: [0, 'Rating tối thiểu là 0'],
    max: [5, 'Rating tối đa là 5'],
    default: 0,
  },
  reviewCount: {
    type: Number,
    default: 0,
  },
  isFeatured: {
    type: Boolean,
    default: false,
  },
  tags: [{
    type: String,
    trim: true,
  }],
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Indexes for better query performance
productSchema.index({ name: 'text', description: 'text', brand: 'text' });
productSchema.index({ brand: 1 });
productSchema.index({ price: 1 });
productSchema.index({ rating: -1 });
productSchema.index({ createdAt: -1 });
productSchema.index({ isFeatured: 1 });
productSchema.index({ 'specs.ram': 1 });
productSchema.index({ 'specs.rom': 1 });
productSchema.index({ condition: 1 });

// Virtual for discount percentage
productSchema.virtual('discountPercent').get(function() {
  if (this.originalPrice && this.originalPrice > this.price) {
    return Math.round((1 - this.price / this.originalPrice) * 100);
  }
  return 0;
});

// Virtual for stock status
productSchema.virtual('stockStatus').get(function() {
  if (this.stock === 0) return 'out_of_stock';
  if (this.stock < 10) return 'low_stock';
  return 'in_stock';
});

// Ensure virtuals are included in JSON
productSchema.set('toJSON', { virtuals: true });
productSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Product', productSchema);
