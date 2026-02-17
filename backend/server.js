require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const User = require('./models/User');
const Message = require('./models/Message');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: [
      "*",
      "https://chat-app-frontend-git-main-om-prakash-vishwakarmas-projects.vercel.app/"  // ← your vercel URL
    ],
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors({
  origin: [
    "*",
    "https://chat-app-frontend-git-main-om-prakash-vishwakarmas-projects.vercel.app/"  // ← your vercel URL
  ],
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true
}));
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/chatapp', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('✅ MongoDB connected successfully'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// JWT Middleware
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
    req.userId = decoded.userId;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// ==================== REST API ROUTES ====================

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Check if user exists
    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }
    
    // Create user
    const user = new User({
      username,
      email,
      password,
      avatar: `https://ui-avatars.com/api/?name=${username}&background=random`
    });
    
    await user.save();
    
    // Generate token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }
    );
    
    res.status(201).json({
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        avatar: user.avatar
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    
    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    
    // Update online status
    user.online = true;
    await user.save();
    
    // Generate token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }
    );
    
    res.json({
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        avatar: user.avatar
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all users (except current user)
app.get('/api/users', verifyToken, async (req, res) => {
  try {
    const users = await User.find({ _id: { $ne: req.userId } })
      .select('-password')
      .sort({ online: -1, username: 1 });
    
    res.json(users);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get chat history between two users
app.get('/api/messages/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.userId;
    
    const messages = await Message.find({
      $or: [
        { sender: currentUserId, receiver: userId },
        { sender: userId, receiver: currentUserId }
      ]
    })
    .populate('sender', 'username avatar')
    .populate('receiver', 'username avatar')
    .sort({ createdAt: 1 })
    .limit(100);
    
    res.json(messages);
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Mark messages as read
app.put('/api/messages/read/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.userId;
    
    await Message.updateMany(
      { sender: userId, receiver: currentUserId, read: false },
      { read: true, readAt: new Date() }
    );
    
    res.json({ success: true });
  } catch (error) {
    console.error('Mark read error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ==================== SOCKET.IO ====================

const userSockets = new Map(); // Map userId to socketId

io.on('connection', (socket) => {
  console.log('🔌 New client connected:', socket.id);
  
  // User joins
  socket.on('join', async (userId) => {
    try {
      socket.userId = userId;
      userSockets.set(userId, socket.id);
      
      // Update user online status
      await User.findByIdAndUpdate(userId, { online: true });
      
      // Notify all users that this user is online
      io.emit('user_online', { userId });
      
      console.log(`✅ User ${userId} joined`);
    } catch (error) {
      console.error('Join error:', error);
    }
  });
  
  // Send message
  socket.on('send_message', async (data) => {
    try {
      const { senderId, receiverId, content, type = 'text' } = data;
      
      // Save message to database
      const message = new Message({
        sender: senderId,
        receiver: receiverId,
        content,
        type
      });
      
      await message.save();
      
      // Populate sender and receiver info
      await message.populate('sender', 'username avatar');
      await message.populate('receiver', 'username avatar');
      
      // Send to receiver if online
      const receiverSocketId = userSockets.get(receiverId);
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('receive_message', message);
      }
      
      // Send confirmation to sender
      socket.emit('message_sent', message);
      
      console.log(`📨 Message from ${senderId} to ${receiverId}`);
    } catch (error) {
      console.error('Send message error:', error);
      socket.emit('message_error', { error: 'Failed to send message' });
    }
  });
  
  // Typing indicator
  socket.on('typing', (data) => {
    const { senderId, receiverId } = data;
    const receiverSocketId = userSockets.get(receiverId);
    
    if (receiverSocketId) {
      io.to(receiverSocketId).emit('user_typing', { userId: senderId });
    }
  });
  
  // Stop typing indicator
  socket.on('stop_typing', (data) => {
    const { senderId, receiverId } = data;
    const receiverSocketId = userSockets.get(receiverId);
    
    if (receiverSocketId) {
      io.to(receiverSocketId).emit('user_stop_typing', { userId: senderId });
    }
  });
  
  // Disconnect
  socket.on('disconnect', async () => {
    try {
      const userId = socket.userId;
      
      if (userId) {
        userSockets.delete(userId);
        
        // Update user offline status
        await User.findByIdAndUpdate(userId, {
          online: false,
          lastSeen: new Date()
        });
        
        // Notify all users that this user is offline
        io.emit('user_offline', { userId });
        
        console.log(`❌ User ${userId} disconnected`);
      }
    } catch (error) {
      console.error('Disconnect error:', error);
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Chat server is running' });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
