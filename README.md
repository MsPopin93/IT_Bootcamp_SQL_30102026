# IT Bootcamp SQL Project

**Autor:** Ivana Popin

## Opis projekta

Projekat je izrađen u okviru **IT Bootcamp Data Engineering** kursa.

## Podaci

Korišćeni su podaci o fudbalskim utakmicama iz sezona:

- 2023/24
- 2024/25

---

# Part G - Model podataka

## Cilj

Izrada modela za analizu kartona kroz kreiranje **zvezdaste šeme (Star Schema)**.

Zvezdasta šema se sastoji od više dimenzionih tabela koje okružuju centralnu fact tabelu sa događajima vezanim za kartone.

## Dimenzije

### dim_team
Svi klubovi.

### dim_calendar
Lista datuma od:

- 2023-07-01
- do
- 2025-06-30

### dim_player
Svi igrači iz tabele `players` uz dodatog nepoznatog člana:

```text
player_id = -1
```

### dim_referee
Sve sudije.

## Fact tabela

### fact_card

Jedan red predstavlja jedan karton:

- yellow_card
- second_yellow
- red_card

Podaci se preuzimaju iz tabele:

```text
match_events
```

---

## Napomene

- Jedan meč može sadržati više kartona.
- Igrač može dobiti više kartona tokom sezone.

---

## Ključevi i veze

| Fact tabela | Dimenzija |
|------------|------------|
| team_id | dim_team |
| date_key | dim_calendar |
| player_id | dim_player |
| referee_id | dim_referee |

---

## Zašto fact_card?

Model omogućava analizu kartona iz više uglova:

- broj kartona po igraču
- broj kartona po klubu
- broj kartona po sudiji
- broj kartona po mesecima
- broj kartona po sezonama
- poređenje klubova prema disciplinskim merama

