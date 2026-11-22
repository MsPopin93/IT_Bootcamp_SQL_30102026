# Izveštaj o sezoni 2024/25

## 1. Sezona u brojevima

| Metrika | Vrednost |
|----------|----------|
| Broj utakmica | 380 |
| Broj golova | 1092 |
| Prosečan broj golova po utakmici | 2,87 |
| Udeo pobeda domaćina | 41,32% |
| Udeo nerešenih utakmica | 25,00% |
| Udeo pobeda gostiju | 33,68% |

U sezoni 2024/25 odigrano je ukupno 380 utakmica na kojima je postignuto 1092 gola. Prosečno je postizano 2,87 golova po utakmici.

Domaći timovi ostvarili su pobedu u 41,32% utakmica, što je više od pobeda gostujućih timova (33,68%). Nerešeni rezultati činili su četvrtinu svih utakmica (25,00%), što ukazuje na relativno izjednačenu konkurenciju u ligi.

## 2. Po mesecima

| Mesec | Avg | Sep | Okt | Nov | Dec | Jan | Feb | Mar | Apr | Maj |
|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
| Broj utakmica | 28 | 32 | 30 | 37 | 52 | 51 | 40 | 40 | 40 | 30 |
| Broj golova | 99 | 78 | 102 | 96 | 145 | 137 | 119 | 113 | 124 | 79 |
| Prosek golova | 3.54 | 2.44 | 3.4 | 2.59 | 2.79 | 2.69 | 2.98 | 2.83 | 3.1 | 2.63 |


Koji se mesec izdvaja:
Izdvaja se mesec avgust, u njemu je najveći prosečan broj golova čak 3,54, dok je istovremeno najmanji broj utakmica!

## 3. Publika

Analiza posete pokazuje značajne razlike među stadionima.

- Najveću prosečnu posetu imao je stadion **Harbourside Park** (stadion_id = 1) sa prosečno **44.074** gledalaca po utakmici.
- Najmanju prosečnu posetu imao je **Dunmore Park** (stadion_id = 19).
- Najveću prosečnu popunjenost zabeležio je stadion **Elmsworth Lane** (stadion_id = 8) sa oko **91%** popunjenosti kapaciteta.
- Najmanju prosečnu popunjenost imao je **National Stadium** (stadion_id = 22) sa oko **36%**.

Tokom sezone nije zabeležena nijedna utakmica bez publike. Pronađeno je **9 utakmica bez podataka o poseti**. U odnosu na ukupno **380 odigranih utakmica**, broj nedostajućih podataka je mali (oko **2,4%** utakmica), pa ne bi trebalo značajno da utiče na ukupne zaključke o posećenosti stadiona.


## 4. Sudije

Sve aktivne sudije u sezoni 2024/25 sudile su po 20 utakmica, osim sudije **Paul Tierney-Ross** (referee_id = 20), koji nije sudio nijednu utakmicu.

Najviše kartona na jednoj utakmici pokazano je na meču **2154**, gde je sudija **Samuel Achebe** (referee_id = 17) dodelio čak **10 kartona**.

Posmatrano na nivou cele sezone, najveći ukupan broj kartona dodelio je **Peter Lindgren** (referee_id = 4), ukupno **85 kartona**. Najmanji broj kartona dodelio je **Samuel Achebe** (referee_id = 17), sa ukupno **55 kartona**.

Ovi rezultati pokazuju značajne razlike u disciplinskom kriterijumu među sudijama, iako je većina njih sudila isti broj utakmica.

## 5. Igrači

### Top 5 strelaca

| Igrač | Golovi |
|----------|----------:|
| Mattéo O'Brien | 34 |
| Leo Marsh (ID 676) | 32 |
| José Muñoz | 24 |
| Marko Stanković | 17 |
| Leo Marsh (ID 677) | 16 |

Mattéo O'Brien bio je najbolji strelac sezone sa 34 postignuta gola. U statistiku su uključeni i golovi iz igre i golovi iz penala.

Zanimljivo je da se među najboljim strelcima pojavljuju dva igrača sa imenom **Leo Marsh**, ali sa različitim `player_id` vrednostima (676 i 677). Nije moguće zaključiti da li je u pitanju duplikat u podacima ili dva različita igrača sa istim imenom, pa je za identifikaciju neophodno koristiti `player_id`.

### Top 5 asistenata

| Igrač | Asistencije |
|----------|----------:|
| Pablo Fernández | 9 |
| Filip Petrović | 7 |
| Eirik Solberg | 7 |
| Lucas Pereira | 7 |
| Mikkel Nielsen | 6 |

Najviše asistencija tokom sezone ostvario je Pablo Fernández sa ukupno 9 asistencija. Iza njega se nalaze Filip Petrović, Eirik Solberg i Lucas Pereira sa po 7 asistencija.

## 6. Kvalitet podataka

Tokom analize pronađena su dva potencijalna problema u kvalitetu podataka.

### Problem 1 - Nedostajući podaci o poseti

Pronađeno je 9 utakmica bez evidentiranih podataka o poseti.

| Pokazatelj | Vrednost |
|------------|-----------|
| Utakmice bez podataka o poseti | 9 |
| Utakmice bez publike | 0 |

U odnosu na ukupno 380 odigranih utakmica, nedostajući podaci čine oko 2,4% svih utakmica, pa njihov uticaj na ukupnu analizu publike nije značajan.

### Upit

```sql
SELECT
SUM(CASE WHEN attendance IS NULL THEN 1 ELSE 0 END)
AS utakmice_bez_posete
FROM matches
WHERE season = '2024/25';
```

## Problem 2 - Igrači sa istim imenom i prezimenom

Među najboljim strelcima pojavljuju se dva igrača sa imenom Leo Marsh, ali sa različitim identifikatorima (player_id 676 i 677).

| Player ID | Full Name |
|------------|-----------|
| 676 | Leo Marsh |
| 677 | Leo Marsh |

Nije moguće zaključiti da li se radi o dva različita igrača ili o dupliranom zapisu. Zbog toga je prilikom analize neophodno koristiti player_id kao jedinstveni identifikator.

### Upit

```sql
SELECT
first_name,
last_name,
COUNT(*) AS broj_igraca
FROM players
GROUP BY
first_name,
last_name
HAVING COUNT(*) > 1;
```
