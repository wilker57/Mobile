# Documentação Técnica - Sistema de Controle de Despesas Pessoais

## Índice
1. [Visão Geral](#visão-geral)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Regras de Negócio](#regras-de-negócio)
4. [Estrutura de Dados](#estrutura-de-dados)
5. [Fluxo de Navegação](#fluxo-de-navegação)
6. [Gerenciamento de Estado](#gerenciamento-de-estado)
7. [Inicialização do Sistema](#inicialização-do-sistema)
8. [Validação e Autenticação](#validação-e-autenticação)
9. [Funcionalidades Principais](#funcionalidades-principais)
10. [Padrões de Implementação](#padrões-de-implementação)

## Visão Geral

O Sistema de Controle de Despesas Pessoais é uma aplicação Flutter desenvolvida seguindo o padrão arquitetural MVVM (Model-View-ViewModel) com gerenciamento de estado Provider. O sistema permite que usuários controlem suas finanças pessoais através do registro de receitas, despesas, categorização e visualização de relatórios com gráficos.

### Tecnologias Utilizadas
- **Framework**: Flutter 
- **Linguagem**: Dart
- **Banco de Dados**: SQLite (sqflite para mobile, sqflite_common_ffi para desktop)
- **Gerenciamento de Estado**: Provider
- **Gráficos**: fl_chart
- **Internacionalização**: intl (pt_BR)
- **Tipografia**: Google Fonts

## Arquitetura do Sistema

### Padrão MVVM
O sistema implementa o padrão MVVM dividindo as responsabilidades em:

#### Model (Modelos)
- **Usuario**: Representa dados do usuário
- **Receita**: Representa entradas financeiras
- **Despesa**: Representa saídas financeiras com suporte a parcelamento
- **Categoria**: Representa categorização de receitas/despesas

#### View (Visualizações)
- **LoginView**: Tela de autenticação
- **CadastroView**: Tela de registro de novo usuário
- **HomeView**: Dashboard principal
- **Formulários**: Adicionar/Editar receitas e despesas
- **Listas**: Visualização de receitas e despesas
- **RelatoriosView**: Gráficos e análises

#### ViewModel (Controladores)
- **UsuarioViewModel**: Gerenciamento de autenticação e sessão
- **ReceitaViewModel**: Operações CRUD de receitas
- **DespesaViewModel**: Operações CRUD de despesas
- **CategoriaViewModel**: Gerenciamento de categorias
- **SaldoViewModel**: Cálculos financeiros

### Estrutura de Diretórios
```
lib/
├── main.dart                    # Ponto de entrada e configuração
├── exports.dart                 # Exports centralizados
├── models/                      # Modelos de dados
│   ├── usuario/
│   ├── receita/
│   ├── despesa/
│   └── categoria/
├── mvvm/                        # ViewModels
├── pages/                       # Telas da aplicação
├── services/                    # Serviços de infraestrutura
│   ├── database_helper.dart     # Configuração do banco
│   └── dao/                     # Data Access Objects
└── finance/                     # Regras de negócio específicas
```

## Regras de Negócio

### Autenticação e Usuários
1. **Cadastro de Usuário**:
   - Email deve ser único no sistema
   - Senha armazenada em texto simples (sem criptografia)
   - Data de criação automática
   - Validação obrigatória de nome, email e senha

2. **Login**:
   - Autenticação por email e senha
   - Sessão mantida durante execução da aplicação
   - Logout limpa dados da sessão

### Categorias
1. **Criação**:
   - Cada categoria pertence a um usuário específico
   - Tipos suportados: "receita" ou "despesa"
   - Nome obrigatório e único por usuário

2. **Utilização**:
   - Receitas e despesas podem ser associadas a categorias
   - Categoria opcional (pode ser null)
   - Categorias não podem ser deletadas se possuem transações associadas

### Receitas
1. **Registro**:
   - Valor sempre positivo
   - Data obrigatória
   - Descrição obrigatória
   - Categoria opcional
   - Data de criação automática

2. **Validações**:
   - Valor deve ser maior que zero
   - Data não pode ser futura (validação no frontend)
   - Descrição não pode ser vazia

### Despesas
1. **Tipos de Pagamento**:
   - **À Vista**: Pagamento único
   - **Parcelado**: Dividido em múltiplas parcelas

2. **Sistema de Parcelamento**:
   - Número máximo de parcelas: 24
   - Valor total dividido igualmente entre parcelas
   - Cada parcela é uma entrada separada no banco
   - Data de vencimento calculada mensalmente
   - Numeração sequencial das parcelas (1/N, 2/N, etc.)

3. **Validações**:
   - Valor deve ser maior que zero
   - Parcelas devem ser entre 1 e 24
   - Data não pode ser futura
   - Descrição obrigatória

### Cálculos Financeiros
1. **Saldo Atual**:
   ```dart
   Saldo = Total de Receitas - Total de Despesas
   ```

2. **Totais**:
   - Total de receitas: soma de todas as receitas do usuário
   - Total de despesas: soma de todas as despesas do usuário
   - Cálculos em tempo real

## Estrutura de Dados

### Esquema do Banco de Dados (Versão 6)

#### Tabela Usuario
```sql
CREATE TABLE Usuario (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  senha TEXT NOT NULL,
  dataCriacao TEXT NOT NULL
)
```

#### Tabela Categoria
```sql
CREATE TABLE Categoria (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL,
  usuarioId INTEGER,
  FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
)
```

#### Tabela Receita
```sql
CREATE TABLE Receita (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  descricao TEXT NOT NULL,
  valor REAL NOT NULL,
  data TEXT NOT NULL,
  categoriaId INTEGER,
  usuarioId INTEGER,
  dataCriacao TEXT NOT NULL,
  FOREIGN KEY (categoriaId) REFERENCES Categoria(id),
  FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
)
```

#### Tabela Despesa
```sql
CREATE TABLE Despesa (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  descricao TEXT NOT NULL,
  valor REAL NOT NULL,
  data TEXT NOT NULL,
  categoriaId INTEGER,
  usuarioId INTEGER,
  dataCriacao TEXT NOT NULL,
  pagamentoTipo TEXT NOT NULL DEFAULT 'AVISTA',
  parcelasTotal INTEGER NOT NULL DEFAULT 1,
  parcelaNumero INTEGER DEFAULT 1,
  FOREIGN KEY (categoriaId) REFERENCES Categoria(id),
  FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
)
```

### Migração de Dados
O sistema implementa migração automática do banco de dados através do método `onUpgrade`, suportando:
- Versão 1→2: Criação da tabela Categoria
- Versão 2→3: Adição da coluna tipo na tabela Categoria
- Versão 3→4: Adição da coluna usuarioId na tabela Categoria
- Versão 4→5: Adição da coluna dataCriacao na tabela Usuario
- Versão 5→6: Adição de colunas de parcelamento nas tabelas Receita e Despesa

## Fluxo de Navegação

### Inicialização
```dart
main() → MyApp() → LoginView()
```

### Após Login Bem-sucedido
```dart
LoginView → HomeView (Dashboard)
```

### Navegação Principal (BottomNavigationBar)
1. **Home** (0): Dashboard principal
2. **Receita** (1): Lista de receitas
3. **Despesa** (2): Lista de despesas  
4. **Categoria** (3): Gerenciamento de categorias
5. **Relatórios** (4): Gráficos e análises

### Drawer Navigation
- Receitas → ReceitaListView
- Despesas → DespesaListView
- Categorias → CategoriaView
- Relatórios → RelatoriosView
- Configurações → (Não implementado)
- Sair → Logout + LoginView

### Fluxos de CRUD
#### Adicionar Nova Receita
```dart
HomeView → AdicionarReceitaView → [Salvar] → HomeView
```

#### Editar Receita Existente
```dart
ReceitaListView → [Edit Button] → EditarReceitaView → [Salvar] → ReceitaListView
```

#### Adicionar Nova Despesa
```dart
HomeView → AdicionarDespesaView → [Configurar Parcelamento?] → [Salvar] → HomeView
```

## Gerenciamento de Estado

### Provider Pattern
O sistema utiliza o padrão Provider para gerenciamento de estado reativo:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UsuarioViewModel()),
    ChangeNotifierProvider(create: (_) => ReceitaViewModel()),
    ChangeNotifierProvider(create: (_) => DespesaViewModel()),
    ChangeNotifierProvider(create: (_) => CategoriaViewModel()),
    ChangeNotifierProvider(create: (_) => SaldoViewModel()),
  ],
  child: MaterialApp(...)
)
```

### Ciclo de Vida dos ViewModels
1. **Inicialização**: Provider cria instância do ViewModel
2. **Configuração**: `setUsuario(userId)` vincula dados ao usuário logado
3. **Carregamento**: `carregar*()` busca dados do banco
4. **Notificação**: `notifyListeners()` atualiza UI
5. **Operações**: CRUD operations com notificação automática

### Padrão de Atualização
```dart
// Exemplo em UsuarioViewModel
Future<bool> login(String email, String senha) async {
  // Lógica de autenticação
  _usuarioAtual = usuario;
  notifyListeners(); // Notifica mudança de estado
  return true;
}
```

## Inicialização do Sistema

### Configuração da Aplicação (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuração SQLite para desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const MyApp());
}
```

### Inicialização do Banco de Dados
1. **Verificação de Plataforma**: Desktop vs Mobile
2. **Configuração SQLite**: sqflite_common_ffi para desktop
3. **Path do Banco**: `getDatabasesPath()` + 'despesa_pessoal.db'
4. **Criação/Migração**: Automática via `onCreate`/`onUpgrade`

### Configuração do Tema
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
  textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
)
```

## Validação e Autenticação

### Sistema de Autenticação
#### Processo de Login
```dart
Future<bool> login(String email, String senha) async {
  try {
    // 1. Buscar usuário por email
    final usuario = await _usuarioDao.findByEmail(email);
    
    // 2. Verificar se usuário existe
    if (usuario != null) {
      // 3. Validar senha (comparação direta)
      if (usuario.senha == senha) {
        // 4. Definir usuário atual e notificar
        _usuarioAtual = usuario;
        notifyListeners();
        return true;
      }
    }
    return false;
  } catch (e) {
    return false;
  }
}
```

#### Processo de Cadastro
```dart
Future<bool> cadastrar(Usuario usuario) async {
  try {
    // 1. Verificar se email já existe
    final usuarioExistente = await _usuarioDao.findByEmail(usuario.email);
    
    if (usuarioExistente != null) {
      return false; // Email já cadastrado
    }
    
    // 2. Criar novo usuário
    final id = await _usuarioDao.create(usuario);
    usuario.id = id;
    
    // 3. Definir como usuário atual
    _usuarioAtual = usuario;
    notifyListeners();
    return true;
  } catch (e) {
    return false;
  }
}
```

### Validação de Formulários
#### Validação de Email
```dart
String? _validarEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email é obrigatório';
  }
  if (!value.contains('@')) {
    return 'Email inválido';
  }
  return null;
}
```

#### Validação de Valor Monetário
```dart
String? _validarValor(String? value) {
  if (value == null || value.isEmpty) {
    return 'Valor é obrigatório';
  }
  final valor = double.tryParse(value.replaceAll(',', '.'));
  if (valor == null || valor <= 0) {
    return 'Valor deve ser maior que zero';
  }
  return null;
}
```

## Funcionalidades Principais

### 1. Dashboard (HomeView)
#### Componentes Principais
- **Card de Saldo**: Exibe saldo atual (receitas - despesas)
- **Acessos Rápidos**: Botões para adicionar receita/despesa
- **Gastos por Categoria**: Gráfico de barras com percentuais

#### Cálculo do Saldo
```dart
Widget build(BuildContext context) {
  return FutureBuilder<List<double>>(
    future: Future.wait([receitaVM.totalReceitas, despesaVM.totalDespesas]),
    builder: (context, snapshot) {
      final receitas = snapshot.data?[0] ?? 0.0;
      final despesas = snapshot.data?[1] ?? 0.0;
      final saldo = saldoVM.calcularSaldoAtual(receitas, despesas);
      // UI do saldo
    },
  );
}
```

### 2. Sistema de Parcelamento
#### Interface de Criação
```dart
Row(
  children: [
    Radio<String>(
      value: 'AVISTA',
      groupValue: _pagamentoTipo,
      onChanged: (value) => setState(() => _pagamentoTipo = value!),
    ),
    Text('À Vista'),
    Radio<String>(
      value: 'PARCELADO',
      groupValue: _pagamentoTipo,
      onChanged: (value) => setState(() => _pagamentoTipo = value!),
    ),
    Text('Parcelado'),
  ],
)
```

#### Lógica de Parcelamento
```dart
Future<void> _salvarDespesa() async {
  if (_pagamentoTipo == 'PARCELADO') {
    final valorParcela = _valor / _numeroParcelas;
    
    for (int i = 1; i <= _numeroParcelas; i++) {
      final dataVencimento = DateTime(
        _data.year,
        _data.month + (i - 1),
        _data.day,
      );
      
      final despesa = Despesa(
        descricao: '${_descricao} (${i}/${_numeroParcelas})',
        valor: valorParcela,
        data: dataVencimento,
        pagamentoTipo: 'PARCELADO',
        parcelasTotal: _numeroParcelas,
        parcelaNumero: i,
        // outros campos...
      );
      
      await despesaViewModel.adicionarDespesa(despesa);
    }
  }
}
```

### 3. Gráficos e Relatórios
#### Implementação com fl_chart
```dart
PieChart(
  PieChartData(
    sections: _buildPieChartSections(),
    centerSpaceRadius: 60,
    sectionsSpace: 2,
  ),
)

List<PieChartSectionData> _buildPieChartSections() {
  final Map<String, double> categoriaValores = {};
  // Agrupar despesas por categoria
  for (final despesa in despesas) {
    final categoria = // buscar categoria
    categoriaValores[categoria.nome] = 
        (categoriaValores[categoria.nome] ?? 0) + despesa.valor;
  }
  // Converter para PieChartSectionData
}
```

### 4. Filtros por Período
#### Implementação de Filtros
```dart
enum PeriodoFiltro { mes, trimestre, semestre, ano }

List<Despesa> _filtrarPorPeriodo(List<Despesa> despesas, PeriodoFiltro filtro) {
  final agora = DateTime.now();
  final inicio = _calcularInicioPerido(filtro, agora);
  
  return despesas.where((despesa) => 
    despesa.data.isAfter(inicio) && despesa.data.isBefore(agora)
  ).toList();
}
```

## Padrões de Implementação

### 1. Padrão DAO (Data Access Object)
```dart
class UsuarioDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.insert('Usuario', usuario.toMap());
  }

  Future<Usuario?> findByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query('Usuario', where: 'email = ?', whereArgs: [email]);
    return maps.isNotEmpty ? Usuario.fromMap(maps.first) : null;
  }
}
```

### 2. Padrão Singleton (DatabaseHelper)
```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
}
```

### 3. Padrão Factory (Model Constructors)
```dart
class Despesa {
  // Constructor padrão
  Despesa({required this.descricao, required this.valor, ...});

  // Factory constructor para Map
  factory Despesa.fromMap(Map<String, dynamic> map) {
    return Despesa(
      id: map['id'],
      descricao: map['descricao'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
      // outros campos...
    );
  }
}
```

### 4. Padrão Observer (Provider/ChangeNotifier)
```dart
class DespesaViewModel extends ChangeNotifier {
  List<Despesa> _despesas = [];
  
  Future<void> adicionarDespesa(Despesa despesa) async {
    await _despesaDao.create(despesa);
    await carregarDespesas(); // Recarrega lista
    notifyListeners(); // Notifica observers
  }
}
```

### 5. Tratamento de Erros
```dart
Future<bool> operacao() async {
  try {
    // Lógica da operação
    return true;
  } catch (e) {
    debugPrint('Erro na operação: $e');
    return false;
  }
}
```

### 6. Formatação de Dados
```dart
// Formatação monetária
final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final valorFormatado = formatter.format(valor);

// Formatação de data
final dataFormatada = DateFormat('dd/MM/yyyy').format(data);
```

## Considerações de Segurança

### Limitações Atuais
1. **Senhas em Texto Simples**: Sistema não implementa criptografia
2. **Validação Cliente**: Validações apenas no frontend
3. **Sessão Local**: Dados de sessão perdidos ao fechar app

### Recomendações para Produção
1. Implementar hash de senhas (bcrypt, SHA-256)
2. Validação server-side
3. Token de autenticação persistente
4. Criptografia de dados sensíveis no SQLite

## Conclusão

Este sistema implementa uma arquitetura sólida baseada no padrão MVVM com Provider para gerenciamento de estado. A separação clara de responsabilidades entre Model, View e ViewModel facilita manutenção e evolução. O suporte completo a operações CRUD, sistema de parcelamento avançado e interface intuitiva oferecem uma experiência completa para controle de despesas pessoais.

A implementação de gráficos interativos, filtros por período e dashboard informativo proporcionam insights valiosos sobre o comportamento financeiro do usuário, tornando a aplicação uma ferramenta útil para gestão financeira pessoal.