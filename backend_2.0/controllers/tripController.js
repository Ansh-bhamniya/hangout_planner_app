const Trip = require('../models/trip');
const User = require('../models/user');
const responses = require('../utils/responses');

// 1. ✅ Create Trip
const createTrip = async (req, res) => {
  try {
    const { title, message, selectedIds = [] } = req.body;
    const creatorId = req.user._id;

    console.log("👤 Authenticated user:", creatorId);
    console.log("📤 Received selectedIds:", selectedIds);

    // Get creator and their 1st-degree friends
    const creator = await User.findById(creatorId).populate('following', '_id');
    if (!creator) return res.status(404).json({ success: false, message: 'Creator not found' });

    const directFriends = creator.following.map(f => f._id.toString());

    // Build participant list with status based on relationship
    const participantList = [
      {
        user: creatorId,
        status: 'approved',
        visible: true,
      },
      ...selectedIds.map(id => ({
        user: id,
        status: 'pending',
        visible: directFriends.includes(id), // only 1st-degree get visible immediately
      })),
    ];

    // Create trip
    const newTrip = new Trip({
      creator: creatorId,
      title,
      message,
      participants: participantList,
    });

    await newTrip.save();

    return res.status(201).json({ success: true, data: newTrip });
  } catch (err) {
    console.error("❌ createTrip error:", err);
    return res.status(500).json({ success: false, message: 'Trip creation failed' });
  }
};




// 2. ✅ Get trips I created
const getMyTrips = async (req, res) => {
  try {
    const trips = await Trip.find({ creator: req.user._id })
      .populate('participants.user', 'name')
      .lean();

    res.status(200).json({ data: trips });
  } catch (err) {
    console.error('❌ getMyTrips error:', err);
    res.status(500).json({ message: 'Failed to fetch trips' });
  }
};

// 3. ✅ Get trips where I'm a participant
const getTripsForMe = async (req, res) => {
  try {
    const trips = await Trip.find({ "participants.user": req.user._id })
      .populate('creator', 'name')
      .populate('participants.user', 'name')
      .lean();

    return res.status(200).json(responses.success_data(trips));
  } catch (err) {
    console.error("❌ getTripsForMe error:", err);
    return res.status(500).json(responses.error("Failed to fetch trips for you"));
  }
};

// 4. ✅ Approve a Trip
const approveTrip = async (req, res) => {
  try {
    const userId = req.user._id;
    const { tripId } = req.params;

    const trip = await Trip.findById(tripId);
    if (!trip) {
      return res.status(404).json({ message: "Trip not found" });
    }

    // Check if user is a participant
    const participant = trip.participants.find(p => p.user.toString() === userId.toString());
    if (!participant) {
      return res.status(403).json({ message: "You're not a participant in this trip" });
    }

    // Prevent double-approval
    if (participant.status === 'approved') {
      return res.status(400).json({ message: "Already approved" });
    }

    // Mark participant as approved
    participant.status = 'approved';

    // Add to approvals list
    if (!trip.approvals.includes(userId)) {
      trip.approvals.push(userId);
    }

    await trip.save();
    res.status(200).json({ message: "Trip approved", status: participant.status });
  } catch (err) {
    console.error("❌ approveTrip error:", err);
    res.status(500).json({ message: "Failed to approve trip" });
  }
};

// 5. ✅ Get incoming trips (for notifications)
// Replace your existing getIncomingTrips function with this enhanced version
const getIncomingTrips = async (req, res) => {
  try {
    const userId = req.user._id;
    // console.log("🔍 Authenticated user:", req.user);
    
    // Get current user's direct friends
    const currentUser = await User.findById(userId).populate('following', '_id name');
    const myDirectFriends = currentUser.following.map(f => f._id.toString());
    
    const trips = await Trip.find({
      $or: [
        { creator: userId },
        { participants: { $elemMatch: { user: userId, visible: true } } }
      ]
    })
    .populate('creator', 'name')
    .populate('participants.user', 'name')
    .lean();
    

    const enrichedTrips = await Promise.all(trips.map(async trip => {
      // Get creator's direct friends
      const creator = await User.findById(trip.creator._id).populate('following', '_id');
      const creatorFriends = creator.following.map(f => f._id.toString());
      
      // Enrich each participant with invite permissions
      const enrichedParticipants = trip.participants.map(participant => {
        const participantId = participant.user._id.toString();
        const canBeInvitedByMe = (
          // I must be a direct friend of the creator
          myDirectFriends.includes(trip.creator._id.toString()) &&
          // Participant must be a friend of creator (but not necessarily my direct friend)
          creatorFriends.includes(participantId) &&
          // Participant is not me
          participantId !== userId.toString() &&
          // Participant is in pending status and not visible yet
          participant.status === 'pending' &&
          !participant.visible
        );

        return {
          ...participant,
          canBeInvitedByMe
        };
      });

      return {
        ...trip,
        participants: enrichedParticipants,
        approvedByMe: trip.participants.find(p => String(p.user._id) === String(userId))?.status === 'approved',
      };
    }));

    res.status(200).json(enrichedTrips);
  } catch (err) {
    console.error('❌ getIncomingTrips error:', err);
    res.status(500).json({ message: 'Failed to fetch incoming trips' });
  }
};

const inviteToTrip = async (req, res) => {
  try {
    const { tripId, userId } = req.params;
    console.log("📨 Invite API hit:", { tripId, userId });
    const trip = await Trip.findById(tripId);
    if (!trip) return res.status(404).json({ message: "Trip not found" });

    const participant = trip.participants.find(p => p.user.toString() === userId);
    if (!participant) return res.status(404).json({ message: "Participant not found" });

    if (participant.visible) {
      return res.status(400).json({ message: "User already invited" });
    }

    participant.visible = true;
    await trip.save();

    res.status(200).json({ message: "Invite sent successfully" });
  } catch (err) {
    console.error("❌ inviteToTrip error:", err);
    res.status(500).json({ message: "Failed to send invite" });
  }
};



const getUserFriends = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId).populate('following', '_id name');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      data: user.following,
    });
  } catch (err) {
    console.error("❌ getUserFriends error:", err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

module.exports = {
  createTrip,
  getMyTrips,
  getTripsForMe,
  approveTrip,
  getIncomingTrips,
  inviteToTrip,
  getUserFriends
};
