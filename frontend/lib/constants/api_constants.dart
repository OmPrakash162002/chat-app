class ApiConstants {
  // Change this to your backend URL
  static const String baseUrl = 'https://chat-app-production-029d.up.railway.app'; // For Android Emulator use: http://10.0.2.2:3000
  static const String socketUrl = 'https://chat-app-production-029d.up.railway.app'; // For Android Emulator use: http://10.0.2.2:3000
  
  // API Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String users = '/api/users';
  static String messages(String userId) => '/api/messages/$userId';
  static String markRead(String userId) => '/api/messages/read/$userId';
}
