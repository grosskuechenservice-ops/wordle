# Wordle auf Deutsch

Ein deutschsprachiges Wordle-Spiel, spielbar als Python-Script oder PowerShell-Script.

## Spielprinzip

Errate das geheime 5-Buchstaben-Wort in maximal 6 Versuchen.

Nach jedem Versuch bekommst du Hinweise:
- **Grün** — Buchstabe ist richtig und an der richtigen Stelle
- **Gelb** — Buchstabe kommt vor, aber an der falschen Stelle
- **Grau** — Buchstabe kommt im Wort nicht vor

## Starten

**Python:**
```bash
python wordle.py
```

**PowerShell:**
```powershell
.\wordle.ps1
```

## Voraussetzungen

- Python 3.8+ **oder** PowerShell 5.1+
- Keine zusätzlichen Pakete nötig

## Spielstand

Siege, Niederlagen und Serien werden in `scores.json` gespeichert.
