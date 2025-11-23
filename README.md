# 🏷️ Gerador de Etiquetas Profissional

<div align="center">

**Aplicativo desktop completo para gerar etiquetas em PDF a partir de arquivos CSV/TXT/TSV**

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-1.0-brightgreen.svg)

**Desenvolvido por:** [Victor Hugo Ribeiro dos Santos Azambuja Primo](https://github.com/VictoAzam)

</div>

---

## 📋 Visão Geral

O **Gerador de Etiquetas Profissional** é uma solução completa para criação de etiquetas profissionais em PDF. Com interface moderna, personalização total e sistema de padrões salvos, é ideal para empresas, cartórios, clínicas e qualquer organização que precise imprimir etiquetas de endereço de forma rápida e profissional.

## ✨ Principais Recursos

### 🎯 **Funcionalidades Principais**
- **📊 Leitura Inteligente**: Detecta automaticamente codificação e separadores de arquivos CSV/TXT/TSV
- **⚙️ Personalização Total**: Configure colunas, linhas, dimensões, margens e espaçamentos
- **💾 Padrões Salvos**: Salve e reutilize suas configurações favoritas
- **📋 Presets Prontos**: Pimaco 6181/6281 e outros formatos populares
- **🎯 Validação Inteligente**: Avisos automáticos para configurações problemáticas
- **🖱️ Interface Moderna**: Design profissional com scroll e abas intuitivas

### 📂 **Formatos Suportados**
- **Entrada**: CSV, TXT, TSV (mínimo 10 colunas)
- **Saída**: PDF otimizado para impressão A4
- **Codificação**: UTF-8, Latin-1, CP1252, ISO-8859-1 (detecção automática)

### 📝 **Estrutura dos Dados**
O arquivo deve conter **exatamente** estas colunas na ordem:
1. **MATRICULA** - Número de matrícula
2. **CARTEIRINHA** - Número da carteirinha  
3. **NOME_TITULAR** - Nome completo
4. **RUA** - Nome da rua/avenida
5. **NUMERO** - Número da residência
6. **COMPLEMENTO** - Complemento (opcional)
7. **BAIRRO** - Bairro
8. **CIDADE** - Cidade
9. **ESTADO** - Estado (sigla)
10. **CEP** - CEP formatado

---

## 🚀 Instalação e Uso

### 💻 **Para Usuários Finais**

1. **Download do Instalador**
   ```
   Baixe: Instalador_Gerador_Etiquetas_Wizard_v1.0.exe
   ```

2. **Instalação Automática**
   - Execute o instalador como administrador
   - O installer automaticamente:
     - Detecta se Python está instalado
     - Baixa e instala Python se necessário
     - Instala todas as dependências
     - Cria atalhos no Desktop e Menu Iniciar

3. **Uso do Aplicativo**
   - Execute pelo atalho criado
   - Selecione seu arquivo CSV/TXT/TSV
   - Configure o layout (opcional)
   - Gere seu PDF de etiquetas

### 👨‍💻 **Para Desenvolvedores**

#### **Pré-requisitos**
```bash
# Python 3.8 ou superior
python --version

# Dependências
pip install -r requirements.txt
```

#### **Execução em Modo Desenvolvimento**
```bash
# Clone o repositório
git clone https://github.com/VictoAzam/gerador-etiquetas.git
cd gerador-etiquetas

# Instale dependências
pip install pandas reportlab

# Execute o aplicativo
python app.py
```

#### **Compilação do Executável**
```bash
# Instale PyInstaller
pip install pyinstaller

# Compile o executável
build_exe.bat

# Resultado: dist/Gerador_Etiquetas.exe
```

#### **Criação do Instalador**
```bash
# Instale NSIS: https://nsis.sourceforge.io/Download
# Compile o instalador wizard
build_wizard.bat

# Resultado: Instalador_Gerador_Etiquetas_Wizard_v1.0.exe
```

---

## 📖 Guias Detalhados

### 🎨 **Personalizando o Layout**

A aba **"Personalização"** permite configurar:

#### **📐 Layout da Página**
- **Colunas**: 1-6 (recomendado máx 4)
- **Linhas**: 5-15 por página

#### **📏 Dimensões das Etiquetas**
- **Largura**: 5-10cm (ideal)
- **Altura**: 2-5cm (ideal)

#### **📐 Margens**
- **Esquerda**: Ajuste conforme sua impressora
- **Superior**: Ajuste conforme sua impressora

#### **↔️ Espaçamentos**
- **Entre colunas**: Para etiquetas separadas
- **Entre linhas**: Para etiquetas separadas

### 💾 **Sistema de Padrões**

1. **Salvar Padrão**
   - Configure o layout desejado
   - Digite um nome no campo "Nome do padrão"
   - Clique em "💾 Salvar"

2. **Carregar Padrão**
   - Selecione o padrão na lista
   - Clique em "📂 Carregar" ou duplo-clique

3. **Excluir Padrão**
   - Selecione o padrão na lista
   - Clique em "🗑️ Excluir"

### 📋 **Presets Inclusos**

#### **Pimaco 6181/6281**
- 2 colunas × 10 linhas
- 9.9×2.54cm por etiqueta
- Margem: 0.6cm (esq) × 1.6cm (sup)

#### **A4 Grande**
- 2 colunas × 5 linhas
- 9.5×5.0cm por etiqueta
- Ideal para etiquetas maiores

---

## 🛠️ Estrutura do Projeto

```
📁 gerador-etiquetas/
├── 📄 app.py                           # Aplicativo principal
├── 📄 requirements.txt                 # Dependências Python
├── 📄 LICENSE.txt                      # Licença MIT
├── 📄 README.md                        # Este arquivo
├── 📄 README_DISTRIBUICAO.md           # Manual do usuário
├── 📄 README_INSTALADOR_WIZARD.md      # Guia do instalador
│
├── 📁 dist/                            # Executável compilado
│   └── 📄 Gerador_Etiquetas.exe
│
├── 📁 padroes/                         # Padrões salvos pelo usuário
│   └── *.json
│
├── 📄 build_exe.bat                    # Script para compilar executável
├── 📄 Gerador_Etiquetas.spec           # Configuração PyInstaller
│
├── 📄 installer.nsi                    # Instalador NSIS tradicional
├── 📄 installer_wizard.nsi             # Instalador wizard avançado
├── 📄 build_wizard.bat                 # Script para compilar instalador
│
└── 📄 create_icon.py                   # Gerador de ícone simples
```

---

## 🧪 Testes e Validação

### ✅ **Checklist de Teste**

- [ ] **Leitura de Arquivos**
  - [ ] CSV com vírgula
  - [ ] CSV com ponto-e-vírgula
  - [ ] TXT tabulado
  - [ ] TSV
  - [ ] Codificações diferentes (UTF-8, Latin-1)

- [ ] **Personalização**
  - [ ] Alteração de colunas/linhas
  - [ ] Modificação de dimensões
  - [ ] Ajuste de margens
  - [ ] Configuração de espaçamentos

- [ ] **Sistema de Padrões**
  - [ ] Salvar padrão
  - [ ] Carregar padrão
  - [ ] Excluir padrão
  - [ ] Duplo-clique para carregar

- [ ] **Presets**
  - [ ] Pimaco 6181/6281
  - [ ] A4 Grande
  - [ ] Aplicar alterações

- [ ] **Geração de PDF**
  - [ ] PDF é criado corretamente
  - [ ] Etiquetas estão alinhadas
  - [ ] Texto não está cortado
  - [ ] Múltiplas páginas funcionam

### 🎯 **Teste do Instalador**

1. **Ambiente Limpo**
   - Use uma VM Windows sem Python
   - Execute o instalador
   - Verifique instalação automática do Python
   - Teste o aplicativo instalado

2. **Ambiente com Python**
   - Execute o instalador
   - Verifique detecção do Python existente
   - Teste instalação de dependências

---

## 🔧 Personalização e Extensão

### 🎨 **Modificando a Interface**

O arquivo `app.py` usa Tkinter com ttk. Para personalizar:

```python
# Cores principais
bg_color = "#f0f0f0"        # Fundo principal
primary_color = "#3498db"   # Azul primário
success_color = "#27ae60"   # Verde sucesso
warning_color = "#e74c3c"   # Vermelho aviso

# Fontes
title_font = ("Arial", 20, "bold")
normal_font = ("Arial", 10)
small_font = ("Arial", 8)
```

### 📊 **Adicionando Novos Formatos**

Para suportar outros formatos de etiqueta:

```python
def preset_custom_format(self):
    """Adiciona um novo preset personalizado."""
    self.colunas_var.set("3")
    self.linhas_var.set("8")
    self.largura_var.set("6.5")
    self.altura_var.set("3.0")
    # ... outras configurações
    self.apply_custom_settings()
```

### 🔌 **Extensões Possíveis**

- **Códigos de Barras**: Integração com bibliotecas de código de barras
- **QR Codes**: Geração de QR codes nas etiquetas
- **Imagens**: Suporte a logos e imagens nas etiquetas
- **Base de Dados**: Conexão direta com bancos de dados
- **API**: Interface web para uso em sistemas

---

## 🐛 Solução de Problemas

### ❓ **Problemas Comuns**

#### **"Erro ao ler arquivo"**
```
✅ Solução:
- Verifique se o arquivo tem 10 colunas
- Teste diferentes separadores (vírgula, ponto-vírgula, tab)
- Verifique a codificação do arquivo
```

#### **"Texto cortado nas etiquetas"**
```
✅ Solução:
- Reduza o número de colunas
- Aumente o tamanho das etiquetas
- Ajuste as margens
- Use fonte menor (modificação no código)
```

#### **"Python não encontrado"**
```
✅ Solução:
- Use o instalador wizard que instala Python automaticamente
- Ou instale Python manualmente: https://python.org
```

#### **"Dependências não instaladas"**
```
✅ Solução:
pip install pandas reportlab
```

### 🔍 **Debug Mode**

Para ativar debug detalhado, modifique `app.py`:

```python
DEBUG = True  # Adicione no topo do arquivo

# Isso mostrará informações detalhadas no console
```

---

## 🤝 Contribuição

### 📝 **Como Contribuir**

1. **Fork** o repositório
2. **Clone** sua fork
3. **Crie** uma branch para sua feature
4. **Faça** suas alterações
5. **Teste** completamente
6. **Commit** com mensagem descritiva
7. **Push** para sua branch
8. **Abra** um Pull Request

### 🎯 **Áreas de Melhoria**

- [ ] **Interface**: Melhorias no design visual
- [ ] **Formatos**: Suporte a mais formatos de arquivo
- [ ] **Etiquetas**: Novos modelos de etiqueta
- [ ] **Performance**: Otimização para arquivos grandes
- [ ] **Recursos**: Códigos de barras, QR codes, imagens
- [ ] **Multiplataforma**: Suporte para Linux e macOS

### 🐛 **Reportando Bugs**

Use as [Issues do GitHub](https://github.com/VictoAzam/gerador-etiquetas/issues) com:

- **Descrição** clara do problema
- **Passos** para reproduzir
- **Arquivos** de exemplo (se aplicável)
- **Screenshot** da tela de erro
- **Versão** do Windows e Python

---

## 📄 Licença

Este projeto está licenciado sob a **Licença MIT** - veja o arquivo [LICENSE.txt](LICENSE.txt) para detalhes.

```
MIT License - Copyright (c) 2025 Victor Hugo Ribeiro dos Santos Azambuja Primo
```

### 📋 **Resumo da Licença**

✅ **Permitido:**
- Uso comercial
- Modificação
- Distribuição
- Uso privado

❗ **Limitações:**
- Responsabilidade
- Garantia

📝 **Condições:**
- Incluir licença e copyright

---

## 🎉 Agradecimentos

- **Python Community** - Pela linguagem incrível
- **ReportLab** - Pela excelente biblioteca de PDF
- **Pandas** - Pela manipulação eficiente de dados
- **NSIS** - Pelo sistema de instalação profissional
- **Usuários e Contributors** - Por feedback e melhorias

---

## 📞 Suporte

### 💬 **Canais de Suporte**

- **GitHub Issues**: [Issues](https://github.com/VictoAzam/gerador-etiquetas/issues)
- **GitHub Discussions**: [Discussions](https://github.com/VictoAzam/gerador-etiquetas/discussions)
- **Email**: Disponível no perfil GitHub

### 📚 **Documentação Adicional**

- [📖 Manual do Usuário](README_DISTRIBUICAO.md)
- [🛠️ Guia do Instalador](README_INSTALADOR_WIZARD.md)
- [💻 Documentação da API](docs/api.md) *(em desenvolvimento)*

---

<div align="center">

**⭐ Se este projeto foi útil, considere dar uma estrela no GitHub! ⭐**

**Desenvolvido com ❤️ por [Victor Hugo Azambuja](https://github.com/VictoAzam)**

---

*Transformando dados em etiquetas profissionais desde 2025* 🏷️

</div>
