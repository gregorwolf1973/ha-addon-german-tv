# 📺 German TV Panel – Home Assistant Add-on

Ein Home Assistant **Add-on**, das kostenlose deutsche TV-Sender (öffentlich-rechtlich) direkt als Ingress-Panel in deine Seitenleiste bringt.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fgregorwolf1973%2Fha-addon-german-tv)

---

## ✨ Features

- 🎬 HLS-Livestreaming direkt im Browser (kein externer Player nötig)
- 📋 **20 vordefinierte Sender** – alle öffentlich-rechtlich, verifiziert (Feb. 2026)
- 🗂️ Gruppiert nach: Öffentlich-Rechtlich · News · Regional · Kinder
- ➕ Sender im Panel **hinzufügen, bearbeiten, löschen**
- ⚙️ Vollständig konfigurierbar über die **Add-on-Konfiguration** in HA
- 🔒 Läuft als **Ingress** – kein offener Port, kein Reverse-Proxy nötig

---

## 🚀 Installation

### Schritt 1 – Repository hinzufügen

**Option A: One-Click (empfohlen)**

Klicke auf den Badge oben oder öffne direkt:

```
https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/gregorwolf1973/ha-addon-german-tv
```

**Option B: Manuell**

1. Home Assistant öffnen
2. **Einstellungen → Add-ons → Add-on-Store**
3. Oben rechts: **⋮ → Repositories**
4. URL eintragen: `https://github.com/gregorwolf1973/ha-addon-german-tv`
5. **Hinzufügen** klicken

### Schritt 2 – Add-on installieren

1. Im Add-on-Store nach **"German TV Panel"** suchen
2. **Installieren** klicken
3. Nach der Installation: **Starten**
4. Optional: **"In Seitenleiste anzeigen"** aktivieren

---

## ⚙️ Konfiguration

Die Sender werden direkt in der Add-on-Konfiguration gepflegt.  
**Einstellungen → Add-ons → German TV Panel → Konfiguration**

```yaml
channels:
  - name: "Das Erste HD"
    url: "https://daserste-live.ard-mcdn.de/daserste/live/hls/de/master.m3u8"
    logo: "https://..."        # optional
    category: "Öffentlich-Rechtlich"  # optional

  - name: "Mein IPTV Sender"
    url: "https://example.com/live/stream.m3u8"
    category: "Allgemein"
```

| Feld | Pflicht | Beschreibung |
|---|---|---|
| `name` | ✅ | Anzeigename |
| `url` | ✅ | HLS-Stream-URL (`.m3u8`) |
| `logo` | ➖ | Logo-Bild URL |
| `category` | ➖ | Kategorie-Gruppe |

> **Tipp:** Senderänderungen im Panel (＋ / ✏️ / 🗑️) sind nur für die aktuelle Browser-Sitzung gültig. Dauerhafte Änderungen immer in der Add-on-Konfiguration vornehmen.

---

## 📺 Vordefinierte Sender (Stand: Feb. 2026)

| Sender | Kategorie | Stream-Quelle |
|---|---|---|
| Das Erste HD | Öffentlich-Rechtlich | ARD-CDN |
| ZDF HD | Öffentlich-Rechtlich | Akamai |
| 3sat | Öffentlich-Rechtlich | Akamai |
| ARTE | Öffentlich-Rechtlich | Akamai |
| ARD Alpha | Öffentlich-Rechtlich | BR-CDN |
| ONE | Öffentlich-Rechtlich | ARD-CDN |
| ZDFneo | Öffentlich-Rechtlich | Akamai |
| ZDFinfo HD | Öffentlich-Rechtlich | Akamai |
| Tagesschau24 | News | Akamai |
| Phoenix HD | News | Akamai |
| WDR HD | Regional | Akamai |
| BR Fernsehen Süd/Nord HD | Regional | BR-CDN |
| NDR Hamburg/Niedersachsen HD | Regional | NDR-CDN |
| MDR Sachsen HD | Regional | Akamai |
| HR HD | Regional | Akamai |
| RBB Berlin HD | Regional | Akamai |
| SWR BW HD | Regional | Akamai |
| KiKA | Kinder | Akamai |

> Private Sender (RTL, ProSieben, SAT.1 etc.) bieten keine freien HLS-Streams an und sind daher nicht enthalten.

---

## 🛠️ Entwicklung

```bash
git clone https://github.com/gregorwolf1973/ha-addon-german-tv
cd ha-addon-german-tv/german_tv

# Lokal testen (Docker erforderlich)
docker build -t german-tv-test .
docker run -p 8099:8099 german-tv-test
# → http://localhost:8099
```

---

## 📄 Lizenz

MIT – siehe [LICENSE](../LICENSE)
