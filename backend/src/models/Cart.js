const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true,
  },
  color: {
    name: { type: String, required: true },
    code: { type: String },
  },
  quantity: {
    type: Number,
    required: true,
    min: [1, 'Số lượng tối thiểu là 1'],
    default: 1,
  },
  price: {
    type: Number,
    required: true,
  },
}, { _id: true });

const cartSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  items: [cartItemSchema],
}, {
  timestamps: true,
});

// Virtual for subtotal
cartSchema.virtual('subtotal').get(function() {
  return this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
});

// Virtual for shipping fee (free if subtotal >= 500,000 VNĐ)
cartSchema.virtual('shippingFee').get(function() {
  const subtotal = this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  return subtotal >= 500000 ? 0 : 30000;
});

// Virtual for tax (10% VAT)
cartSchema.virtual('tax').get(function() {
  const subtotal = this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  return Math.round(subtotal * 0.1);
});

// Virtual for total
cartSchema.virtual('total').get(function() {
  const subtotal = this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const shippingFee = subtotal >= 500000 ? 0 : 30000;
  const tax = Math.round(subtotal * 0.1);
  return subtotal + shippingFee + tax;
});

// Virtual for item count
cartSchema.virtual('itemCount').get(function() {
  return this.items.reduce((sum, item) => sum + item.quantity, 0);
});

// Ensure virtuals are included
cartSchema.set('toJSON', { virtuals: true });
cartSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Cart', cartSchema);
