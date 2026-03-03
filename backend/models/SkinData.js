const mongoose = require('mongoose');

const SkinDataSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    fullName: { type: String, required: true },
    age: { type: Number },
    gender: { type: String },
    skinType: { type: String },
    undertone: { type: String },
    shadeLevel: { type: String },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('SkinData', SkinDataSchema);
