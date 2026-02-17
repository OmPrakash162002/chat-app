# Real-Time Chat Application

A full-stack real-time chat application built with Flutter, Express.js, Socket.io, and MongoDB Atlas.

## Features

- ✅ User authentication (Register/Login)
- ✅ Real-time messaging with Socket.io
- ✅ Online/Offline status indicators
- ✅ Typing indicators
- ✅ Message history
- ✅ Beautiful and modern UI
- ✅ Read receipts
- ✅ Last seen timestamps

## Tech Stack

### Backend
- **Express.js** - Node.js web framework
- **Socket.io** - Real-time bidirectional communication
- **MongoDB Atlas** - Cloud database
- **JWT** - Authentication
- **Bcrypt** - Password hashing

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **Socket.io Client** - Real-time communication
- **HTTP** - REST API calls

---

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Node.js** (v14 or higher) - [Download](https://nodejs.org/)
2. **Flutter SDK** (v3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
3. **MongoDB Atlas Account** - [Sign up](https://www.mongodb.com/cloud/atlas/register)
4. **Android Studio/Xcode** (for mobile development)
5. **Git** - [Download](https://git-scm.com/)

---

## Step-by-Step Setup Instructions

### Part 1: MongoDB Atlas Setup

1. **Create MongoDB Atlas Account**
   - Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register)
   - Sign up for a free account

2. **Create a New Cluster**
   - Click "Build a Database"
   - Choose "FREE" tier (M0)
   - Select a cloud provider and region
   - Click "Create Cluster"

3. **Create Database User**
   - Go to "Database Access" in the left sidebar
   - Click "Add New Database User"
   - Choose "Password" authentication
   - Create username and password (save these!)
   - Set privileges to "Read and write to any database"
   - Click "Add User"

4. **Configure Network Access**
   - Go to "Network Access" in the left sidebar
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (0.0.0.0/0)
   - Click "Confirm"

5. **Get Connection String**
   - Go to "Database" in the left sidebar
   - Click "Connect" on your cluster
   - Click "Connect your application"
   - Copy the connection string
   - It looks like: `mongodb+srv://username:<password>@cluster.mongodb.net/?retryWrites=true&w=majority`
   - Replace `<password>` with your actual password

---

### Part 2: Backend Setup

1. **Navigate to Backend Directory**
   ```bash
   cd chat-app/backend
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Create Environment File**
   ```bash
   cp .env.example .env
   ```

4. **Configure Environment Variables**
   
   Open `.env` and update with your values:
   ```env
   PORT=3000
   MONGODB_URI=mongodb+srv://yourusername:yourpassword@cluster.mongodb.net/chatapp?retryWrites=true&w=majority
   JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
   ```

   **Important:** Replace:
   - `yourusername` - Your MongoDB Atlas username
   - `yourpassword` - Your MongoDB Atlas password
   - `cluster` - Your actual cluster name
   - `JWT_SECRET` - A random secure string

5. **Start the Backend Server**
   ```bash
   npm start
   ```

   Or for development with auto-reload:
   ```bash
   npm run dev
   ```

6. **Verify Server is Running**
   
   You should see:
   ```
   🚀 Server running on port 3000
   ✅ MongoDB connected successfully
   ```

   Test the health endpoint:
   ```bash
   curl http://localhost:3000/health
   ```

---

### Part 3: Flutter Frontend Setup

1. **Navigate to Frontend Directory**
   ```bash
   cd chat-app/frontend
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API URL**
   
   Open `lib/constants/api_constants.dart` and update the URLs:

   **For Android Emulator:**
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000';
   static const String socketUrl = 'http://10.0.2.2:3000';
   ```

   **For iOS Simulator:**
   ```dart
   static const String baseUrl = 'http://localhost:3000';
   static const String socketUrl = 'http://localhost:3000';
   ```

   **For Real Device (find your computer's IP):**
   ```dart
   static const String baseUrl = 'http://192.168.1.XXX:3000';  // Your IP
   static const String socketUrl = 'http://192.168.1.XXX:3000';
   ```

   **To find your IP:**
   - **Windows:** Run `ipconfig` in CMD, look for IPv4 Address
   - **Mac/Linux:** Run `ifconfig` or `ip addr show`, look for inet address

4. **Connect Device/Emulator**
   
   **For Android:**
   - Open Android Studio
   - Start an Android Emulator or connect a physical device with USB debugging
   - Verify: `flutter devices`

   **For iOS (Mac only):**
   - Open Xcode
   - Start iOS Simulator or connect a physical device
   - Verify: `flutter devices`

5. **Run the Flutter App**
   ```bash
   flutter run
   ```

   Or specify a device:
   ```bash
   flutter run -d <device-id>
   ```

---

## Testing the Application

### Step 1: Register First User
1. Launch the app
2. Click "Register"
3. Fill in:
   - Username: `user1`
   - Email: `user1@test.com`
   - Password: `password123`
   - Confirm Password: `password123`
4. Click "Register"

### Step 2: Register Second User
1. Use a different device/emulator OR logout and register again
2. Fill in:
   - Username: `user2`
   - Email: `user2@test.com`
   - Password: `password123`
   - Confirm Password: `password123`
3. Click "Register"

### Step 3: Start Chatting
1. On user1's device: Click on user2 from the list
2. Send a message
3. On user2's device: You should see the message in real-time!
4. Reply from user2
5. See real-time updates, typing indicators, and online status

---

## Project Structure

### Backend Structure
```
backend/
├── models/
│   ├── User.js           # User schema
│   └── Message.js        # Message schema
├── server.js             # Main server file
├── package.json          # Dependencies
├── .env                  # Environment variables
└── .env.example          # Example environment file
```

### Frontend Structure
```
frontend/
├── lib/
│   ├── constants/
│   │   └── api_constants.dart    # API endpoints
│   ├── models/
│   │   ├── user.dart             # User model
│   │   └── message.dart          # Message model
│   ├── providers/
│   │   ├── auth_provider.dart    # Authentication state
│   │   └── chat_provider.dart    # Chat state
│   ├── screens/
│   │   ├── login_screen.dart     # Login UI
│   │   ├── register_screen.dart  # Register UI
│   │   ├── home_screen.dart      # User list UI
│   │   └── chat_screen.dart      # Chat UI
│   ├── services/
│   │   ├── api_service.dart      # REST API calls
│   │   └── socket_service.dart   # Socket.io connection
│   └── main.dart                 # Entry point
└── pubspec.yaml                  # Flutter dependencies
```

---

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Users
- `GET /api/users` - Get all users (requires auth)

### Messages
- `GET /api/messages/:userId` - Get chat history (requires auth)
- `PUT /api/messages/read/:userId` - Mark messages as read (requires auth)

### Socket Events

**Client → Server:**
- `join` - User joins with userId
- `send_message` - Send new message
- `typing` - User is typing
- `stop_typing` - User stopped typing

**Server → Client:**
- `receive_message` - New message received
- `message_sent` - Message sent confirmation
- `user_online` - User came online
- `user_offline` - User went offline
- `user_typing` - User is typing
- `user_stop_typing` - User stopped typing

---

## Troubleshooting

### Backend Issues

**MongoDB Connection Error:**
```
❌ MongoDB connection error: MongoNetworkError
```
**Solution:**
- Check your MongoDB URI in `.env`
- Verify Network Access allows your IP
- Ensure password doesn't contain special characters (or encode them)

**Port Already in Use:**
```
Error: listen EADDRINUSE: address already in use :::3000
```
**Solution:**
```bash
# Find and kill the process
# Mac/Linux:
lsof -ti:3000 | xargs kill -9

# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Flutter Issues

**Cannot Connect to Backend:**
- Verify backend is running (`curl http://localhost:3000/health`)
- Check API URLs in `api_constants.dart`
- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For real devices, use your computer's IP address
- Check firewall settings

**Socket Connection Failed:**
- Verify Socket.io server is running
- Check Socket URL matches backend URL
- Check console logs for connection errors

**Packages Not Found:**
```bash
flutter clean
flutter pub get
```

**Build Errors:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## Development Tips

### Backend Development
- Use `npm run dev` for auto-reload with nodemon
- Check server logs for debugging
- Use MongoDB Compass to view database visually
- Test API endpoints with Postman or curl

### Flutter Development
- Use `flutter run` in debug mode for hot reload
- Press `r` to hot reload, `R` to hot restart
- Use `print()` statements for debugging
- Check Flutter DevTools for performance

### Testing with Multiple Users
- Use multiple emulators/simulators
- Or use one emulator + one real device
- Or use web version (requires additional setup)

---

## Common Features to Add

Want to extend the app? Here are some ideas:

1. **Group Chats** - Allow multiple users in a conversation
2. **Image Sharing** - Upload and send images
3. **Push Notifications** - Notify users of new messages
4. **Message Search** - Search through chat history
5. **Voice Messages** - Record and send audio
6. **Video Calls** - WebRTC integration
7. **Message Reactions** - React to messages with emojis
8. **User Profiles** - Detailed user information
9. **Dark Mode** - Toggle between light/dark themes
10. **End-to-End Encryption** - Secure messages

---

## Security Considerations for Production

⚠️ **This app is for development/learning purposes. For production:**

1. **Use HTTPS/WSS** - Encrypt all communications
2. **Strengthen JWT Secret** - Use a long, random string
3. **Add Rate Limiting** - Prevent abuse
4. **Validate Input** - Sanitize all user input
5. **Use Environment-Specific URLs** - Different URLs for dev/prod
6. **Add Error Monitoring** - Use Sentry or similar
7. **Implement Logging** - Track errors and usage
8. **Add Tests** - Unit and integration tests
9. **Use CORS Properly** - Restrict to specific domains
10. **Hash Passwords Properly** - Already using bcrypt (good!)

---

## License

MIT License - Feel free to use this project for learning and development!

---

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify all setup steps were completed
3. Check server and Flutter console logs
4. Ensure all dependencies are installed
5. Verify MongoDB connection string is correct

---

## Credits

Built with ❤️ using Flutter, Express.js, Socket.io, and MongoDB Atlas.
