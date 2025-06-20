const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  bio: String,
  phoneNumber: { type: String, unique: true },
  password: String,
  profileImage: String, // URL or filename
  otp: { type: String, default: '123456' },

  // 👇 Add these lines
  followRequests: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  followers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  following: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  acceptedFollowRequests: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  
});

module.exports = mongoose.model('User', userSchema);
