import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:CineLog/constants.dart';

class AuthService {
  static const String _baseUrl = AUTH_BASE_URL;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print("Token salvo com sucesso!");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    print("User ID salvo com sucesso!");
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
    print("Dados de autenticação limpos");
  }

  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  static Future<Map<String, dynamic>> login({
    required String login,
    required String senha,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    print("=== INICIANDO LOGIN ===");
    print("URL: $url");

    try {
      print("Enviando requisição POST...");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'password': senha,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("TIMEOUT: Requisição demorou mais de 10 segundos!");
          throw Exception('Timeout na conexão com a API');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dados = jsonDecode(response.body);
        final token = dados['token'] ?? dados['access_token'] ?? '';

        if (token.isEmpty) {
          return {'sucesso': false, 'mensagem': 'Token não fornecido pela API'};
        }

        await _saveToken(token);

        final userId = dados['idUser'] ?? '';
        if (userId.isNotEmpty) {
          await _saveUserId(userId);
        }

        await _saveUserData(dados);

        return {'sucesso': true, 'mensagem': 'Login realizado'};
      } else {
        final dados = jsonDecode(response.body);
        return {
          'sucesso': false,
          'mensagem': dados['error'] ?? 'Erro no servidor'
        };
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexão: $e'};
    }
  }


}
