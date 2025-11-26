import 'package:dio/dio.dart';
import 'package:CineLog/constants.dart';
import 'package:CineLog/services/auth_service.dart';

class DioService {
  static final DioService _instance = DioService._internal();

  late Dio _dio;

  DioService._internal() {
    _dio = Dio(BaseOptions(baseUrl: API_BASE_URL));
    
    // Adiciona interceptador para incluir o token em todas as requisições
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Obtém o token armazenado
          final token = await AuthService.getToken();
          
          if (token != null) {
            // Adiciona o token no header Authorization
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) {
          // Trata erros de autenticação (token expirado, inválido, etc)
          if (error.response?.statusCode == 401) {
            print('Token inválido ou expirado');
            // Poderia redirecionar para login aqui
          }
          return handler.next(error);
        },
      ),
    );
  }

  factory DioService() {
    return _instance;
  }

  Dio get dio => _dio;
}
