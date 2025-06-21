// controllers/userNetworkController.js
const User = require('../models/user');
const responses = require('../utils/responses');

const getUserNetwork = async (req, res) => {
  try {
    const currentUserId = req.user._id.toString();

    const currentUser = await User.findById(currentUserId)
      .populate('following', '_id name')
      .lean();

    const directFriends = currentUser.following.map(f => f._id.toString());

    const friendsOfFriendsSet = new Set();

    for (const friendId of directFriends) {
      const friend = await User.findById(friendId).populate('following', '_id name').lean();
      friend.following.forEach(f => {
        const fid = f._id.toString();
        if (fid !== currentUserId && !directFriends.includes(fid)) {
          friendsOfFriendsSet.add(fid);
        }
      });
    }

    const allUsers = await User.find({}, '_id name').lean();

    return res.status(200).json(responses.success_data({
      currentUserId,
      directFriends,
      friendsOfFriends: Array.from(friendsOfFriendsSet),
      allUsers
    }));
  } catch (err) {
    console.error("❌ Error in getUserNetwork:", err);
    return res.status(500).json(responses.error("Failed to fetch network"));
  }
};


// 1. Fetch direct friends
const getFriendsOf = async (req, res) => {
  try {
    const currentUser = await User.findById(req.user._id)
      .populate('following', '_id name profileImage')
      .lean();

    return res.status(200).json(responses.success_data(currentUser.following));
  } catch (err) {
    console.error("❌ getFriendsOf error:", err);
    return res.status(500).json(responses.error("Failed to fetch friends"));
  }
};


// 2. Fetch friends of friends
const getFriendsOfFriends = async (req, res) => {
  try {
    const currentUser = await User.findById(req.user._id)
      .populate({
        path: 'following',
        populate: { path: 'following', select: '_id name profileImage' }
      })
      .lean();

    const directIds = currentUser.following.map(f => f._id.toString());
    const fofSet = new Set();

    currentUser.following.forEach(f => {
      f.following?.forEach(ff => {
        const id = ff._id.toString();
        if (id !== req.user._id.toString() && !directIds.includes(id)) {
          fofSet.add(id);
        }
      });
    });

    // Return array of friend-of-friend user documents
    const fofUsers = await User.find({ _id: { $in: Array.from(fofSet) } }, '_id name profileImage').lean();

    return res.status(200).json(responses.success_data(fofUsers));
  } catch (err) {
    console.error("❌ getFriendsOfFriends error:", err);
    return res.status(500).json(responses.error("Failed to fetch friends of friends"));
  }
};


module.exports = {
  getUserNetwork,
  getFriendsOf,
  getFriendsOfFriends
};
