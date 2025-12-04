import 'package:flutter/foundation.dart';
import '../models/usuario/usuario.dart';
import '../services/dao/usuario_dao.dart';

//gerenciar estado do usuario

class UsuarioViewModel extends ChangeNotifier {
  final UsuarioDao _usuarioDao = UsuarioDao();
  Usuario? _usuarioAtual;

  //Verifica usuario logado e retorna usuario atual

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get isLogado => _usuarioAtual != null;

//Validação por email e senha
//Retorna true se sucesso, false se falha
  Future<bool> login(String email, String senha) async {
    try {
      print('Tentando login para: $email');
      final usuario = await _usuarioDao.findByEmail(email);
      print('Usuário encontrado: ${usuario != null ? usuario.nome : 'null'}');

      if (usuario != null) {
        print('Senha fornecida: $senha');
        print('Senha no banco: ${usuario.senha}');

        if (usuario.senha == senha) {
          _usuarioAtual = usuario;
          notifyListeners();
          print('Login bem-sucedido!');
          return true;
        } else {
          print('Senha incorreta');
        }
      } else {
        print('Usuário não encontrado');
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
      return false;
    }
  }

//Cadastro de novo usuario
//Retorna true se sucesso, false se falha (email ja existe)
  Future<bool> cadastrar(Usuario usuario) async {
    try {
      print('Tentando cadastrar usuário: ${usuario.email}');

      // Verifica se já existe usuário com este email
      final usuarioExistente = await _usuarioDao.findByEmail(usuario.email);

      if (usuarioExistente != null) {
        print('Email já existe: ${usuarioExistente.email}');
        return false; // Email já cadastrado
      }

      print('Criando novo usuário...');
      final id = await _usuarioDao.create(usuario);
      usuario.id = id;
      _usuarioAtual = usuario;
      print('Usuário criado com ID: $id');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao cadastrar: $e');
      return false;
    }
  }

//Encerra sessão do usuario atual
  void logout() {
    _usuarioAtual = null;
    notifyListeners();
  }

//Atualiza dados do usuario atual try/catch para capturar erros
  Future<void> atualizarUsuario(Usuario usuario) async {
    try {
      await _usuarioDao.update(usuario);
      _usuarioAtual = usuario;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
    }
  }
}
