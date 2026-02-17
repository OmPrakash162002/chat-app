import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';
import '../models/message.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String userId) {
    if (_socket != null && _isConnected) {
      print('Socket already connected');
      return;
    }

    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _isConnected = true;
      _socket!.emit('join', userId);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('Connection Error: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('Socket Error: $error');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
    }
  }

  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('send_message', {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'type': type,
      });
    }
  }

  void onMessageReceived(Function(Message) callback) {
    _socket?.on('receive_message', (data) {
      final message = Message.fromJson(data);
      callback(message);
    });
  }

  void onMessageSent(Function(Message) callback) {
    _socket?.on('message_sent', (data) {
      final message = Message.fromJson(data);
      callback(message);
    });
  }

  void onUserOnline(Function(String userId) callback) {
    _socket?.on('user_online', (data) {
      callback(data['userId']);
    });
  }

  void onUserOffline(Function(String userId) callback) {
    _socket?.on('user_offline', (data) {
      callback(data['userId']);
    });
  }

  void onUserTyping(Function(String userId) callback) {
    _socket?.on('user_typing', (data) {
      callback(data['userId']);
    });
  }

  void onUserStopTyping(Function(String userId) callback) {
    _socket?.on('user_stop_typing', (data) {
      callback(data['userId']);
    });
  }

  void emitTyping(String senderId, String receiverId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing', {
        'senderId': senderId,
        'receiverId': receiverId,
      });
    }
  }

  void emitStopTyping(String senderId, String receiverId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('stop_typing', {
        'senderId': senderId,
        'receiverId': receiverId,
      });
    }
  }

  void removeAllListeners() {
    _socket?.off('receive_message');
    _socket?.off('message_sent');
    _socket?.off('user_online');
    _socket?.off('user_offline');
    _socket?.off('user_typing');
    _socket?.off('user_stop_typing');
  }
}
