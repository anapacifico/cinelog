import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_project/services/auth_service.dart';
import 'package:to_do_project/services/dio_service.dart';
import 'package:to_do_project/pages/login.dart';
import 'package:to_do_project/models/movie.dart';
import 'package:to_do_project/pages/movie.detail.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<Movie> _filmesCriados = [];
  bool _carregandoFilmes = false;
  int _paginaAtual = 0;
  int _totalPaginas = 0;
  final _dioService = DioService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
      _carregarFilmesCriados();
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarFilmesCriados({int pagina = 0}) async {
    if (_userData == null) return;
    
    try {
      setState(() => _carregandoFilmes = true);
      
      final userId = _userData!['idUser']?.toString();
      if (userId == null) return;

      final response = await _dioService.dio.get(
        '/api/filmes/adicionados/$userId',
        queryParameters: {
          'page': pagina,
          'size': 5,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> filmes = data['content'] ?? [];
        
        setState(() {
          _filmesCriados = filmes
              .map((filme) => Movie.fromJson(filme as Map<String, dynamic>))
              .toList();
          _paginaAtual = data['pageable']?['pageNumber'] ?? 0;
          _totalPaginas = data['totalPages'] ?? 1;
          _carregandoFilmes = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar filmes criados: $e');
      setState(() => _carregandoFilmes = false);
    }
  }

  Future<void> _deletarFilme(int filmeId) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Deletar Filme', 
              style: TextStyle(color: Colors.white)),
          content: const Text('Tem certeza que deseja deletar este filme?',
              style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', 
                  style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deletar',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final response = await _dioService.dio.delete('/api/filmes/$filmeId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Filme deletado com sucesso!'),
            backgroundColor: Colors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
        _carregarFilmesCriados(pagina: _paginaAtual);
      }
    } catch (e) {
      print('Erro ao deletar filme: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar filme: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.clearAuth();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String username = _userData?['username'] ?? 'Usuário';
    final String userInitial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 216, 21, 7)))
          : _userData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                      const SizedBox(height: 16),
                      const Text('Erro ao carregar perfil', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color.fromARGB(255, 216, 21, 7), Color.fromARGB(255, 180, 15, 5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 216, 21, 7).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userInitial,
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData!['email'] ?? 'email@naoencontrado.com',
                        style: TextStyle(
                          color: Colors.grey[400], 
                          fontSize: 14
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildDarkInfoCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _userData!['email'] ?? 'N/A',
                      ),
                      
                      const SizedBox(height: 16),

                      _buildDarkInfoCard(
                        icon: Icons.fingerprint,
                        label: 'ID do Usuário',
                        value: _userData!['idUser']?.toString() ?? 'N/A',
                        isCopyable: true,
                      ),

                      const SizedBox(height: 50),

                      _buildFilmesAdicionadosSection(),

                      const SizedBox(height: 50),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sair da Conta', style: TextStyle(fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFilmesAdicionadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Filmes Adicionados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_filmesCriados.isNotEmpty)
              Text(
                '${_paginaAtual + 1}/${_totalPaginas}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_carregandoFilmes && _filmesCriados.isEmpty)
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(color: Color.fromARGB(255, 216, 21, 7)),
                const SizedBox(height: 12),
                Text(
                  'Carregando filmes...',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          )
        else if (_filmesCriados.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: [
                Icon(Icons.movie_outlined, color: Colors.grey[600], size: 48),
                const SizedBox(height: 12),
                Text(
                  'Nenhum filme adicionado ainda',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filmesCriados.length,
                itemBuilder: (context, index) {
                  final filme = _filmesCriados[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(movie: filme),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.network(
                              filme.backdropUrl,
                              width: 110,
                              height: 62,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 110,
                                height: 62,
                                color: Colors.black54,
                                child: const Icon(Icons.broken_image_outlined,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filme.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        filme.averageRating
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.favorite,
                                          color: Colors.redAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        filme.likes.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: Colors.grey[900],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deletarFilme(filme.id);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Deletar',
                                      style:
                                          TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_paginaAtual > 0)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _carregarFilmesCriados(pagina: _paginaAtual - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 216, 21, 7),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 216, 21, 7), width: 1),
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (_paginaAtual < _totalPaginas - 1)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _carregarFilmesCriados(pagina: _paginaAtual + 1),
                      label: const Text('Próximo'),
                      icon: const Icon(Icons.arrow_forward),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 216, 21, 7),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 216, 21, 7), width: 1),
                      ),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDarkInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Card escuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!), // Borda sutil
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color.fromARGB(255, 216, 21, 7), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCopyable)
            IconButton(
              icon: Icon(Icons.copy, color: Colors.grey[600], size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ID copiado!'),
                    backgroundColor: Color.fromARGB(255, 216, 21, 7),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
