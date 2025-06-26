# Gestão CBM-GO

Sistema de gestão para o Corpo de Bombeiros Militar de Goiás, desenvolvido em Flutter.

## 📱 Sobre o Projeto

O **Gestão CBM-GO** é um aplicativo móvel e web desenvolvido para facilitar a gestão operacional do Corpo de Bombeiros Militar de Goiás. O sistema oferece funcionalidades para:

- 🏠 **Dashboard Principal** - Visão geral das operações
- 📦 **Gestão de Almoxarifado** - Controle completo de estoque
- 🚗 **Gestão de Frota** - Controle de veículos e equipamentos
- 🔍 **Vistorias** - Sistema de inspeções e vistorias
- 🛠️ **Serviços Terceirizados** - Gestão de serviços externos
- 🔔 **Notificações** - Sistema de alertas e comunicações

## 🏗️ Funcionalidades Implementadas

### Gestão de Almoxarifado
- ✅ **Dashboard de Estoque** - Visão geral com estatísticas
- ✅ **Cadastro de Produtos** - Registro completo de itens
- ✅ **Lista de Produtos** - Visualização e busca de produtos
- ✅ **Movimentação de Estoque** - Controle de entradas e saídas
- ✅ **Controle de Estoque Crítico** - Alertas de estoque baixo
- ✅ **Filtros e Busca** - Localização rápida de produtos

### Recursos Técnicos
- ✅ **Firebase Integration** - Backend em nuvem
- ✅ **Firestore Database** - Banco de dados NoSQL
- ✅ **Responsive Design** - Interface adaptável
- ✅ **Navigation System** - Navegação intuitiva
- ✅ **State Management** - Gerenciamento de estado com Riverpod

## 🚀 Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Dart** - Linguagem de programação
- **Firebase** - Backend as a Service
- **Firestore** - Banco de dados NoSQL
- **Riverpod** - Gerenciamento de estado
- **Go Router** - Navegação
- **Material Design** - Interface do usuário

## 📋 Pré-requisitos

- Flutter SDK (versão 3.0 ou superior)
- Dart SDK
- Android Studio / VS Code
- Conta no Firebase
- Git

## 🔧 Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/gestaocbmgo.git
   cd gestaocbmgo
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
   - Adicione seu app Android/iOS/Web
   - Baixe os arquivos de configuração:
     - `google-services.json` (Android)
     - `GoogleService-Info.plist` (iOS)
   - Configure o Firestore Database

4. **Execute o aplicativo**
   ```bash
   flutter run
   ```

## 📱 Plataformas Suportadas

- ✅ **Android** - Aplicativo nativo
- ✅ **iOS** - Aplicativo nativo
- ✅ **Web** - Progressive Web App
- ✅ **Windows** - Aplicativo desktop
- ✅ **macOS** - Aplicativo desktop
- ✅ **Linux** - Aplicativo desktop

## 🏗️ Estrutura do Projeto

```
lib/
├── app/                    # Módulos da aplicação
│   ├── home/              # Tela principal
│   ├── stock/             # Gestão de almoxarifado
│   ├── fleet/             # Gestão de frota
│   ├── inspections/       # Sistema de vistorias
│   ├── notifications/     # Notificações
│   └── trade_services/    # Serviços terceirizados
├── core/                  # Funcionalidades centrais
│   ├── models/           # Modelos de dados
│   ├── services/         # Serviços e APIs
│   ├── providers/        # Gerenciamento de estado
│   ├── navigation/       # Configuração de rotas
│   └── widgets/          # Widgets reutilizáveis
└── main.dart             # Ponto de entrada da aplicação
```

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Equipe de Desenvolvimento

- **CB MORAES** - Desenvolvedor Principal

## 📞 Contato

- **Email**: cbmoraes@example.com
- **Projeto**: [https://github.com/seu-usuario/gestaocbmgo](https://github.com/seu-usuario/gestaocbmgo)

---

**Desenvolvido com ❤️ para o Corpo de Bombeiros Militar de Goiás**