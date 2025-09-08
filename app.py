import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import pandas as pd
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib.units import cm
import os

# --- Configurações das Etiquetas ---
# Baseado no formato comum Pimaco 6181/6281 (10 linhas, 2 colunas)
# Se seu formulário for diferente, ajuste as medidas aqui.
ETIQUETA_LARGURA = 9.9 * cm
ETIQUETA_ALTURA = 2.54 * cm
MARGEM_ESQUERDA = 0.6 * cm
MARGEM_SUPERIOR = 1.6 * cm
COLUNAS = 2
LINHAS = 10

# Espaçamento entre as etiquetas. Deixe 0 se elas forem coladas.
ESPACAMENTO_HORIZONTAL = 0.1 * cm
ESPACAMENTO_VERTICAL = 0 * cm

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

        # Inicia a criação do arquivo PDF.
        c = canvas.Canvas(pdf_path, pagesize=A4)
        _, altura_pagina = A4

        col = 0
        row = 0

        # Itera sobre cada linha do arquivo CSV para criar uma etiqueta.
        for index, item in df.iterrows():
            try:
                # Calcula a posição X e Y da etiqueta atual na página.
                x = MARGEM_ESQUERDA + col * (ETIQUETA_LARGURA + ESPACAMENTO_HORIZONTAL)
                y = altura_pagina - MARGEM_SUPERIOR - row * (ETIQUETA_ALTURA + ESPACAMENTO_VERTICAL)

                # --- Desenha o conteúdo da etiqueta ---
                texto_x = x + 0.3 * cm
                texto_y = y - 0.6 * cm

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
        self.root.geometry("600x400")
        self.root.resizable(True, False)
        
        # Configura o tema e cores
        self.setup_style()
        
        self.csv_path = None

        # Frame principal com gradiente visual
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

        # Container para os botões e informações
        content_frame = tk.Frame(main_frame, bg="#ffffff", relief="ridge", bd=2)
        content_frame.pack(expand=True, fill=tk.BOTH, pady=10)
        
        # Frame interno com padding
        inner_frame = tk.Frame(content_frame, bg="#ffffff")
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
                                 "• Formato das etiquetas: Pimaco 6181/6281 (A4)", 
                            font=("Arial", 9), 
                            fg="#7f8c8d", 
                            bg="#ecf0f1",
                            justify="left")
        info_text.pack(padx=15, pady=(0, 10))

        # Footer
        footer_frame = tk.Frame(main_frame, bg="#f0f0f0")
        footer_frame.pack(side=tk.BOTTOM, pady=(20, 0))
        
        footer = tk.Label(footer_frame, 
                         text="💡 Uma solução simples e profissional para criação de etiquetas", 
                         font=("Arial", 9), 
                         fg="#95a5a6", 
                         bg="#f0f0f0")
        footer.pack()

    def setup_style(self):
        """Configura o estilo visual da aplicação."""
        # Configurações de estilo podem ser expandidas aqui
        pass

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
