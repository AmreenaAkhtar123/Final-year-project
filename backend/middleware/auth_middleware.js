
import jwt from 'jsonwebtoken';

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    // Check whether the Authorization header exists.
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Authentication token is required.',
      });
    }

    // Extract the token.
    const token = authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        message: 'Authentication token is required.',
      });
    }

    // Verify the token.
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET,
    );

    // Attach the authenticated user's ID to the request.
    req.user = {
      userId: decoded.userId,
    };

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        message: 'Your session has expired. Please log in again.',
      });
    }

    return res.status(401).json({
      message: 'Invalid authentication token.',
    });
  }
};

export default authMiddleware;
