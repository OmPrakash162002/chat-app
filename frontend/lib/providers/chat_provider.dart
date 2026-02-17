import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChatProvider with ChangeNotifier {
  List<User> _users = [];
  List<Message> _messages = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _typingUserId;

  List<User> get users => _users;
  List<Message> get messages => _messages;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get typingUserId => _typingUserId;

  void initialize(String currentUserId) {
    // Listen for new messages
   SocketService().onMessageReceived((message) {
  if (message.senderId != currentUserId) {  // ← Only add from others
    final alreadyExists = _messages.any((m) => m.id == message.id);
    if (!alreadyExists) {
      _messages.add(message);
      notifyListeners();
    }
  }
});

    // Listen for sent message confirmation
  SocketService().onMessageSent((message) {
  _messages.removeWhere(        // ← Remove temp message
    (m) => m.senderId == currentUserId && m.id.length <= 13,
  );
  final alreadyExists = _messages.any((m) => m.id == message.id);
  if (!alreadyExists) {
    _messages.add(message);     // ← Add real server message
  }
  notifyListeners();
});

    // Listen for user online status
    SocketService().onUserOnline((userId) {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(online: true);
        notifyListeners();
      }
    });

    // Listen for user offline status
    SocketService().onUserOffline((userId) {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(online: false);
        notifyListeners();
      }
    });

    // Listen for typing indicator
    SocketService().onUserTyping((userId) {
      if (_selectedUser?.id == userId) {
        _typingUserId = userId;
        notifyListeners();
      }
    });

    // Listen for stop typing
    SocketService().onUserStopTyping((userId) {
      if (_typingUserId == userId) {
        _typingUserId = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await ApiService.getUsers();
    } catch (e) {
      print('Error loading users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectUser(User user) async {
    _selectedUser = user;
    _messages = [];
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await ApiService.getMessages(user.id);
      await ApiService.markMessagesAsRead(user.id);
    } catch (e) {
      print('Error loading messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void sendMessage(String currentUserId, String content) {
    if (_selectedUser == null || content.trim().isEmpty) return;

    // Add message optimistically
    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      receiverId: _selectedUser!.id,
      content: content,
      createdAt: DateTime.now(),
    );

    _messages.add(tempMessage);
    notifyListeners();

    // Send via socket
    SocketService().sendMessage(
      senderId: currentUserId,
      receiverId: _selectedUser!.id,
      content: content,
    );
  }

  void emitTyping(String currentUserId) {
    if (_selectedUser != null) {
      SocketService().emitTyping(currentUserId, _selectedUser!.id);
    }
  }

  void emitStopTyping(String currentUserId) {
    if (_selectedUser != null) {
      SocketService().emitStopTyping(currentUserId, _selectedUser!.id);
    }
  }

  void clearChat() {
    _selectedUser = null;
    _messages = [];
    _typingUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService().removeAllListeners();
    super.dispose();
  }
}
