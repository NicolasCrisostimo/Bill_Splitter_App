# Divisor de Contas

Um aplicativo multiplataforma, desenvolvido com **Flutter**, para gerenciar e dividir despesas compartilhadas com amigos. O aplicativo funciona offline, salvando todos os dados localmente no dispositivo.

---

## Funcionalidades

* **Autenticação de Usuários**: Sistema completo de login e cadastro com validações de formulário.
* **Armazenamento Local**: Dados de usuários e dívidas são salvos em arquivos CSV, garantindo que o app funcione sem conexão com a internet.
* **Gestão de Dívidas**: Crie e gerencie dívidas compartilhadas entre você e um amigo.
* **Lançamento de Despesas**: Adicione despesas com descrição, valor, categoria e a pessoa que pagou.
* **Cálculo de Saldo Automático**: O aplicativo calcula e exibe automaticamente o saldo entre os usuários.
* **Visualização com Gráficos**: Analise seus gastos com gráficos de pizza (por categoria) e de barras (por mês).
* **Gestão de Categorias**: Crie e personalize categorias para organizar suas despesas.
* **Exclusão de Dados**: Remova despesas individuais (arrastando para o lado) ou dívidas inteiras.
* **Interface Moderna**: Design limpo e intuitivo para uma ótima experiência do usuário.

---

## Tecnologias e Pacotes

Este projeto foi construído usando as seguintes tecnologias e pacotes:

* **Flutter & Dart**
* **csv**: Para manipulação de arquivos CSV.
* **path_provider**: Para encontrar e gerenciar diretórios no dispositivo.
* **fl_chart**: Para a criação dos gráficos.
* **intl**: Para formatação de datas e valores monetários.

---

## Estrutura do Projeto

O projeto segue uma arquitetura de camadas inspirada no padrão MVVM (Model-View-ViewModel), com uma clara separação de responsabilidades:

* `/lib/models`: Contém as classes de dados (`User`, `Debt`, `Expense`).
* `/lib/services`: Contém a lógica de negócios e o gerenciamento de estado (`AuthService`, `DataService`).
* `/lib/screens`: Contém os widgets que compõem a interface do usuário (UI).

---

## Como Executar o Projeto

Siga os passos abaixo para executar o projeto em sua máquina local.

**Pré-requisitos:**

* SDK do Flutter instalado.
* Um emulador/simulador ou dispositivo físico configurado.

**Passos:**

1.  Clone o repositório:

    git clone [https://github.com/seu-usuario/nome-do-repositorio.git](https://github.com/seu-usuario/nome-do-repositorio.git)


2.  Acesse a pasta do projeto:

    cd nome-do-repositorio


3.  Instale as dependências:

    flutter pub get
    

4.  Execute o aplicativo:

    flutter run
    
---

## Telas

* Tela de Login
* Tela Principal
* Tela de Detalhes
* Tela de Gráficos

---

## Melhorias Futuras

* Migrar o armazenamento de dados de CSV para um banco de dados local (SQLite) ou em nuvem (Firebase).
* Adicionar sincronização de dados entre dispositivos.
* Implementar notificações push para lembretes de dívidas.
* Permitir a divisão de despesas em grupos com mais de duas pessoas.
* Adicionar um tema escuro (Dark Mode).