# 🏷️ Instalador Wizard - Gerador de Etiquetas

## 📋 Visão Geral

Este é um instalador wizard avançado criado com NSIS que oferece:

- **🎯 Interface Moderna**: Wizard profissional com múltiplas páginas
- **🐍 Auto-instalação do Python**: Download e instalação automática se necessário
- **📦 Dependências Automáticas**: Instala pandas e reportlab automaticamente
- **🔗 Atalhos Inteligentes**: Desktop e Menu Iniciar
- **🗑️ Desinstalador Completo**: Remove tudo limpo

## 🚀 Como Compilar o Instalador

### Pré-requisitos

1. **NSIS (Nullsoft Scriptable Install System)**
   - Baixe em: https://nsis.sourceforge.io/Download
   - Instale a versão mais recente (3.08+)
   - **IMPORTANTE**: Durante a instalação, marque "Add NSIS to PATH"

2. **Executável do App**
   - Certifique-se que `dist\Gerador_Etiquetas.exe` existe
   - Se não existir, execute primeiro: `build_exe.bat`

### Passos de Compilação

1. **Abra o Prompt de Comando como Administrador**
   ```cmd
   # Navegue até a pasta do projeto
   cd "c:\Users\Azam\Desktop\gerar etiquetas"
   
   # Execute o script de compilação
   build_wizard.bat
   ```

2. **Resultado Esperado**
   - Arquivo criado: `Instalador_Gerador_Etiquetas_Wizard_v1.0.exe`
   - Tamanho aproximado: 10-15 MB

## 🎯 Funcionalidades do Instalador

### Páginas do Wizard

1. **Boas-vindas**: Apresentação profissional do aplicativo
2. **Licença**: Termos de uso (MIT License)
3. **Componentes**: Escolha o que instalar:
   - ✅ Arquivos Principais (obrigatório)
   - ✅ Python e Dependências (recomendado)
   - ✅ Atalhos (recomendado)
4. **Diretório**: Escolha onde instalar (padrão: Program Files)
5. **Instalação**: Progresso em tempo real
6. **Finalização**: Opção de executar o app imediatamente

### Instalação Inteligente do Python

- **Detecção Automática**: Verifica se Python já está instalado
- **Download Automático**: Baixa Python 3.11.7 oficial se necessário
- **Instalação Silenciosa**: Instala Python sem intervenção do usuário
- **Configuração do PATH**: Adiciona Python ao PATH automaticamente
- **Dependências**: Instala pandas e reportlab via pip

### Compatibilidade

- **Windows 7+**: Funciona em todas as versões modernas do Windows
- **Arquitetura**: x64 (baixa Python 64-bit automaticamente)
- **Conexão**: Requer internet apenas se Python não estiver instalado
- **Permissões**: Solicita privilégios de administrador

## 🧪 Como Testar

### Teste Completo (Recomendado)

1. **Máquina Virtual**: Use uma VM Windows limpa
2. **Sem Python**: Certifique-se que Python não está instalado
3. **Execute o Instalador**: Teste todo o processo automático
4. **Verifique**:
   - Python foi instalado
   - Dependências funcionam
   - App abre corretamente
   - Atalhos foram criados

### Teste Rápido

```cmd
# Execute o instalador
Instalador_Gerador_Etiquetas_Wizard_v1.0.exe

# Siga o wizard
# Teste o app instalado
# Teste o desinstalador
```

## 🔧 Personalização

### Modificar o Script NSIS

O arquivo `installer_wizard.nsi` pode ser personalizado:

```nsis
; Alterar informações do produto
!define PRODUCT_NAME "Seu App"
!define PRODUCT_VERSION "2.0"
!define PRODUCT_PUBLISHER "Seu Nome"

; Personalizar URLs
"https://github.com/SeuUsuario"

; Alterar versão do Python
"python-3.11.7-amd64.exe"
```

### Adicionar Ícone Personalizado

1. Crie um arquivo `icon.ico` (32x32 pixels)
2. Modifique no script:
   ```nsis
   !define MUI_ICON "icon.ico"
   !define MUI_UNICON "icon.ico"
   ```

## 📊 Estrutura de Arquivos

```
📁 Projeto/
├── 📄 installer_wizard.nsi      # Script NSIS principal
├── 📄 build_wizard.bat          # Script de compilação
├── 📄 LICENSE.txt               # Licença MIT
├── 📁 dist/
│   └── 📄 Gerador_Etiquetas.exe # Executável do app
└── 📄 README_DISTRIBUICAO.md    # Documentação do usuário
```

## 🐛 Solução de Problemas

### NSIS não encontrado
```
[ERRO] NSIS não encontrado no PATH!
```
**Solução**: Instale o NSIS e adicione ao PATH

### Python download falha
```
Erro no download do Python
```
**Solução**: Verifique conexão com internet

### Erro de permissão
```
Acesso negado
```
**Solução**: Execute como Administrador

### Dependências falham
```
Erro ao instalar pandas/reportlab
```
**Solução**: Verifica se pip está funcionando

## 📈 Vantagens do Instalador Wizard

✅ **Profissional**: Interface moderna e intuitiva
✅ **Automático**: Zero configuração manual
✅ **Compatível**: Funciona em qualquer Windows
✅ **Inteligente**: Detecta o que já está instalado
✅ **Limpo**: Desinstalação completa
✅ **Confiável**: Usa fontes oficiais (python.org)

## 🎉 Resultado Final

Após a compilação, você terá um instalador profissional que:

1. **Funciona em qualquer PC Windows**: Mesmo sem Python
2. **Instala tudo automaticamente**: Python + dependências + app
3. **Cria atalhos**: Desktop e Menu Iniciar
4. **Pode ser desinstalado**: Completamente pelo Painel de Controle
5. **Está pronto para distribuição**: Via email, site, GitHub releases

**Este é o padrão ouro para distribuição de aplicativos Python no Windows!**
