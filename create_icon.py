# 🎨 Gerador de Ícone Simples para o Aplicativo
# Este script cria um ícone básico para o instalador NSIS

try:
    from PIL import Image, ImageDraw, ImageFont
    import os

    def create_simple_icon():
        """Cria um ícone simples 32x32 para o aplicativo."""
        
        # Cria uma imagem 32x32 com fundo azul
        img = Image.new('RGBA', (32, 32), (52, 152, 219, 255))  # Azul bonito
        draw = ImageDraw.Draw(img)
        
        # Desenha um retângulo branco (representando uma etiqueta)
        draw.rectangle([6, 8, 26, 18], fill=(255, 255, 255, 255), outline=(44, 62, 80, 255), width=1)
        
        # Desenha linhas representando texto
        draw.line([8, 11, 24, 11], fill=(127, 140, 141, 255), width=1)
        draw.line([8, 13, 20, 13], fill=(127, 140, 141, 255), width=1)
        draw.line([8, 15, 22, 15], fill=(127, 140, 141, 255), width=1)
        
        # Desenha uma segunda etiqueta parcial
        draw.rectangle([6, 20, 26, 24], fill=(255, 255, 255, 255), outline=(44, 62, 80, 255), width=1)
        draw.line([8, 22, 24, 22], fill=(127, 140, 141, 255), width=1)
        
        # Salva o ícone
        current_dir = os.path.dirname(os.path.abspath(__file__))
        icon_path = os.path.join(current_dir, "icon.ico")
        img.save(icon_path, format='ICO')
        
        print(f"✅ Ícone criado: {icon_path}")
        return icon_path

    if __name__ == "__main__":
        print("🎨 Criando ícone simples para o aplicativo...")
        create_simple_icon()
        print("🎉 Ícone criado com sucesso!")
        print("\nPara usar no instalador NSIS:")
        print("1. Descomente as linhas de ícone no installer_wizard.nsi")
        print("2. Recompile o instalador com build_wizard.bat")

except ImportError:
    print("❌ Erro: Pillow não está instalado.")
    print("\nPara instalar: pip install Pillow")
    print("\nOu você pode usar um ícone pronto baixado da internet.")
    print("Salve como 'icon.ico' na pasta do projeto.")
