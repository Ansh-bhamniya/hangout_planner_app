const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const responses = require('../utils/responses');

// Register with phone number, password, name, bio, and profile image
const register = async (req, res) => {
  const { name, bio, phoneNumber, password, profileImage } = req.body;

  if (!name || !bio || !phoneNumber || !password || !profileImage) {
    return res.status(400).json(responses.error("All fields are required"));
  }

  try {
    const existingUser = await User.findOne({ phoneNumber });
    if (existingUser) {
      return res.status(400).json(responses.error("Phone number already registered"));
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      bio,
      phoneNumber,
      password: hashedPassword,
      profileImage,
      otp: '123456' // static OTP for demonstration
    });

    await user.save();

    return res.status(201).json(responses.success_data({
      message: "Registered successfully",
      phoneNumber: user.phoneNumber
    }));
  } catch (err) {
    return res.status(500).json(responses.error("Registration failed"));
  }
};

// Login with phone and password (moves to OTP screen if correct)
const login = async (req, res) => {
  const { phoneNumber, password } = req.body;

  if (!phoneNumber || !password) {
    return res.status(400).json(responses.error("Phone number and password are required"));
  }

  try {
    const user = await User.findOne({ phoneNumber });
    if (!user) {
      return res.status(401).json(responses.error("Invalid credentials"));
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json(responses.error("Invalid credentials"));
    }

    // Proceed to OTP screen
    return res.status(200).json(responses.success_data({
      message: "OTP sent to terminal",
      phoneNumber: user.phoneNumber
    }));
  } catch (err) {
    return res.status(500).json(responses.error("Login failed"));
  }
};

// OTP verification (always use 123456)
const verifyOtp = async (req, res) => {
  const { phoneNumber, otp } = req.body;

  if (otp !== '123456') {
    return res.status(401).json(responses.error("Invalid OTP"));
  }

  try {
    const user = await User.findOne({ phoneNumber });
    if (!user) {
      return res.status(404).json(responses.error("User not found"));
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET || "sher", {
      expiresIn: '1h'
    });

    return res.status(200).json(responses.success_data({
      token,
      user: {
        id: user._id,
        name: user.name,
        phoneNumber: user.phoneNumber,
        profileImage: user.profileImage
      }
    }));
  } catch (err) {
    return res.status(500).json(responses.error("OTP verification failed"));
  }
};

// // Get current logged-in user info
// const getMe = async (req, res) => {
//   const user = req.user;

//   return res.status(200).json(responses.success_data({
//     id: user._id,
//     name: user.name,
//     bio: user.bio,
//     phoneNumber: user.phoneNumber,
//     profileImage: user.profileImage
//   }));
// };

module.exports = {
  register,
  login,
  verifyOtp,
//   getMe
};
