const jwt = require('jsonwebtoken');
const responses = require('../utils/responses');
const User = require('../models/user');

const authMiddleware = async (req, res, next) => {
    const authHeader = req.header('Authorization');

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json(responses.error("No or invalid token format."));
    }

    const token = authHeader.split(" ")[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || "sher");
        const user = await User.findById(decoded.userId);

        if (!user) {
            return res.status(401).json(responses.error("User not found."));
        }

        req.user = user;
        next();
    } catch (err) {
        console.error("Auth error:", err.message);
        return res.status(401).json(responses.error("Invalid or expired token."));
    }
};

module.exports = authMiddleware;
