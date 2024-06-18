import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class TelaConfiguracoes extends StatelessWidget {
  final String uid;

  const TelaConfiguracoes({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        centerTitle: true,
        backgroundColor: Color(0xFF310E3E), // Cor da barra de navegação
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 20),
          _buildTituloSecao(context, 'Configurações da Conta'),
          _buildItemLista(context, 'Alterar Senha', Icons.lock, () {
            _navegarParaAlterarSenha(context);
          }),
          _buildItemLista(context, 'Excluir Conta', Icons.delete, () {
            _exibirDialogoConfirmacaoExclusao(context);
          }),
        ],
      ),
    );
  }

  Widget _buildTituloSecao(BuildContext context, String titulo) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF310E3E), // Cor do título da seção
        ),
      ),
    );
  }

  Widget _buildItemLista(BuildContext context, String titulo, IconData icone, Function() onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF310E3E).withOpacity(0.3), // Sombra mais suave
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF310E3E), // Cor do texto
          ),
        ),
        leading: Icon(icone, color: Color(0xFF310E3E)), // Cor do ícone
        onTap: onTap,
      ),
    );
  }

  void _navegarParaAlterarSenha(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaAlterarSenha(uid: uid),
      ),
    );
  }

  void _exibirDialogoConfirmacaoExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Excluir Conta"),
          content: Text("Tem certeza de que deseja excluir sua conta?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _excluirConta(context);
              },
              child: Text(
                "Excluir",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _excluirConta(BuildContext context) async {
    try {
      // Excluir o documento do usuário da coleção 'users'
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      
      // Deslogar o usuário
      await auth.FirebaseAuth.instance.signOut();

      // Fechar diálogo
      Navigator.pop(context);
      
      // Adicionar lógica adicional, se necessário
    } catch (error) {
      print("Erro ao excluir conta: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao excluir conta. Por favor, tente novamente mais tarde.')),
      );
    }
  }
}

class TelaAlterarSenha extends StatefulWidget {
  final String uid;

  const TelaAlterarSenha({Key? key, required this.uid}) : super(key: key);

  @override
  _TelaAlterarSenhaState createState() => _TelaAlterarSenhaState();
}

class _TelaAlterarSenhaState extends State<TelaAlterarSenha> {
  final TextEditingController _senhaAntigaController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<void> _alterarSenha() async {
    try {
      String email = _auth.currentUser!.email!;
      String senhaAntiga = _senhaAntigaController.text.trim();
      String novaSenha = _novaSenhaController.text.trim();

      auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senhaAntiga,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updatePassword(novaSenha);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senha atualizada com sucesso')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      print("Erro ao atualizar a senha: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao atualizar senha. Por favor, tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alterar Senha'),
        backgroundColor: Color(0xFF310E3E), // Cor da barra de navegação
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _senhaAntigaController,
              decoration: InputDecoration(
                labelText: 'Senha Antiga',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _novaSenhaController,
              decoration: InputDecoration(
                labelText: 'Nova Senha',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _alterarSenha,
              child: Text('Salvar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF310E3E), // Cor do texto do botão
              ),
            ),
          ],
        ),
      ),
    );
  }
}
