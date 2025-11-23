"""
🏷️ GERADOR DE ETIQUETAS PROFISSIONAL
=====================================

Aplicativo desktop para gerar etiquetas em PDF a partir de arquivos CSV/TXT/TSV.
Interface gráfica moderna com personalização completa de layout e padrões salvos.

Desenvolvedor: Victor Hugo Ribeiro dos Santos Azambuja Primo
GitHub: VictoAzam
Data: 2025

Recursos:
- Leitura robusta de arquivos CSV/TXT/TSV
- Detecção automática de codificação e separadores  
- Interface moderna com abas
- Personalização completa do layout das etiquetas
- Sistema de padrões salvos
- Validações inteligentes
- Suporte a múltiplos formatos de etiqueta
"""

import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import pandas as pd
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib.units import cm
import os
import json

# --- Configurações das Etiquetas ---
# Baseado no formato comum Pimaco 6181/6281 (10 linhas, 2 colunas)
# Se seu formulário for diferente, ajuste as medidas aqui.
ETIQUETA_LARGURA = 9.9 * cm
ETIQUETA_ALTURA = 2.54 * cm
MARGEM_ESQUERDA = 0.6 * cm
MARGEM_SUPERIOR = 1.2 * cm
COLUNAS = 2
LINHAS = 10

# Espaçamento entre as etiquetas. Deixe 0 se elas forem coladas.
ESPACAMENTO_HORIZONTAL = 0.1 * cm
ESPACAMENTO_VERTICAL = 0 * cm

# Configurações personalizáveis globais
config_etiquetas = {
    'largura': 9.9,
    'altura': 2.54,
    'margem_esquerda': 0.6,
    'margem_superior': 1.2,
    'colunas': 2,
    'linhas': 10,
    'espacamento_horizontal': 0.1,
    'espacamento_vertical': 0.0
}

# --- Colunas Esperadas no Arquivo CSV ---
# O nome das colunas no seu arquivo CSV deve ser exatamente este.
COLUNAS_NECESSARIAS = [
    'MATRICULA', 'CARTEIRINHA', 'NOME_TITULAR', 'RUA', 'NUMERO',
    'COMPLEMENTO', 'BAIRRO', 'CIDADE', 'ESTADO', 'CEP'
]

def gerar_pdf_etiquetas(csv_path, pdf_path):
    """
    Lê o arquivo CSV e gera o PDF com as etiquetas formatadas.
    """
    try:
        # Tenta ler o CSV com diferentes codificações e separadores
        df = None
        encodings = ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']
        separators = [',', ';', '\t', '|']  # Separadores mais comuns em CSVs gerados online
        
        print("Tentando ler o arquivo...")
        
        for encoding in encodings:
            for sep in separators:
                try:
                    df = pd.read_csv(csv_path, dtype=str, encoding=encoding, sep=sep)
                    
                    print(f"Testando encoding: {encoding} e separador: '{sep}' - Colunas: {len(df.columns)}")
                    
                    # Se tem pelo menos 10 colunas, aceita
                    if len(df.columns) >= 10:
                        print(f"✓ Arquivo lido com sucesso! Encoding: {encoding}, Separador: '{sep}'")
                        break
                except Exception as e:
                    continue
            if df is not None and len(df.columns) >= 10:
                break
        
        # Se não conseguiu com separadores fixos, tenta detecção automática
        if df is None or len(df.columns) < 10:
            print("Tentando detecção automática de separador...")
            for encoding in encodings:
                try:
                    df = pd.read_csv(csv_path, dtype=str, encoding=encoding, sep=None, engine='python')
                    if len(df.columns) >= 10:
                        print(f"✓ Arquivo lido com detecção automática! Encoding: {encoding}")
                        break
                except Exception as e:
                    continue
        
        if df is None:
            messagebox.showerror("❌ Erro de Leitura", 
                               "Não foi possível ler o arquivo.\n\n"
                               "Verifique se o arquivo está no formato correto:\n"
                               "• CSV com vírgulas ou ponto e vírgula\n"
                               "• TXT com dados separados por tabulação\n"
                               "• Codificação UTF-8 ou similar")
            return

        # Preenche valores ausentes (NaN) com uma string vazia para evitar erros.
        df.fillna('', inplace=True)

        print("Colunas encontradas no arquivo:", list(df.columns))
        print(f"Total de colunas: {len(df.columns)}")
        print(f"Total de linhas: {len(df)}")
        
        # Verifica se tem pelo menos 10 colunas
        if len(df.columns) < 10:
            messagebox.showerror("📊 Erro de Formato", 
                               f"O arquivo precisa ter pelo menos 10 colunas.\n\n"
                               f"📈 Encontradas: {len(df.columns)} colunas\n"
                               f"✅ Necessárias: 10 colunas\n\n"
                               f"Verifique se o arquivo está no formato correto.")
            return
        
        # Usa as primeiras 10 colunas, independente do nome
        colunas = df.columns[:10].tolist()
        print("Usando as colunas:", colunas)
        
        # Renomeia as colunas para os nomes padrão
        mapeamento = {
            colunas[0]: 'MATRICULA',
            colunas[1]: 'CARTEIRINHA', 
            colunas[2]: 'NOME_TITULAR',
            colunas[3]: 'RUA',
            colunas[4]: 'NUMERO',
            colunas[5]: 'COMPLEMENTO',
            colunas[6]: 'BAIRRO',
            colunas[7]: 'CIDADE',
            colunas[8]: 'ESTADO',
            colunas[9]: 'CEP'
        }
        
        df = df.rename(columns=mapeamento)
        df = df[['MATRICULA', 'CARTEIRINHA', 'NOME_TITULAR', 'RUA', 'NUMERO', 'COMPLEMENTO', 'BAIRRO', 'CIDADE', 'ESTADO', 'CEP']]

        # Inicia a criação do arquivo PDF usando as configurações atuais
        c = canvas.Canvas(pdf_path, pagesize=A4)
        _, altura_pagina = A4

        col = 0
        row = 0

        # Itera sobre cada linha do arquivo CSV para criar uma etiqueta.
        for index, item in df.iterrows():
            try:
                # Calcula a posição X e Y da etiqueta atual na página usando as configurações globais
                x = MARGEM_ESQUERDA + col * (ETIQUETA_LARGURA + ESPACAMENTO_HORIZONTAL)
                y = altura_pagina - MARGEM_SUPERIOR - row * (ETIQUETA_ALTURA + ESPACAMENTO_VERTICAL)

                # --- Desenha o conteúdo da etiqueta ---
                texto_x = x + 0.2 * cm  # Margem interna menor
                texto_y = y - 0.3 * cm  # Margem superior interna menor

                texto = c.beginText(texto_x, texto_y)
                texto.setFont("Helvetica", 8)

                # Adiciona as linhas de texto, tratando cada campo e removendo caracteres problemáticos.
                def clean_text(text):
                    """Remove ou substitui caracteres que podem causar problemas no PDF."""
                    if pd.isna(text) or text == '':
                        return ''
                    # Remove caracteres de controle e substitui caracteres problemáticos
                    text = str(text).encode('ascii', 'ignore').decode('ascii')
                    return text.strip()
                
                # Verifica se todas as colunas existem antes de acessá-las
                matricula = clean_text(item.get('MATRICULA', ''))
                carteirinha = clean_text(item.get('CARTEIRINHA', ''))
                nome = clean_text(item.get('NOME_TITULAR', ''))
                rua = clean_text(item.get('RUA', ''))
                numero = clean_text(item.get('NUMERO', ''))
                complemento = clean_text(item.get('COMPLEMENTO', ''))
                bairro = clean_text(item.get('BAIRRO', ''))
                cidade = clean_text(item.get('CIDADE', ''))
                estado = clean_text(item.get('ESTADO', ''))
                cep = clean_text(item.get('CEP', ''))
                
                texto.textLine(f"{matricula}    {carteirinha}")
                texto.textLine(f"{nome}")
                
                endereco_linha1 = f"{rua}, nº {numero}"
                if complemento:
                    endereco_linha1 += f" - {complemento}"
                texto.textLine(endereco_linha1)
                
                texto.textLine(f"{bairro}")
                texto.textLine(f"{cidade} - {estado}    CEP: {cep}")
                
                c.drawText(texto)

                # --- Atualiza a posição para a próxima etiqueta ---
                col += 1
                if col >= COLUNAS:
                    col = 0
                    row += 1
                if row >= LINHAS:
                    c.showPage()  # Cria uma nova página quando a atual estiver cheia.
                    row = 0
                    col = 0
                    
            except Exception as e:
                print(f"Erro ao processar linha {index}: {e}")
                print(f"Dados da linha: {dict(item)}")
                continue

        c.save()
        messagebox.showinfo("🎉 Sucesso!", f"PDF de etiquetas gerado com sucesso!\n\n📂 Local: {pdf_path}\n\n✅ Pronto para impressão!")

    except FileNotFoundError:
        messagebox.showerror("Erro", f"Arquivo não encontrado: {csv_path}")
    except Exception as e:
        messagebox.showerror("Erro Inesperado", f"Ocorreu um erro ao gerar o PDF:\n{e}")


class App:
    """
    Cria a interface gráfica do programa com visual moderno.
    """
    def __init__(self, root):
        self.root = root
        self.root.title("🏷️ Gerador de Etiquetas - Profissional")
        self.root.geometry("750x650")
        self.root.resizable(True, True)
        
        # Configura o tema e cores
        self.setup_style()
        
        self.csv_path = None

        # Frame principal
        main_frame = tk.Frame(root, bg="#f0f0f0")
        main_frame.pack(expand=True, fill=tk.BOTH, padx=20, pady=20)

        # Título principal
        title_frame = tk.Frame(main_frame, bg="#f0f0f0")
        title_frame.pack(fill=tk.X, pady=(0, 20))
        
        title_label = tk.Label(title_frame, 
                              text="🏷️ GERADOR DE ETIQUETAS", 
                              font=("Arial", 20, "bold"), 
                              fg="#2c3e50", 
                              bg="#f0f0f0")
        title_label.pack()
        
        subtitle_label = tk.Label(title_frame, 
                                 text="Transforme seus dados em etiquetas profissionais", 
                                 font=("Arial", 11), 
                                 fg="#7f8c8d", 
                                 bg="#f0f0f0")
        subtitle_label.pack()

        # Criando as abas
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(expand=True, fill=tk.BOTH, pady=10)

        # Aba 1 - Geração de Etiquetas
        self.create_main_tab()
        
        # Aba 2 - Personalização
        self.create_customization_tab()

    def create_main_tab(self):
        """Cria a aba principal de geração de etiquetas."""
        main_tab = tk.Frame(self.notebook, bg="#ffffff")
        self.notebook.add(main_tab, text="🏷️ Gerar Etiquetas")
        
        # Frame interno com padding
        inner_frame = tk.Frame(main_tab, bg="#ffffff")
        inner_frame.pack(expand=True, fill=tk.BOTH, padx=30, pady=30)

        # Botão 1 - Selecionar arquivo
        self.btn_select_csv = tk.Button(inner_frame, 
                                       text="📁 1. SELECIONAR ARQUIVO DE DADOS", 
                                       command=self.select_csv, 
                                       height=2, 
                                       font=("Arial", 12, "bold"),
                                       bg="#3498db", 
                                       fg="white", 
                                       relief="flat",
                                       cursor="hand2",
                                       activebackground="#2980b9",
                                       activeforeground="white")
        self.btn_select_csv.pack(fill=tk.X, pady=(0, 15))

        # Label de status do arquivo
        status_frame = tk.Frame(inner_frame, bg="#ffffff")
        status_frame.pack(fill=tk.X, pady=(0, 20))
        
        self.lbl_csv_path = tk.Label(status_frame, 
                                    text="📄 Nenhum arquivo selecionado", 
                                    fg="#95a5a6", 
                                    bg="#ffffff",
                                    font=("Arial", 10),
                                    wraplength=500)
        self.lbl_csv_path.pack()

        # Botão 2 - Gerar PDF
        self.btn_generate_pdf = tk.Button(inner_frame, 
                                         text="🎯 2. GERAR PDF COM ETIQUETAS", 
                                         command=self.generate_pdf, 
                                         height=2, 
                                         state=tk.DISABLED, 
                                         font=("Arial", 12, "bold"),
                                         bg="#27ae60", 
                                         fg="white", 
                                         relief="flat",
                                         cursor="hand2",
                                         activebackground="#229954",
                                         activeforeground="white",
                                         disabledforeground="#bdc3c7")
        self.btn_generate_pdf.pack(fill=tk.X, pady=(0, 30))

        # Informações técnicas
        info_frame = tk.Frame(inner_frame, bg="#ecf0f1", relief="flat", bd=1)
        info_frame.pack(fill=tk.X, pady=(0, 20))
        
        info_title = tk.Label(info_frame, 
                             text="ℹ️ INFORMAÇÕES", 
                             font=("Arial", 10, "bold"), 
                             fg="#34495e", 
                             bg="#ecf0f1")
        info_title.pack(pady=(10, 5))
        
        info_text = tk.Label(info_frame, 
                            text="• Formato aceito: CSV, TXT, TSV (10 colunas)\n"
                                 "• Ordem das colunas: MATRICULA | CARTEIRINHA | NOME | RUA | NUMERO |\n"
                                 "  COMPLEMENTO | BAIRRO | CIDADE | ESTADO | CEP\n"
                                 "• Configure o layout na aba 'Personalização'", 
                            font=("Arial", 9), 
                            fg="#7f8c8d", 
                            bg="#ecf0f1",
                            justify="left")
        info_text.pack(padx=15, pady=(0, 10))

        # Footer
        footer_frame = tk.Frame(inner_frame, bg="#ffffff")
        footer_frame.pack(side=tk.BOTTOM, pady=(20, 0))
        
        footer = tk.Label(footer_frame, 
                         text="💡 Uma solução simples e profissional para criação de etiquetas", 
                         font=("Arial", 9), 
                         fg="#95a5a6", 
                         bg="#ffffff")
        footer.pack()
        
        # Créditos do desenvolvedor
        credits_frame = tk.Frame(inner_frame, bg="#ffffff")
        credits_frame.pack(side=tk.BOTTOM, pady=(10, 0))
        
        credits = tk.Label(credits_frame, 
                          text="👨‍💻 Criado por Victor Hugo Ribeiro dos Santos Azambuja Primo\n🔗 GitHub: VictoAzam", 
                          font=("Arial", 8), 
                          fg="#7f8c8d", 
                          bg="#ffffff",
                          justify="center")
        credits.pack()

    def create_customization_tab(self):
        """Cria a aba de personalização das etiquetas."""
        custom_tab = tk.Frame(self.notebook, bg="#ffffff")
        self.notebook.add(custom_tab, text="⚙️ Personalização")
        
        # Canvas e scrollbar para permitir rolagem
        canvas = tk.Canvas(custom_tab, bg="#ffffff")
        scrollbar = ttk.Scrollbar(custom_tab, orient="vertical", command=canvas.yview)
        scrollable_frame = tk.Frame(canvas, bg="#ffffff")

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        # Função para scroll com mouse
        def _on_mousewheel(event):
            canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        
        def _bind_to_mousewheel(event):
            canvas.bind_all("<MouseWheel>", _on_mousewheel)
        
        def _unbind_from_mousewheel(event):
            canvas.unbind_all("<MouseWheel>")
        
        # Bind eventos de scroll
        canvas.bind('<Enter>', _bind_to_mousewheel)
        canvas.bind('<Leave>', _unbind_from_mousewheel)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        # Frame interno com padding
        inner_frame = tk.Frame(scrollable_frame, bg="#ffffff")
        inner_frame.pack(expand=True, fill=tk.BOTH, padx=30, pady=30)

        # Título da seção
        title_label = tk.Label(inner_frame, 
                              text="⚙️ CONFIGURAÇÕES DAS ETIQUETAS", 
                              font=("Arial", 16, "bold"), 
                              fg="#2c3e50", 
                              bg="#ffffff")
        title_label.pack(pady=(0, 10))
        
        # Aviso importante
        warning_frame = tk.Frame(inner_frame, bg="#fff3cd", relief="solid", bd=1)
        warning_frame.pack(fill=tk.X, pady=(0, 20))
        
        warning_label = tk.Label(warning_frame, 
                                text="⚠️ IMPORTANTE: Muitas colunas (>4) ou etiquetas muito pequenas podem cortar o texto!\n"
                                     "💡 DICA: Teste sempre com uma página antes de imprimir grandes quantidades.", 
                                font=("Arial", 9), 
                                fg="#856404", 
                                bg="#fff3cd",
                                justify="center")
        warning_label.pack(pady=8)

        # Frame para configurações de layout
        layout_frame = tk.LabelFrame(inner_frame, text="📐 Layout da Página", font=("Arial", 12, "bold"), 
                                    fg="#34495e", bg="#ffffff", padx=20, pady=15)
        layout_frame.pack(fill=tk.X, pady=(0, 15))

        # Grid para organizar os controles
        row = 0
        
        # Colunas
        tk.Label(layout_frame, text="Colunas por página:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.colunas_var = tk.StringVar(value="2")
        colunas_combo = ttk.Combobox(layout_frame, textvariable=self.colunas_var, values=["1", "2", "3", "4", "5", "6"], width=10, state="readonly")
        colunas_combo.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(layout_frame, text="(máx 4 recomendado)", font=("Arial", 8), fg="#e74c3c", bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)
        
        row += 1
        
        # Linhas
        tk.Label(layout_frame, text="Linhas por página:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.linhas_var = tk.StringVar(value="10")
        linhas_combo = ttk.Combobox(layout_frame, textvariable=self.linhas_var, values=["5", "6", "7", "8", "9", "10", "12", "15"], width=10, state="readonly")
        linhas_combo.grid(row=row, column=1, sticky="w", pady=5)

        # Frame para dimensões das etiquetas
        size_frame = tk.LabelFrame(inner_frame, text="📏 Dimensões das Etiquetas (cm)", font=("Arial", 12, "bold"), 
                                  fg="#34495e", bg="#ffffff", padx=20, pady=15)
        size_frame.pack(fill=tk.X, pady=(0, 15))

        row = 0
        
        # Largura
        tk.Label(size_frame, text="Largura:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.largura_var = tk.StringVar(value="9.9")
        largura_entry = tk.Entry(size_frame, textvariable=self.largura_var, width=10)
        largura_entry.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(size_frame, text="cm (ideal: 5-10cm)", font=("Arial", 8), fg="#7f8c8d", bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)
        
        row += 1
        
        # Altura
        tk.Label(size_frame, text="Altura:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.altura_var = tk.StringVar(value="2.54")
        altura_entry = tk.Entry(size_frame, textvariable=self.altura_var, width=10)
        altura_entry.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(size_frame, text="cm (ideal: 2-5cm)", font=("Arial", 8), fg="#7f8c8d", bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)

        # Frame para margens
        margin_frame = tk.LabelFrame(inner_frame, text="📐 Margens (cm)", font=("Arial", 12, "bold"), 
                                    fg="#34495e", bg="#ffffff", padx=20, pady=15)
        margin_frame.pack(fill=tk.X, pady=(0, 15))

        row = 0
        
        # Margem esquerda
        tk.Label(margin_frame, text="Margem esquerda:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.margem_esq_var = tk.StringVar(value="0.6")
        margem_esq_entry = tk.Entry(margin_frame, textvariable=self.margem_esq_var, width=10)
        margem_esq_entry.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(margin_frame, text="cm", font=("Arial", 10), bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)
        
        row += 1
        
        # Margem superior
        tk.Label(margin_frame, text="Margem superior:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.margem_sup_var = tk.StringVar(value="1.2")
        margem_sup_entry = tk.Entry(margin_frame, textvariable=self.margem_sup_var, width=10)
        margem_sup_entry.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(margin_frame, text="cm", font=("Arial", 10), bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)

        # Frame para espaçamentos
        spacing_frame = tk.LabelFrame(inner_frame, text="↔️ Espaçamentos (cm)", font=("Arial", 12, "bold"), 
                                     fg="#34495e", bg="#ffffff", padx=20, pady=15)
        spacing_frame.pack(fill=tk.X, pady=(0, 15))

        row = 0
        
        # Espaçamento horizontal
        tk.Label(spacing_frame, text="Entre colunas:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.esp_horiz_var = tk.StringVar(value="0.1")
        esp_horiz_entry = tk.Entry(spacing_frame, textvariable=self.esp_horiz_var, width=10)
        esp_horiz_entry.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(spacing_frame, text="cm", font=("Arial", 10), bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)
        
        row += 1
        
        # Espaçamento vertical
        tk.Label(spacing_frame, text="Entre linhas:", font=("Arial", 10), bg="#ffffff").grid(row=row, column=0, sticky="w", padx=(0, 10), pady=5)
        self.esp_vert_var = tk.StringVar(value="0")
        esp_vert_entry = tk.Entry(spacing_frame, textvariable=self.esp_vert_var, width=10)
        esp_vert_entry.grid(row=row, column=1, sticky="w", pady=5)
        tk.Label(spacing_frame, text="cm", font=("Arial", 10), bg="#ffffff").grid(row=row, column=2, sticky="w", padx=(5, 0), pady=5)

        # Frame para salvar/carregar padrões
        pattern_frame = tk.LabelFrame(inner_frame, text="💾 Gerenciar Padrões", font=("Arial", 12, "bold"), 
                                     fg="#34495e", bg="#ffffff", padx=20, pady=15)
        pattern_frame.pack(fill=tk.X, pady=(0, 15))
        
        # Primeira linha - Nome do padrão e botões
        row1_frame = tk.Frame(pattern_frame, bg="#ffffff")
        row1_frame.pack(fill=tk.X, pady=(0, 10))
        
        tk.Label(row1_frame, text="Nome do padrão:", font=("Arial", 10), bg="#ffffff").pack(side=tk.LEFT, padx=(0, 10))
        self.pattern_name_var = tk.StringVar()
        pattern_name_entry = tk.Entry(row1_frame, textvariable=self.pattern_name_var, width=25)
        pattern_name_entry.pack(side=tk.LEFT, padx=(0, 10))
        
        # Botões para salvar/carregar
        btn_save_pattern = tk.Button(row1_frame, 
                                    text="💾 Salvar", 
                                    command=self.save_pattern,
                                    font=("Arial", 9),
                                    bg="#9b59b6", 
                                    fg="white", 
                                    relief="flat",
                                    cursor="hand2")
        btn_save_pattern.pack(side=tk.LEFT, padx=(0, 5))
        
        btn_load_pattern = tk.Button(row1_frame, 
                                    text="📂 Carregar", 
                                    command=self.load_pattern,
                                    font=("Arial", 9),
                                    bg="#f39c12", 
                                    fg="white", 
                                    relief="flat",
                                    cursor="hand2")
        btn_load_pattern.pack(side=tk.LEFT, padx=(0, 5))
        
        btn_delete_pattern = tk.Button(row1_frame, 
                                      text="🗑️ Excluir", 
                                      command=self.delete_pattern,
                                      font=("Arial", 9),
                                      bg="#e74c3c", 
                                      fg="white", 
                                      relief="flat",
                                      cursor="hand2")
        btn_delete_pattern.pack(side=tk.LEFT)
        
        # Segunda linha - Lista de padrões salvos
        row2_frame = tk.Frame(pattern_frame, bg="#ffffff")
        row2_frame.pack(fill=tk.X, pady=(10, 0))
        
        tk.Label(row2_frame, text="Padrões salvos:", font=("Arial", 10), bg="#ffffff").pack(anchor="w")
        self.pattern_listbox = tk.Listbox(row2_frame, height=4, width=60)
        self.pattern_listbox.pack(fill=tk.X, pady=(5, 0))
        self.pattern_listbox.bind('<Double-1>', self.on_pattern_double_click)

        # Carrega os padrões salvos
        self.load_saved_patterns()

        # Botões de presets
        preset_frame = tk.Frame(inner_frame, bg="#ffffff")
        preset_frame.pack(fill=tk.X, pady=(15, 0))
        
        preset_label = tk.Label(preset_frame, 
                               text="📋 Presets Populares:", 
                               font=("Arial", 12, "bold"), 
                               fg="#34495e", 
                               bg="#ffffff")
        preset_label.pack(anchor="w")
        
        buttons_frame = tk.Frame(preset_frame, bg="#ffffff")
        buttons_frame.pack(fill=tk.X, pady=(10, 0))
        
        btn_pimaco = tk.Button(buttons_frame, 
                              text="📄 Pimaco 6181/6281", 
                              command=self.preset_pimaco,
                              font=("Arial", 10),
                              bg="#3498db", 
                              fg="white", 
                              relief="flat",
                              cursor="hand2")
        btn_pimaco.pack(side=tk.LEFT, padx=(0, 10))
        
        btn_a4_large = tk.Button(buttons_frame, 
                                text="📄 A4 Grande (2x5)", 
                                command=self.preset_a4_large,
                                font=("Arial", 10),
                                bg="#27ae60", 
                                fg="white", 
                                relief="flat",
                                cursor="hand2")
        btn_a4_large.pack(side=tk.LEFT, padx=(0, 10))
        
        btn_custom = tk.Button(buttons_frame, 
                              text="🔄 Aplicar Alterações", 
                              command=self.apply_custom_settings,
                              font=("Arial", 10, "bold"),
                              bg="#e74c3c", 
                              fg="white", 
                              relief="flat",
                              cursor="hand2")
        btn_custom.pack(side=tk.RIGHT)

    def save_pattern(self):
        """Salva o padrão atual com o nome especificado."""
        pattern_name = self.pattern_name_var.get().strip()
        if not pattern_name:
            messagebox.showwarning("⚠️ Aviso", "Por favor, digite um nome para o padrão.")
            return
        
        # Cria o diretório de padrões se não existir
        patterns_dir = os.path.join(os.path.dirname(__file__), "padroes")
        if not os.path.exists(patterns_dir):
            os.makedirs(patterns_dir)
        
        # Coleta as configurações atuais
        pattern_data = {
            'colunas': self.colunas_var.get(),
            'linhas': self.linhas_var.get(),
            'largura': self.largura_var.get(),
            'altura': self.altura_var.get(),
            'margem_esquerda': self.margem_esq_var.get(),
            'margem_superior': self.margem_sup_var.get(),
            'espacamento_horizontal': self.esp_horiz_var.get(),
            'espacamento_vertical': self.esp_vert_var.get()
        }
        
        # Salva o padrão em um arquivo JSON
        pattern_file = os.path.join(patterns_dir, f"{pattern_name}.json")
        try:
            with open(pattern_file, 'w', encoding='utf-8') as f:
                json.dump(pattern_data, f, indent=2, ensure_ascii=False)
            
            messagebox.showinfo("✅ Sucesso", f"Padrão '{pattern_name}' salvo com sucesso!")
            self.pattern_name_var.set("")  # Limpa o campo
            self.load_saved_patterns()  # Atualiza a lista
            
        except Exception as e:
            messagebox.showerror("❌ Erro", f"Erro ao salvar padrão:\n{e}")

    def load_pattern(self):
        """Carrega o padrão selecionado na lista."""
        selection = self.pattern_listbox.curselection()
        if not selection:
            messagebox.showwarning("⚠️ Aviso", "Por favor, selecione um padrão da lista.")
            return
        
        pattern_name = self.pattern_listbox.get(selection[0])
        self.load_pattern_by_name(pattern_name)

    def load_pattern_by_name(self, pattern_name):
        """Carrega um padrão específico pelo nome."""
        patterns_dir = os.path.join(os.path.dirname(__file__), "padroes")
        pattern_file = os.path.join(patterns_dir, f"{pattern_name}.json")
        
        try:
            with open(pattern_file, 'r', encoding='utf-8') as f:
                pattern_data = json.load(f)
            
            # Aplica as configurações
            self.colunas_var.set(pattern_data.get('colunas', '2'))
            self.linhas_var.set(pattern_data.get('linhas', '10'))
            self.largura_var.set(pattern_data.get('largura', '9.9'))
            self.altura_var.set(pattern_data.get('altura', '2.54'))
            self.margem_esq_var.set(pattern_data.get('margem_esquerda', '0.6'))
            self.margem_sup_var.set(pattern_data.get('margem_superior', '1.2'))
            self.esp_horiz_var.set(pattern_data.get('espacamento_horizontal', '0.1'))
            self.esp_vert_var.set(pattern_data.get('espacamento_vertical', '0'))
            
            # Aplica as configurações
            self.apply_custom_settings()
            messagebox.showinfo("✅ Sucesso", f"Padrão '{pattern_name}' carregado com sucesso!")
            
        except Exception as e:
            messagebox.showerror("❌ Erro", f"Erro ao carregar padrão:\n{e}")

    def delete_pattern(self):
        """Exclui o padrão selecionado."""
        selection = self.pattern_listbox.curselection()
        if not selection:
            messagebox.showwarning("⚠️ Aviso", "Por favor, selecione um padrão para excluir.")
            return
        
        pattern_name = self.pattern_listbox.get(selection[0])
        
        if messagebox.askyesno("🗑️ Confirmar Exclusão", f"Tem certeza que deseja excluir o padrão '{pattern_name}'?"):
            patterns_dir = os.path.join(os.path.dirname(__file__), "padroes")
            pattern_file = os.path.join(patterns_dir, f"{pattern_name}.json")
            
            try:
                os.remove(pattern_file)
                messagebox.showinfo("✅ Sucesso", f"Padrão '{pattern_name}' excluído com sucesso!")
                self.load_saved_patterns()  # Atualiza a lista
                
            except Exception as e:
                messagebox.showerror("❌ Erro", f"Erro ao excluir padrão:\n{e}")

    def on_pattern_double_click(self, event):
        """Carrega o padrão quando clicado duas vezes."""
        self.load_pattern()

    def load_saved_patterns(self):
        """Carrega a lista de padrões salvos."""
        self.pattern_listbox.delete(0, tk.END)
        
        patterns_dir = os.path.join(os.path.dirname(__file__), "padroes")
        if not os.path.exists(patterns_dir):
            return
        
        try:
            for filename in os.listdir(patterns_dir):
                if filename.endswith('.json'):
                    pattern_name = filename[:-5]  # Remove .json
                    self.pattern_listbox.insert(tk.END, pattern_name)
        except Exception as e:
            print(f"Erro ao carregar padrões: {e}")

    def setup_style(self):
        """Configura o estilo visual da aplicação."""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Estilo personalizado para o notebook
        style.configure('TNotebook', background='#f0f0f0')
        style.configure('TNotebook.Tab', padding=[20, 10])
        style.map('TNotebook.Tab', 
                 background=[('selected', '#3498db'), ('!selected', '#bdc3c7')],
                 foreground=[('selected', 'white'), ('!selected', '#2c3e50')])

    def preset_pimaco(self):
        """Aplica configurações para etiquetas Pimaco 6181/6281."""
        self.colunas_var.set("2")
        self.linhas_var.set("10")
        self.largura_var.set("9.9")
        self.altura_var.set("2.54")
        self.margem_esq_var.set("0.6")
        self.margem_sup_var.set("1.2")
        self.esp_horiz_var.set("0.1")
        self.esp_vert_var.set("0")
        self.apply_custom_settings()
        messagebox.showinfo("✅ Preset Aplicado", "Configurações Pimaco 6181/6281 aplicadas!")

    def preset_a4_large(self):
        """Aplica configurações para etiquetas grandes A4."""
        self.colunas_var.set("2")
        self.linhas_var.set("5")
        self.largura_var.set("9.5")
        self.altura_var.set("5.0")
        self.margem_esq_var.set("1.0")
        self.margem_sup_var.set("2.0")
        self.esp_horiz_var.set("0.5")
        self.esp_vert_var.set("0.3")
        self.apply_custom_settings()
        messagebox.showinfo("✅ Preset Aplicado", "Configurações A4 Grande aplicadas!")

    def apply_custom_settings(self):
        """Aplica as configurações personalizadas às variáveis globais."""
        global ETIQUETA_LARGURA, ETIQUETA_ALTURA, MARGEM_ESQUERDA, MARGEM_SUPERIOR
        global COLUNAS, LINHAS, ESPACAMENTO_HORIZONTAL, ESPACAMENTO_VERTICAL
        
        try:
            colunas = int(self.colunas_var.get())
            linhas = int(self.linhas_var.get())
            largura = float(self.largura_var.get())
            altura = float(self.altura_var.get())
            margem_esq = float(self.margem_esq_var.get())
            margem_sup = float(self.margem_sup_var.get())
            esp_horiz = float(self.esp_horiz_var.get())
            esp_vert = float(self.esp_vert_var.get())
            
            # Validações e avisos
            warnings = []
            
            # Verifica se as etiquetas cabem na página A4 (21cm de largura)
            largura_total = margem_esq + (colunas * largura) + ((colunas - 1) * esp_horiz)
            if largura_total > 20.5:  # Deixa margem de segurança
                warnings.append(f"⚠️ LARGURA: {largura_total:.1f}cm pode não caber na página A4 (21cm)")
            
            # Verifica se as etiquetas cabem na altura A4 (29.7cm)
            altura_total = margem_sup + (linhas * altura) + ((linhas - 1) * esp_vert)
            if altura_total > 29:  # Deixa margem de segurança
                warnings.append(f"⚠️ ALTURA: {altura_total:.1f}cm pode não caber na página A4 (29.7cm)")
            
            # Aviso para muitas colunas
            if colunas > 4:
                warnings.append("⚠️ MUITAS COLUNAS: Mais de 4 colunas pode deixar o texto muito pequeno/cortado")
            
            # Aviso para etiquetas muito pequenas
            if largura < 3.0:
                warnings.append("⚠️ LARGURA PEQUENA: Etiquetas menores que 3cm podem cortar o texto")
            
            if altura < 1.5:
                warnings.append("⚠️ ALTURA PEQUENA: Etiquetas menores que 1.5cm podem cortar o texto")
            
            # Mostra avisos se houver
            if warnings:
                warning_msg = "⚠️ ATENÇÃO - Possíveis problemas detectados:\n\n" + "\n".join(warnings)
                warning_msg += "\n\n🔧 DICAS:\n"
                warning_msg += "• Use no máximo 3-4 colunas para melhor legibilidade\n"
                warning_msg += "• Etiquetas ideais: 5-10cm largura, 2-5cm altura\n"
                warning_msg += "• Teste sempre com uma página antes de imprimir tudo\n\n"
                warning_msg += "Deseja continuar mesmo assim?"
                
                if not messagebox.askyesno("⚠️ Configuração Pode Causar Problemas", warning_msg):
                    return
            
            # Aplica as configurações se passou nas validações
            COLUNAS = colunas
            LINHAS = linhas
            ETIQUETA_LARGURA = largura * cm
            ETIQUETA_ALTURA = altura * cm
            MARGEM_ESQUERDA = margem_esq * cm
            MARGEM_SUPERIOR = margem_sup * cm
            ESPACAMENTO_HORIZONTAL = esp_horiz * cm
            ESPACAMENTO_VERTICAL = esp_vert * cm
            
            success_msg = "✅ Configurações aplicadas com sucesso!\n\n"
            success_msg += f"📊 RESUMO:\n"
            success_msg += f"• Layout: {colunas} colunas × {linhas} linhas\n"
            success_msg += f"• Tamanho: {largura}×{altura}cm\n"
            success_msg += f"• Área total: {largura_total:.1f}×{altura_total:.1f}cm\n\n"
            success_msg += "As próximas etiquetas geradas usarão estas configurações."
            
            messagebox.showinfo("✅ Sucesso", success_msg)
            
        except ValueError:
            messagebox.showerror("❌ Erro", "Por favor, insira apenas números válidos nos campos.")

    def select_csv(self):
        """Abre a janela para o usuário selecionar o arquivo CSV."""
        path = filedialog.askopenfilename(
            title="📁 Selecione o arquivo com os dados",
            filetypes=[
                ("Todos os arquivos suportados", "*.csv;*.txt;*.tsv"),
                ("Arquivos CSV", "*.csv"),
                ("Arquivos TXT", "*.txt"),
                ("Arquivos TSV", "*.tsv"),
                ("Todos os arquivos", "*.*")
            ]
        )
        if path:
            self.csv_path = path
            filename = os.path.basename(path)
            self.lbl_csv_path.config(text=f"✅ Arquivo selecionado: {filename}", fg="#27ae60")
            self.btn_generate_pdf.config(state=tk.NORMAL, bg="#27ae60")

    def generate_pdf(self):
        """Abre a janela para salvar o PDF e chama a função de geração."""
        if not self.csv_path:
            messagebox.showwarning("⚠️ Aviso", "Por favor, selecione um arquivo primeiro.")
            return

        pdf_path = filedialog.asksaveasfilename(
            title="💾 Salvar PDF como...",
            defaultextension=".pdf",
            filetypes=[("Arquivos PDF", "*.pdf")]
        )
        if pdf_path:
            # Feedback visual durante o processamento
            self.btn_generate_pdf.config(text="🔄 PROCESSANDO...", state=tk.DISABLED, bg="#f39c12")
            self.root.update()
            
            try:
                gerar_pdf_etiquetas(self.csv_path, pdf_path)
            finally:
                # Restaura o botão
                self.btn_generate_pdf.config(text="🎯 2. GERAR PDF COM ETIQUETAS", state=tk.NORMAL, bg="#27ae60")


if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()
