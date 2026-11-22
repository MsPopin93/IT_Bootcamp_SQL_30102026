--Izveštaj sezone 2024/25

--1. Pregled sezone -- 
--broj utakmica i golova
--prosečan broj golova po utakmici
SELECT
m.season,
count(m.match_id) as broj_utakmica,
sum(m.home_goals + m.away_goals) as broj_golova,
round(avg(m.home_goals + m.away_goals),2) as prosecan_br_golova,
round(100 * sum(CASE WHEN m.home_goals > m.away_goals THEN 1 ELSE 0 END) / count(m.match_id),2) as pobede_domacina,
round(100 * sum(CASE WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END)/ count(m.match_id),2) as nereseno,
round(100 *sum(CASE WHEN m.home_goals < m.away_goals THEN 1 ELSE 0 END)/ count(m.match_id),2) as pobede_gostiju

FROM matches m 
WHERE m.season = '2024/25'

group BY
m.season;

-----------------------------------------------------------------------------------------------------------------
--2. Meseci
--broj utakmica i golova po mesecima
--prosečan broj golova po utakmici
SELECT
m.season,
month(m.kickoff_ts) as month,
count(m.match_id) as broj_utakmica,
sum(m.home_goals + m.away_goals) as broj_golova,
round(avg(m.home_goals + m.away_goals),2) as prosecan_br_golova,
round(100 * sum(CASE WHEN m.home_goals > m.away_goals THEN 1 ELSE 0 END) / count(m.match_id),2) as pobede_domacina,
round(100 * sum(CASE WHEN m.home_goals = m.away_goals THEN 1 ELSE 0 END)/ count(m.match_id),2) as nereseno,
round(100 *sum(CASE WHEN m.home_goals < m.away_goals THEN 1 ELSE 0 END)/ count(m.match_id),2) as pobede_gostiju

FROM matches m 
WHERE m.season = '2024/25'

group BY
m.season,
month;
--Izdvaja se mesec avgust, u njemu je najveći prosečan broj golova čak 3,54, dok je istovremeno najmanji broj utakmica!
-----------------------------------------------------------------------------------------------------------------
--3. Publika
--Prosečna poseta i popunjenost (odnos posete i kapaciteta) po stadionu,
--Koliko utakmica nema podataka o poseti?
--Utakmica bez publike

SELECT
m.stadium_id,
s.stadium_name,
round(avg(m.attendance),2) as prosecna_poseta,
Round(avg(m.attendance/s.capacity) *100.0) as prosecna_popunjenost_utakmica,
SUM(case when m.attendance is null then 1 else 0 end) as broj_utakmica_bez_podataka_o_poseti,
SUM(case when m.attendance = 0 then 1 else 0 end) as broj_utakmica_bez_publike
FROM matches m 
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE m.season = '2024/25'
group by 
m.stadium_id,
s.stadium_name;


-----------------------------------------------------------------------------------------------------------------
--4. Sudije -- broj utakmica i broj kartona u sezoni
with sve_utakmice_sudije as (
select 
r.referee_id,
r.referee_name,
count(m.match_id) as broj_utakmica
from referees r 
left join matches m on r.referee_id = m.referee_id and m.season = '2024/25'
where 1=1
group by 
r.referee_id,
r.referee_name
--and m.match_id = '2001'
),
utakmice_sa_kartonima (
select 
m.match_id,
m.referee_id,
r.referee_name,
count(me.event_id) as broj_kartona_po_utakmici
from matches m
inner join referees r on r.referee_id = m.referee_id
inner join match_events me on me.match_id = m.match_id and me.event_type in ('yellow_card', 'second_yellow','red_card') 
where 1=1
and m.season = '2024/25'
group by
m.match_id,
m.referee_id,
r.referee_name
)


    select 
    uk.referee_id,
    uk.referee_name,
    sum(broj_kartona_po_utakmici) as uk_broj_kartona,
    broj_utakmica
    from utakmice_sa_kartonima uk
    left join sve_utakmice_sudije s on s.referee_id = uk.referee_id
    group by
    uk.referee_id,
    uk.referee_name,
    broj_utakmica;


--Sudija sa najvećim brojem kartona Peter Lindgren - čak 85, sa najmanje kartona Samel Achebe čak 55
--Interesantno da su sve sudije u sezoni imale po 20 utakmica, osim Paul Tierney-Ross koji je imao 0


-----------------------------------------------------------------------------------------------------------------
--5. Igrači
--a) 5. najbolja stelca kluba
--b) 5. najbolji asistent


--a) najbolji strelci sezone

with utakmice as (
select 
m.kickoff_ts,
m.match_id,
m.home_team_id as team_id

from matches m
WHERE m.season = '2024/25'

union 

select 
m.kickoff_ts,
m.match_id,
m.away_team_id as team_id

from matches m
WHERE m.season = '2024/25'
)

SELECT
me.player_id,
p.first_name,
p.last_name,
--me.related_player_id,
sum(case when me.event_type IN ('goal', 'penalty_goal') then 1 else 0 end) as broj_golova
from utakmice u
INNER JOIN match_events me ON  me.match_id = u.match_id and u.team_id = me.team_id and me.event_type IN ('goal', 'penalty_goal')
INNER JOIN players p ON  p.player_id = me.player_id

GROUP BY
me.player_id,
p.first_name,
p.last_name
ORDER BY broj_golova desc
LIMIT 5;

--najbolji strelci su oni koji su postigli i redovne i penalty golove i to najvise u sezoni 
--Mattéo O'Brien 34
--u listi najboljih strelaca imamo dva Leo Marsh ali srećom različit player_id, ili je dva puta isti igrač pod dva različita id
------------------------------------------------------------------------------------------
--b) 5. najbolji asistent
with utakmice as (
select 
m.kickoff_ts,
m.match_id,
m.home_team_id as team_id

from matches m
WHERE m.season = '2024/25'

union 

select 
m.kickoff_ts,
m.match_id,
m.away_team_id as team_id

from matches m
WHERE m.season = '2024/25'
)

SELECT
me.related_player_id,
p.first_name,
p.last_name,

sum(case when me.event_type IN ('goal') then 1 else 0 end) as broj_asistencija
from utakmice u
INNER JOIN match_events me ON  me.match_id = u.match_id and u.team_id = me.team_id and me.event_type IN ('goal')
INNER JOIN players p ON  p.player_id = me.related_player_id

GROUP BY
me.related_player_id,
p.first_name,
p.last_name
ORDER BY broj_asistencija desc
LIMIT 5;
--najvise assistencija je u sezoni imao Pablo Fernández, čak 9
--a najmanje Mikkel Nielsen 6


--6. Kvalitet podataka


--Broj_utakmica bez podataka o poseti 9


Select sum(broj_utakmica_bez_podataka_o_poseti) from (
SELECT
m.stadium_id,
s.stadium_name,
round(avg(m.attendance),2) as prosecna_poseta,
Round(avg(m.attendance/s.capacity) *100.0) as prosecna_popunjenost_utakmica,
SUM(case when m.attendance is null then 1 else 0 end) as broj_utakmica_bez_podataka_o_poseti,
SUM(case when m.attendance = 0 then 1 else 0 end) as broj_utakmica_bez_publike
FROM matches m 
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE m.season = '2024/25'
group by 
m.stadium_id,
s.stadium_name
);

--Broj_utakmica bez publike  0

Select sum(broj_utakmica_bez_publike) from (
SELECT
m.stadium_id,
s.stadium_name,
round(avg(m.attendance),2) as prosecna_poseta,
Round(avg(m.attendance/s.capacity) *100.0) as prosecna_popunjenost_utakmica,
SUM(case when m.attendance is null then 1 else 0 end) as broj_utakmica_bez_podataka_o_poseti,
SUM(case when m.attendance = 0 then 1 else 0 end) as broj_utakmica_bez_publike
FROM matches m 
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE m.season = '2024/25'
group by 
m.stadium_id,
s.stadium_name
)