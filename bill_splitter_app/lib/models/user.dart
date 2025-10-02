/// A classe User serve como um "molde" ou "planta" para um objeto de usuário.
/// Ela define quais informações (propriedades) todo usuário no sistema terá.
class User {
  // 'final' indica que, uma vez que um objeto User é criado, essas propriedades não podem ser alteradas.
  final String id;
  final String name;
  final String email;
  final String password; // Em um app real, isso seria um hash, não a senha em texto plano.

  /// O construtor é usado para criar uma nova instância (objeto) da classe User.
  /// 'required' significa que todos esses parâmetros devem ser fornecidos ao criar um usuário.
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}

