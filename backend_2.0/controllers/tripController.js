const Trip = require('../models/trip');
const User = require('../models/user');
const responses = require('../utils/responses');

// 1. ✅ Create Trip
const createTrip = async (req, res) => {
  try {
    const { selectedIds, title, message } = req.body;
    const creator = req.user._id; // ← take from auth middleware

    if (!creator || !selectedIds || !title || !message) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const requests = selectedIds.map(userId => ({
      userId,
      status: 'pending'
    }));

    const trip = new Trip({
      creator,
      title,
      message,
      participants: selectedIds,
      requests
    });

    await trip.save();

    return res.status(201).json({ message: "Trip created successfully", data: trip });
  } catch (err) {
    console.error("❌ createTrip error:", err);
    return res.status(500).json({ message: "Trip creation failed" });
  }
};



// 2. ✅ Get trips I created
    const getMyTrips = async (req, res) => {
        try {
        const trips = await Trip.find({ creator: req.user._id });
        res.status(200).json({ data: trips });
        } catch (err) {
        console.error('❌ getMyTrips error:', err);
        res.status(500).json({ message: 'Failed to fetch trips' });
        }
    };
  

// 3. ✅ Get trips where I'm a participant
    const getTripsForMe = async (req, res) => {
    try {
        const trips = await Trip.find({ "participants.user": req.user._id }).populate('createdBy', 'name');
        return res.status(200).json(responses.success_data(trips));
    } catch (err) {
        console.error("❌ getTripsForMe error:", err);
        return res.status(500).json(responses.error("Failed to fetch trips for you"));
    }
    };

// 4. ✅ Approve a Trip
    const approveTrip = async (req, res) => {
        try {
        const trip = await Trip.findById(req.params.tripId);
        const participant = trip.participants.find(p => p.user.toString() === req.user._id.toString());
    
        if (!participant) return res.status(404).json({ message: 'Not a participant' });
    
        // Approve only if not already approved
        if (!participant.approvals.includes(req.user._id.toString())) {
            participant.approvals.push(req.user._id);
        }
    
        // If approved by all 1-degree friends, mark as approved
        if (participant.approvals.length >= 1) {
            participant.status = 'approved';
        }
    
        await trip.save();
        res.status(200).json({ message: 'Approved', trip });
        } catch (err) {
        console.error('❌ approveTrip error:', err);
        res.status(500).json({ message: 'Approval failed' });
        }
    };
  

const getIncomingTrips = async (req, res) => {
    try {
      const trips = await Trip.find({
        'participants.user': req.user._id
      });
      res.status(200).json({ data: trips });
    } catch (err) {
      console.error('❌ getIncomingTrips error:', err);
      res.status(500).json({ message: 'Failed to fetch incoming trips' });
    }
  };


  
module.exports = {
  createTrip,
  getMyTrips,
  getTripsForMe,
  approveTrip,
  getIncomingTrips
};
