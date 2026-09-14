#!/bin/bash
cd "$(dirname "$0")"
PORT=8775

# Serveur accessible depuis le Mac et les appareils du même Wi-Fi.
python3 -m http.server "$PORT" --bind 0.0.0.0 >/tmp/revise6e_parent_server_v139.log 2>&1 &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null' EXIT
sleep 1

# Adresse réseau du Mac.
IP=$(ipconfig getifaddr en0 2>/dev/null)
if [ -z "$IP" ]; then IP=$(ipconfig getifaddr en1 2>/dev/null); fi
if [ -z "$IP" ]; then IP=""; fi

if [ -n "$IP" ]; then
  MOBILE_URL="http://${IP}:${PORT}/parent.html?v=138"
else
  MOBILE_URL=""
fi

# Crée automatiquement une petite page avec QR code sur le Mac.
python3 - "$PORT" "$MOBILE_URL" <<'PY'
import sys, html
from pathlib import Path
port=sys.argv[1]
url=sys.argv[2]
base=Path('.')
qr_path=base/'qr_telephone_v139.png'
if url:
    try:
        import qrcode
        qrcode.make(url).save(qr_path)
    except Exception:
        pass
page=f'''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Révise ta 6e ! — Téléphone</title><style>body{{font-family:Arial,sans-serif;background:#f7f5ff;color:#302d45;text-align:center;padding:30px}}.box{{max-width:520px;margin:auto;background:white;border-radius:24px;padding:28px;box-shadow:0 8px 30px #0001}}img{{width:280px;max-width:80vw;border-radius:16px}}.url{{word-break:break-all;background:#f1edff;padding:12px;border-radius:12px;margin-top:18px}}</style></head><body><div class="box"><h1>📱 Ouvrir l'espace parent</h1><p>Sur ton téléphone, scanne ce QR code.</p>{('<img src="qr_telephone_v139.png" alt="QR code">' if url else '<p>Impossible de détecter automatiquement l’adresse réseau du Mac.</p>')}<div class="url">{html.escape(url) if url else 'Vérifie que le Mac est connecté au Wi-Fi.'}</div><p>Le Mac et le téléphone doivent être sur le <b>même Wi-Fi</b>.</p></div></body></html>'''
(base/'acces_telephone_v139.html').write_text(page,encoding='utf-8')
PY

ACCESS_URL="http://localhost:${PORT}/acces_telephone_v139.html"
open "$ACCESS_URL"

# L'adresse du Mac reste disponible directement.
open "http://localhost:${PORT}/parent.html?v=138"

wait $SERVER_PID
