const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5050;

// ✅ Middleware
app.use(cors()); // Enable CORS
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Controllers
const authController = require('./controllers/auth');
const tripController = require('./controllers/tripController');
const authMiddleware = require('./controllers/authMiddleware');
const { getUserNetwork , getFriendsOf, getFriendsOfFriends} = require('./controllers/userNetworkController');
// ✅ Auth Routes
app.post('/auth/register', authController.register);
app.post('/auth/login', authController.login);
app.post('/auth/verify-otp', authController.verifyOtp);
app.get('/auth/users', authMiddleware, authController.getAllUsers);
app.post('/auth/follow/:targetUserId', authMiddleware, authController.sendFollowRequest);
// app.post('/auth/f', authMiddleware, authController.sendFollowRequest);
app.post('/auth/accept/:requesterId', authMiddleware, authController.acceptFollowRequest);
app.get('/auth/pending-requests', authMiddleware, authController.getPendingRequests);
app.get('/auth/friends', authMiddleware, authController.getFriends);
app.get('/auth/me', authMiddleware, authController.getMe);

app.get('/auth/network', authMiddleware, getUserNetwork);
app.get('/auth/direct-friends', authMiddleware, getFriendsOf);
app.get('/auth/friends-of-friends', authMiddleware, getFriendsOfFriends);

// ✅ Trip routes
app.post('/auth/trips/create', authMiddleware, tripController.createTrip);
app.get('/auth/trips/incoming', authMiddleware, tripController.getIncomingTrips);
app.post('/auth/trips/:tripId/approve', authMiddleware, tripController.approveTrip);
app.get('/auth/trips/my', authMiddleware, tripController.getMyTrips);
// ✅ NEW: Allow a participant to send trip invite to another participant
app.post('/auth/trips/:tripId/invite/:userId', authMiddleware, tripController.inviteToTrip);
app.post('/auth/users/:userId/friends', authMiddleware, tripController.getUserFriends);
// to approve a pending trip

// ✅ Root route
app.get('/', (req, res) => {
  res.send({ message: 'API running successfully!' });
});

// ✅ MongoDB connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch(err => console.error(" MongoDB connection error:", err));

// ✅ Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
