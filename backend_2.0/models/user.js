const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  bio: String,
  phoneNumber: { type: String, unique: true },
  password: String,
  profileImage: String, // URL or filename
  otp: { type: String, default: '123456' },
});

module.exports = mongoose.model('User', userSchema);
