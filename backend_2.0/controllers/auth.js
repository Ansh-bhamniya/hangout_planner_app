const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const responses = require('../utils/responses');

// Register with phone number, password, name, bio, and profile image
const register = async (req, res) => {
  const { name, bio, phoneNumber, password, profileImage } = req.body;
  console.log("🛠️ Incoming request body:", req.body);

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
    console.log(`this_is_user ${JSON.stringify(user, null, 2)}`);

    await user.save();

    return res.status(201).json(responses.success_data({
      message: "Registered successfully",
      phoneNumber: user.phoneNumber
    }));
  } catch (err) {
    console.error("❌ Registration error:", err);
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

// Updated getAllUsers controller
const getAllUsers = async (req, res) => {
  try {
    const currentUserId = req.user._id;
    const currentUser = await User.findById(currentUserId);

    const users = await User.find({}, 'name phoneNumber profileImage bio followRequests followers').lean();

    const modifiedUsers = users.map(user => {
      const isSelf = user._id.toString() === currentUserId.toString();

      const isRequested = user.followRequests?.some(
        id => id.toString() === currentUserId.toString()
      );

      const isFriend =
        currentUser.following?.some(id => id.toString() === user._id.toString()) &&
        user.followers?.some(id => id.toString() === currentUserId.toString());

      return {
        ...user,
        followRequested: !isSelf && isRequested && !isFriend,
        isFriend: !isSelf && isFriend,
      };
    });

    return res.status(200).json(responses.success_data(modifiedUsers));
  } catch (err) {
    console.error("❌ getAllUsers error:", err);
    return res.status(500).json(responses.error("Failed to fetch users"));
  }
};





const sendFollowRequest = async (req, res) => {
  const currentUserId = req.user._id;
  const targetUserId = req.params.targetUserId;

  if (currentUserId.toString() === targetUserId) {
    return res.status(400).json(responses.error("You can't follow yourself."));
  }

  try {
    const targetUser = await User.findById(targetUserId);
    if (!targetUser) {
      return res.status(404).json(responses.error("User not found."));
    }

    if (targetUser.followRequests.includes(currentUserId)) {
      return res.status(400).json(responses.error("Follow request already sent."));
    }

    targetUser.followRequests.push(currentUserId);
    await targetUser.save();

    return res.status(200).json(responses.success("Follow request sent."));
  } catch (error) {
    console.error("❌ Follow request error:", error);
    return res.status(500).json(responses.error("Something went wrong."));
  }
};


const acceptFollowRequest = async (req, res) => {
  const currentUserId = req.user._id;
  const requesterId = req.params.requesterId;

  try {
    const user = await User.findById(currentUserId);
    const requester = await User.findById(requesterId);

    if (!user || !requester) {
      return res.status(404).json(responses.error("User not found"));
    }

    // ✅ Don't remove from followRequests so it remains visible in notifications
    // But only add if not already added
    if (!user.followers.includes(requesterId)) {
      user.followers.push(requesterId);
    }

    if (!user.following.includes(requesterId)) {
      user.following.push(requesterId);
    }

    if (!requester.followers.includes(currentUserId)) {
      requester.followers.push(currentUserId);
    }

    if (!requester.following.includes(currentUserId)) {
      requester.following.push(currentUserId);
    }

    await user.save();
    await requester.save();

    console.log("✅ Follow request accepted successfully");
    return res.status(200).json(responses.success("Follow request accepted"));
  } catch (err) {
    console.error("❌ Error in acceptFollowRequest:", err);
    return res.status(500).json(responses.error("Server error"));
  }
};

const getPendingRequests = async (req, res) => {
  try {
    const currentUser = await User.findById(req.user._id).populate(
      'followRequests',
      'name phoneNumber profileImage following'
    );
    const currentUserId = req.user._id.toString();

    const enrichedRequests = currentUser.followRequests.map((user) => {
      const isAccepted = user.following?.some(
        (id) => id.toString() === currentUserId
      );
      return {
        _id: user._id,
        name: user.name,
        phoneNumber: user.phoneNumber,
        profileImage: user.profileImage,
        isAccepted, // ✅ frontend will use this
      };
    });

    return res.status(200).json({ data: enrichedRequests });
  } catch (err) {
    console.error("❌ Error in getPendingRequests:", err);
    return res.status(500).json({ message: "Failed to fetch follow requests" });
  }
};

const getFriends = async (req, res) => {
  try {
    const currentUser = await User.findById(req.user._id);

    // All users who are both in following and followers = friends
    const friendIds = currentUser.following.filter(followingId =>
      currentUser.followers.includes(followingId)
    );

    // Fetch friend user data
    const friends = await User.find({ _id: { $in: friendIds } }, 'name phoneNumber bio profileImage');

    return res.status(200).json({ data: friends });
  } catch (err) {
    console.error("❌ getFriends error:", err);
    return res.status(500).json({ message: "Failed to fetch friends" });
  }
};

// GET /auth/me - Returns current user ID and basic info
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id, 'name phoneNumber _id');
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    return res.status(200).json({ success: true, data: user });
  } catch (err) {
    console.error("❌ getMe error:", err);
    return res.status(500).json({ success: false, message: "Server error" });
  }
};
  


module.exports = {
  register,
  login,
  verifyOtp,
  getAllUsers,
  sendFollowRequest,
  acceptFollowRequest,
  getPendingRequests,
  getFriends,
  getMe
  
//   getMe
};
