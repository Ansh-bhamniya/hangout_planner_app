// models/trip.js
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const recipientSchema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User' },
  status: { type: String, enum: ['pending', 'approved'], default: 'pending' },
});


const tripSchema = new mongoose.Schema({
    creator: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    message: { type: String },
    participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // ✅ FIXED

  }, { timestamps: true });
  
module.exports = mongoose.model('Trip', tripSchema);
