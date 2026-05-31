#Requires -Version 5.1

$WORDS = @(
    "APFEL","BAUCH","BRIEF","BUSCH","DACHS","DECKE","DRAHT","DUNST","DURCH",
    "ENGEL","ERBSE","FALKE","FARBE","FAUST","FEUER","FISCH","FLUSS","FORST",
    "FUCHS","GABEL","GASSE","GEIST","GLEIS","GNADE","GRUBE","GRUND","HAFEN",
    "HAUPT","HOBEL","HUTTE","KABEL","KATZE","KERZE","KISTE","KLANG","KLAUE",
    "KNALL","KNOPF","KREIS","KREUZ","KRONE","LACHS","LAMPE","LANZE","LASER",
    "LAUBE","LAUNE","LEDER","LEHRE","LICHT","LISTE","MARKT","MAUER","MASKE",
    "MEISE","MILCH","MITTE","NACHT","NADEL","NAGEL","NEBEL","NELKE","NOTIZ",
    "PANNE","PAUSE","PFEIL","PFERD","PHASE","PILOT","PLATZ","PUNKT","PUPPE",
    "RAUCH","REGEN","REIHE","REISE","RIESE","RINDE","ROHRE","RUNDE","SACHE",
    "SALAT","SCHAF","SCHUH","SEIFE","SENSE","SOCKE","SONNE","SORGE","STAHL",
    "STAMM","STERN","STIFT","STOCK","STURM","SUCHE","SZENE","TANNE","TASTE",
    "TINTE","TISCH","TITEL","TURBO","TURM","VOGEL","WACHE","WAGEN","WANZE",
    "WATTE","WELLE","WENDE","WOCHE","WOLKE","WUNDE","ZAHNE","ZEBRA","STOPP",
    "SPORT","SPORN","PREIS","PROBE","KRAFT","KRANZ","BLATT","GLANZ","TRAUM",
    "FRANK","FLECK","FLACH","ZWECK","ZWANG","KLEIN"
)

$ScoresFile = Join-Path $PSScriptRoot "scores.json"

function Load-Scores {
    if (Test-Path $ScoresFile) {
        $raw = Get-Content $ScoresFile -Raw | ConvertFrom-Json
        return @{
            wins        = [int]$raw.wins
            losses      = [int]$raw.losses
            streak      = [int]$raw.streak
            best_streak = [int]$raw.best_streak
            dist        = @{"1"=[int]$raw.dist."1";"2"=[int]$raw.dist."2";"3"=[int]$raw.dist."3";
                            "4"=[int]$raw.dist."4";"5"=[int]$raw.dist."5";"6"=[int]$raw.dist."6"}
        }
    }
    return @{wins=0;losses=0;streak=0;best_streak=0;dist=@{"1"=0;"2"=0;"3"=0;"4"=0;"5"=0;"6"=0}}
}

function Save-Scores($sc) {
    $obj = [pscustomobject]@{
        wins=$sc.wins; losses=$sc.losses; streak=$sc.streak; best_streak=$sc.best_streak
        dist=[pscustomobject]@{"1"=$sc.dist."1";"2"=$sc.dist."2";"3"=$sc.dist."3";
                               "4"=$sc.dist."4";"5"=$sc.dist."5";"6"=$sc.dist."6"}
    }
    $obj | ConvertTo-Json | Set-Content $ScoresFile -Encoding utf8
}

function Write-C($text, $fg, $bg) {
    $of = $Host.UI.RawUI.ForegroundColor
    $ob = $Host.UI.RawUI.BackgroundColor
    if ($fg) { $Host.UI.RawUI.ForegroundColor = $fg }
    if ($bg) { $Host.UI.RawUI.BackgroundColor = $bg }
    Write-Host $text -NoNewline
    $Host.UI.RawUI.ForegroundColor = $of
    $Host.UI.RawUI.BackgroundColor = $ob
}

function Print-Header {
    Write-Host ""
    Write-C "+==========================+" "Cyan" $null; Write-Host ""
    Write-C "|   W O R D L E  (DE)     |" "Cyan" $null; Write-Host ""
    Write-C "|  Errate das 5-Buchstaben-Wort!  |" "Cyan" $null; Write-Host ""
    Write-C "+==========================+" "Cyan" $null; Write-Host ""
    Write-Host "  Gruen=richtig  Gelb=falsche Stelle  Grau=nicht im Wort"
    Write-Host ""
}

function Get-States($guess, $target) {
    $states = @("gray","gray","gray","gray","gray")
    $rem = $target.ToCharArray()
    for ($i = 0; $i -lt 5; $i++) {
        if ($guess[$i] -eq $target[$i]) { $states[$i] = "green"; $rem[$i] = $null }
    }
    for ($i = 0; $i -lt 5; $i++) {
        if ($states[$i] -eq "green") { continue }
        $idx = [Array]::IndexOf($rem, $guess[$i])
        if ($idx -ge 0) { $states[$i] = "yellow"; $rem[$idx] = $null }
    }
    return $states
}

function Print-Row($guess, $target) {
    Write-Host "  " -NoNewline
    $states = Get-States $guess $target
    for ($i = 0; $i -lt 5; $i++) {
        $ch = " " + $guess[$i] + " "
        switch ($states[$i]) {
            "green"  { Write-C $ch "Black" "Green" }
            "yellow" { Write-C $ch "Black" "Yellow" }
            "gray"   { Write-C $ch "White" "DarkGray" }
        }
        Write-Host " " -NoNewline
    }
    Write-Host ""
}

function Print-Empty {
    Write-Host "  " -NoNewline
    for ($i = 0; $i -lt 5; $i++) {
        Write-C " _ " "DarkGray" $null
        Write-Host " " -NoNewline
    }
    Write-Host ""
}

function Print-Keys($guesses, $target) {
    $rows = @("QWERTZUIOP","ASDFGHJKL","YXCVBNM")
    $state = @{}
    foreach ($g in $guesses) {
        $states = Get-States $g $target
        for ($i = 0; $i -lt 5; $i++) {
            $ch = [string]$g[$i]
            if ($states[$i] -eq "green") { $state[$ch] = "green" }
            elseif ($states[$i] -eq "yellow" -and $state[$ch] -ne "green") { $state[$ch] = "yellow" }
            elseif (-not $state.ContainsKey($ch)) { $state[$ch] = "gray" }
        }
    }
    Write-Host ""
    foreach ($row in $rows) {
        Write-Host "  " -NoNewline
        foreach ($ch in $row.ToCharArray()) {
            $k = [string]$ch
            switch ($state[$k]) {
                "green"  { Write-C (" " + $k + " ") "Black" "Green" }
                "yellow" { Write-C (" " + $k + " ") "Black" "Yellow" }
                "gray"   { Write-C (" " + $k + " ") "White" "DarkGray" }
                default  { Write-Host ("[" + $k + "]") -NoNewline }
            }
        }
        Write-Host ""
    }
    Write-Host ""
}

function Print-Stats($sc) {
    $total = $sc.wins + $sc.losses
    $pct = if ($total -gt 0) { [int]($sc.wins * 100 / $total) } else { 0 }
    Write-Host ""
    Write-C "-- Statistik --" "Cyan" $null; Write-Host ""
    Write-Host ("  Gespielt: " + $total + "  Gewonnen: " + $sc.wins + " (" + $pct + " Prozent)")
    Write-Host ("  Serie: " + $sc.streak + "  Beste Serie: " + $sc.best_streak)
    Write-Host "  Verteilung:"
    for ($i = 1; $i -le 6; $i++) {
        $n = $sc.dist["$i"]
        $bar = ""; for ($b = 0; $b -lt $n; $b++) { $bar += "#" }
        Write-Host ("    " + $i + " | " + $bar + " (" + $n + ")")
    }
    Write-Host ""
}

function Play {
    $target = ($WORDS | Get-Random)
    $guesses = @()
    $maxG = 6
    $sc = Load-Scores

    while ($true) {
        Clear-Host
        Print-Header

        foreach ($g in $guesses) { Print-Row $g $target }
        for ($r = $guesses.Count; $r -lt $maxG; $r++) { Print-Empty }
        Print-Keys $guesses $target

        if ($guesses.Count -gt 0 -and $guesses[-1] -eq $target) {
            $n = $guesses.Count
            $suf = if ($n -ne 1) { "en" } else { "" }
            Write-C ("  Richtig! In " + $n + " Versuch" + $suf + "!") "Green" $null; Write-Host ""
            $sc.wins++; $sc.streak++
            if ($sc.streak -gt $sc.best_streak) { $sc.best_streak = $sc.streak }
            $sc.dist["$n"]++
            Save-Scores $sc
            Print-Stats $sc
            break
        }

        if ($guesses.Count -ge $maxG) {
            Write-C ("  Verloren! Das Wort war: " + $target) "Red" $null; Write-Host ""
            $sc.losses++; $sc.streak = 0
            Save-Scores $sc
            Print-Stats $sc
            break
        }

        $att = $guesses.Count + 1
        Write-Host ("  Versuch " + $att + "/" + $maxG + " -- 5 Buchstaben eingeben:")
        $inp = (Read-Host "  >").Trim().ToUpper()

        if ($inp.Length -ne 5) {
            Write-C "  Bitte genau 5 Buchstaben!" "Red" $null; Write-Host ""
            Start-Sleep -Milliseconds 800
            continue
        }

        $guesses += $inp
    }

    Write-Host "  Nochmal? (j/n)"
    $again = (Read-Host "  >").Trim().ToLower()
    if ($again -eq "j") { Play }
    else { Write-C "  Tschuess! Bis bald." "Cyan" $null; Write-Host ""; Write-Host "" }
}

Play
