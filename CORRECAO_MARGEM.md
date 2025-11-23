# 🔧 Correção de Margem Superior - Guia de Teste

## 📋 Problema Identificado

**Sintoma**: PDF gerado com margem superior de ~3cm em vez da configurada
**Causa**: Dupla aplicação de margem (margem da página + margem interna do texto)

## ✅ Correções Aplicadas

### 1. **Margem Interna do Texto Reduzida**
```python
# ANTES:
texto_x = x + 0.3 * cm
texto_y = y - 0.6 * cm  # Margem muito alta

# DEPOIS:
texto_x = x + 0.2 * cm  # Margem lateral menor
texto_y = y - 0.3 * cm  # Margem superior menor (50% de redução)
```

### 2. **Margem Superior Padrão Ajustada**
```python
# ANTES:
MARGEM_SUPERIOR = 1.6 * cm

# DEPOIS:
MARGEM_SUPERIOR = 1.2 * cm  # Redução de 0.4cm
```

### 3. **Interface Atualizada**
- Valor padrão na interface: `1.2 cm`
- Preset Pimaco atualizado: `1.2 cm`
- Carregamento de padrões: fallback para `1.2 cm`

## 🧪 Como Testar

### Teste Rápido
1. **Execute** o aplicativo atualizado: `dist\Gerador_Etiquetas.exe`
2. **Carregue** um arquivo CSV de teste
3. **Gere** um PDF com configurações padrão
4. **Meça** a margem superior com uma régua

### Teste Detalhado
1. **Aba Personalização**:
   - Verifique se margem superior mostra `1.2`
   - Teste com `1.0`, `1.2`, `1.5` para comparar
   - Use "🔄 Aplicar Alterações" após cada mudança

2. **Presets**:
   - Teste "📄 Pimaco 6181/6281"
   - Verifique se aplica `1.2 cm`

3. **Padrões Salvos**:
   - Salve um padrão com margem `1.0 cm`
   - Carregue e teste

## 📐 Valores Recomendados

| **Situação** | **Margem Superior** | **Observação** |
|--------------|-------------------|----------------|
| **Pimaco 6181/6281** | 1.2 cm | Padrão corrigido |
| **Folha comum A4** | 1.0 cm | Para máximo aproveitamento |
| **Impressora problemática** | 1.5 cm | Se cortar no topo |
| **Etiquetas grandes** | 1.8 cm | Para etiquetas >4cm altura |

## 🎯 Resultado Esperado

- **Margem superior real**: ~1.2-1.3 cm (em vez de 3cm)
- **Melhor aproveitamento** da página
- **Alinhamento correto** com folhas de etiqueta padrão
- **Texto bem posicionado** dentro de cada etiqueta

## 🐛 Se Ainda Houver Problemas

### Margem ainda muito grande:
```
Solução: Reduza para 0.8 ou 1.0 cm na aba Personalização
```

### Margem muito pequena (texto cortado):
```
Solução: Aumente para 1.5 ou 1.8 cm na aba Personalização
```

### Impressora específica:
```
Solução: Teste diferentes valores e salve como padrão personalizado
```

## 📝 Notas Técnicas

- **Margem da página**: Distância do topo da folha até a primeira etiqueta
- **Margem interna**: Distância dentro da etiqueta até o texto
- **Total**: Soma das duas margens = posição final do texto

## ✅ Verificação Final

Execute este checklist após a correção:

- [ ] Margem superior ≤ 1.5 cm na primeira etiqueta
- [ ] Texto não cortado no topo
- [ ] Alinhamento correto com etiquetas físicas
- [ ] Configuração salva corretamente
- [ ] Presets funcionando

---

**✨ As correções já foram aplicadas e o executável recompilado!**
**Execute `dist\Gerador_Etiquetas.exe` para testar as melhorias.**
