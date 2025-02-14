#!/bin/bash

echo "🚀 Iniciando a instalação do Winbox e configuração do handler..."

# Verificar se o yay está instalado
if ! command -v yay &>/dev/null; then
    echo "❌ O yay não está instalado. Instale-o antes de continuar."
    exit 1
fi

echo "📦 Instalando o Winbox (winbox3 e winbox) via yay..."
yay -S --noconfirm winbox3 winbox

# Verificar se o Winbox foi instalado corretamente
if ! command -v winbox3 &>/dev/null; then
    echo "❌ Erro: O winbox3 não foi instalado corretamente."
    exit 1
fi

if ! command -v winbox &>/dev/null; then
    echo "❌ Erro: O winbox não foi instalado corretamente."
    exit 1
fi

echo "✅ Winbox instalado com sucesso!"

echo "🔧 Criando o script handler em /usr/local/bin/winbox-handler..."
sudo bash -c 'cat > /usr/local/bin/winbox-handler' <<'EOF'
#!/bin/bash

# Remover o prefixo winbox:
parametro="${1#winbox:}"

# Executar o Winbox com o IP extraído
/usr/bin/winbox3 "$parametro" > /dev/null 2>&1 &
EOF

# Tornar o script executável
sudo chmod +x /usr/local/bin/winbox-handler
echo "✅ Script handler criado e tornado executável."

echo "📂 Criando o arquivo .desktop em /usr/share/applications/winbox.desktop..."
sudo bash -c 'cat > /usr/share/applications/winbox.desktop' <<'EOF'
[Desktop Entry]
Name=Winbox
Comment=Abrir roteadores MikroTik
Exec=/usr/local/bin/winbox-handler %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/winbox;
EOF

echo "✅ Arquivo .desktop criado."

echo "🔗 Registrando o protocolo winbox: no sistema..."
xdg-mime default winbox.desktop x-scheme-handler/winbox

echo "✅ Protocolo registrado com sucesso!"

# Testar se foi registrado corretamente
registrado=$(xdg-mime query default x-scheme-handler/winbox)

if [[ "$registrado" == "winbox.desktop" ]]; then
    echo "🎉 Tudo pronto! Agora você pode usar:"
    echo "    xdg-open winbox:10.0.0.1"
else
    echo "⚠️ Algo deu errado no registro do protocolo."
fi
