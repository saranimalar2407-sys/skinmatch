const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
    brand: { type: String, required: true },
    name: { type: String, required: true },
    finish: { type: String },
    undertone: { type: String },
    price: { type: String },
    imageUrl: { type: String }
});

module.exports = mongoose.model('Product', ProductSchema);
