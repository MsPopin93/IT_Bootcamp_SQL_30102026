Ivana Popin

OPIS PROJEKTA: IT_Bootcamp_kurs data engineering kurs

PODACI: o utakmicama u sezoni 2023/24 i sezoni 2024/25

--Part G
MODEL PODATAKA: Izrada modela za analizu kartona kroz kreiranje zvezdaste seme. 
Zvezdasta sema podrazumeva izradu vise dimenzionih tabela, oko fact tabele koja sadrzi sve dogadjaje vezane za kartone.

Dimenzije:
a) dim_team - svi klubovi
b) dim_calendar - lista datuma od prve utakmice '2023-07-01' do poslednje '2025-06-30'
c) dim_player - svi igrači iz players + nepoznati član sa player_id = -1
d) dim_referee - sve sudije 

FACT TABELA:
fact_card - jedan red po kartonu (yellow_card, second_yellow ili red_card). preuzeto iz match_events

NAPOMENA:
Jedan meč može sadržati više kartona.
Igrač može dobiti više kartona tokom sezone

KLJUČEVI I VEZE:

team_id → dim_team
date_key → dim_date
player_id → dim_player
referee_id → dim_referee

ZAŠTO FACT_CARD
Zato što se kartoni mogu analizirati iz vise uglova: po klubu, igraču, po mesecima, sudiji i slicno. Ovaj model onda omogucava analizu:
broj kartona po igracu
broj kartona po sudiji
broj kartona po klubovima
