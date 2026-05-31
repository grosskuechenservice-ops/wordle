import random
import os
import json
from datetime import date

WORDS = [
    "APFEL", "BAUCH", "BRIEF", "BUSCH", "DACHS", "DECKE", "DOCHT", "DRAHT",
    "DUNST", "DURCH", "EBENE", "ENGEL", "ERBSE", "FALKE", "FARBE", "FAUST",
    "FEUER", "FISCH", "FLUSS", "FORST", "FUCHS", "GABEL", "GASSE", "GEIST",
    "GLEIS", "GLÜCK", "GNADE", "GRUBE", "GRUND", "HAFEN", "HASEN", "HAUPT",
    "HERZ", "HOBEL", "HOLZ", "HÜGEL", "HÜRDE", "HÜTTE", "INSEL", "JAGD",
    "KABEL", "KATZE", "KERZE", "KISTE", "KLANG", "KLAUE", "KLEIN", "KNALL",
    "KNOPF", "KREIS", "KREUZ", "KRONE", "KÜCHE", "KUNDE", "KUNST", "KURVE",
    "LACHS", "LAMPE", "LANZE", "LASER", "LAUBE", "LAUNE", "LEDER", "LEHRE",
    "LICHT", "LISTE", "LÜCKE", "LUFT", "MARKT", "MAUER", "MASKE", "MEISE",
    "MILCH", "MITTE", "MÖNCH", "MÜCKE", "MÜNZE", "NACHT", "NADEL", "NAGEL",
    "NEBEL", "NELKE", "NONNE", "NOTIZ", "OCKER", "OFEN", "ORDEN", "OTTER",
    "PANNE", "PAUSE", "PFEIL", "PFERD", "PHASE", "PILOT", "PINNE", "PLATZ",
    "PUNKT", "PUPPE", "QUELLE", "RANCH", "RAUCH", "REGEN", "REIHE", "REISE",
    "RIESE", "RINDE", "RÖHRE", "RUNDE", "RUSSE", "SACHE", "SALAT", "SALBE",
    "SATZE", "SAURE", "SCHAF", "SCHUH", "SEIFE", "SENSE", "SKALA", "SOCKE",
    "SONNE", "SORGE", "STAHL", "STAMM", "STERN", "STIFT", "STOCK", "STURM",
    "SUCHE", "SZENE", "TANNE", "TASTE", "TAUFE", "TINTE", "TISCH", "TITEL",
    "TUMOR", "TURBO", "TURM", "ÜBUNG", "UFER", "ULMEN", "VOGEL", "WACHE",
    "WAGEN", "WANZE", "WATTE", "WELLE", "WENDE", "WOCHE", "WOLKE", "WUNDE",
    "WURM", "YACHT", "ZAHNE", "ZEBRA", "ZIEGE", "ZIMMER", "ZIRKEL", "ZUFALL",
    "STOPP", "SCHULD", "SPORT", "SPORN", "SPASS", "SPALT", "SPAHN", "SPATH",
    "PREIS", "PROBE", "PROFI", "KRAFT", "KRANZ", "KRACH", "KNABE", "KNAST",
    "BLATT", "BLASE", "BLANC", "BLAND", "GLANZ", "GLANB", "TRAUM", "TRAKT",
    "FRANK", "FLECK", "FLACH", "FLASK", "FLAIR", "FLAGG", "ZWECK", "ZWANG",
]

# Filter to exactly 5-letter words
WORDS = [w for w in WORDS if len(w) == 5]

SCORES_FILE = os.path.join(os.path.dirname(__file__), "scores.json")

GREEN  = "\033[42;30m"
YELLOW = "\033[43;30m"
GRAY   = "\033[100;37m"
RESET  = "\033[0m"
BOLD   = "\033[1m"
CYAN   = "\033[96m"
RED    = "\033[91m"


def load_scores():
    if os.path.exists(SCORES_FILE):
        with open(SCORES_FILE) as f:
            return json.load(f)
    return {"wins": 0, "losses": 0, "streak": 0, "best_streak": 0, "distribution": {str(i): 0 for i in range(1, 7)}}


def save_scores(scores):
    with open(SCORES_FILE, "w") as f:
        json.dump(scores, f, indent=2)


def clear():
    os.system("cls" if os.name == "nt" else "clear")


def print_header():
    print(f"{BOLD}{CYAN}")
    print("╔══════════════════════════════╗")
    print("║        W O R D L E  🇩🇪       ║")
    print("║     Errate das 5-Wort!       ║")
    print("╚══════════════════════════════╝")
    print(RESET)


def color_guess(guess, target):
    result = []
    target_chars = list(target)
    colored = [""] * 5
    used = [False] * 5

    # First pass: greens
    for i in range(5):
        if guess[i] == target[i]:
            colored[i] = GREEN + f" {guess[i]} " + RESET
            used[i] = True
            target_chars[i] = None

    # Second pass: yellows and grays
    for i in range(5):
        if colored[i]:
            continue
        if guess[i] in target_chars:
            idx = target_chars.index(guess[i])
            target_chars[idx] = None
            colored[i] = YELLOW + f" {guess[i]} " + RESET
        else:
            colored[i] = GRAY + f" {guess[i]} " + RESET

    return "".join(colored)


def print_keyboard(guesses, target):
    layout = ["QWERTZUIOP", "ASDFGHJKL", "YXCVBNM"]
    letter_state = {}
    for guess in guesses:
        for i, ch in enumerate(guess):
            if ch == target[i]:
                letter_state[ch] = "green"
            elif ch in target and letter_state.get(ch) != "green":
                letter_state[ch] = "yellow"
            elif ch not in letter_state:
                letter_state[ch] = "gray"

    print()
    for row in layout:
        print("  ", end="")
        for ch in row:
            state = letter_state.get(ch)
            if state == "green":
                print(GREEN + f" {ch} " + RESET, end="")
            elif state == "yellow":
                print(YELLOW + f" {ch} " + RESET, end="")
            elif state == "gray":
                print(GRAY + f" {ch} " + RESET, end="")
            else:
                print(f"[{ch}]", end="")
        print()
    print()


def print_scores(scores):
    total = scores["wins"] + scores["losses"]
    win_pct = int(scores["wins"] / total * 100) if total else 0
    print(f"{BOLD}📊 Statistik:{RESET}")
    print(f"  Gespielt: {total}  Gewonnen: {scores['wins']} ({win_pct}%)")
    print(f"  Serie: {scores['streak']}  Beste Serie: {scores['best_streak']}")
    print(f"{BOLD}  Verteilung:{RESET}")
    for i in range(1, 7):
        count = scores["distribution"].get(str(i), 0)
        bar = "█" * count
        print(f"  {i}: {bar} {count}")
    print()


def play():
    target = random.choice(WORDS)
    guesses = []
    max_guesses = 6
    scores = load_scores()

    while True:
        clear()
        print_header()

        # Print previous guesses
        for g in guesses:
            print("  " + color_guess(g, target))
        # Print empty rows
        for _ in range(max_guesses - len(guesses)):
            print("  " + GRAY + " _ " + RESET + GRAY + " _ " + RESET + GRAY + " _ " + RESET + GRAY + " _ " + RESET + GRAY + " _ " + RESET)

        print_keyboard(guesses, target)

        if guesses and guesses[-1] == target:
            attempt = len(guesses)
            print(f"{BOLD}🎉 Richtig! In {attempt} Versuch{'en' if attempt != 1 else'}!{RESET}")
            scores["wins"] += 1
            scores["streak"] += 1
            scores["best_streak"] = max(scores["streak"], scores["best_streak"])
            scores["distribution"][str(attempt)] = scores["distribution"].get(str(attempt), 0) + 1
            save_scores(scores)
            print_scores(scores)
            break

        if len(guesses) == max_guesses:
            print(f"{RED}{BOLD}❌ Verloren! Das Wort war: {target}{RESET}")
            scores["losses"] += 1
            scores["streak"] = 0
            save_scores(scores)
            print_scores(scores)
            break

        remaining = max_guesses - len(guesses)
        print(f"  {BOLD}Versuch {len(guesses)+1}/{max_guesses}{RESET} — Eingabe (5 Buchstaben):")
        guess = input("  > ").strip().upper()

        if len(guess) != 5:
            input(f"  {RED}Bitte genau 5 Buchstaben eingeben. [Enter]{RESET}")
            continue

        guesses.append(guess)

    print()
    again = input("  Nochmal spielen? (j/n): ").strip().lower()
    if again == "j":
        play()
    else:
        print(f"\n{CYAN}  Tschüss! Bis zum nächsten Mal.{RESET}\n")


if __name__ == "__main__":
    play()
