--1. Колико утакмица је одиграно у фебруару 2025?


SELECT COUNT(*) as broj_utakmica
FROM matches m
WHERE m.kickoff_ts >= '2025-02-01' AND kickoff_ts < '2025-03-01';

--U feb 2025 je odigrano 40 utakmica;

--2.a) Који стадион има највећи капацитет, 


SELECT s.*
FROM stadiums s
WHERE 1=1
ORDER BY s.capacity desc
LIMIT 1;

--Najveći kapacitet ima stadium 22 - National Stadium - Centralia - 80.000

--2. b) који је највећи стадион неког клуба?


SELECT 
t.team_id,
t.team_name,
s.stadium_id,
max(s.capacity) as najveci_stadion_kluba
FROM teams t
LEFT JOIN stadiums s on s.stadium_id = t.stadium_id
WHERE 1=1
GROUP BY 
t.team_id,
t.team_name,
s.stadium_id;

--3. Колико играча у лиги има српско држављанство (nationality = 'Serbia')?

--ukupno igrača srpskog drzavljanstva 42, ali ako gledamo samo one u ligi onda 39
select p.* from players p
where p.nationality = 'Serbia'
and p.player_id in (select distinct player_id from player_match_stats);

 --4. Колико утакмица је завршено резултатом 1:1?

--rezultatom nerešeno je zavšreno 191 utakmica
SELECT count(m.match_id) as broj_neresenih
FROM matches m
WHERE m.home_goals = m.away_goals;

--a ako baš želimo 1:1, onda je 94 utakmice
SELECT count(m.match_id) as broj_neresenih
FROM matches m
WHERE 1=1
and m.home_goals = 1
and m.away_goals = 1;

--5.  Колика је просечна посета по сезони?
SELECT
m.season,
avg(m.attendance) as avg_attendance
FROM matches m
WHERE 1=1
GROUP by m.season;

--6. Колико голова је дато из пенала по сезони?
select 
m.season,
count(me.event_id) as Broj_golova_iz_penala
from matches m
inner join match_events me on me.match_id = m.match_id and me.event_type = 'penalty_goal'
group by
m.season;

--select me.* from match_events me where me.event_type = 'penalty_goal';
--ukupan broj golova iz penala = 213, od toga 2023/24 104, a 2024/25 109;

--7. Колико различитих играча је дало бар један гол у сезони 2024/25?

--prvo golovi -- uk 2043
/*
select 
--count(me.event_id) as broj_golova
me.*
from match_events me where me.event_type in ('penalty_goal', 'goal');
*/

--dodajem filter za sezonu - 1033 golova u sezoni 24/25 --308 igrača
select count(distinct player_id)  from (
select 
m.season,
m.match_id,
me.player_id
--count(distinct me.player_id) as Broj_različitih_igrača
from matches m
inner join match_events me on me.match_id = m.match_id and me.event_type in ('penalty_goal', 'goal')
where m.season = '2024/25'
group by
m.season,
m.match_id,
me.player_id
);

--8.  Који судија је највише пута судио утакмице клуба Northport United?

with utakmice as (
select 
m.match_id,
m.home_team_id as team_id,
m.referee_id
from matches m

union 

select 
m.match_id,
m.away_team_id as team_id,
m.referee_id
from matches m
)

select 

--u.team_id,
--t.team_name,
r.referee_id,
r.referee_name,
count(u.match_id) as broj_utakmica
from utakmice u
inner join teams t on t.team_id = u.team_id and t.team_name = 'Northport United'
inner join referees r on r.referee_id = u.referee_id
group by r.referee_id, r.referee_name
order by broj_utakmica desc
limit 1;

--Najvise utakmica Northport United je sudio Peter Lindgren

--9. Који судија је у сезони 2024/25 имао највећи удео утакмица у којима је досуђен бар један пенал, дат или промашен?

--prvo filtriram sezonu i utakmice --380
--penalty goal/penalty miss ima uk 252

WITH utakmice_sa_penalima (
select 
m.match_id,
m.referee_id,
r.referee_name,
count(me.event_id) as broj_penala
from matches m
inner join referees r on r.referee_id = m.referee_id
inner join match_events me on me.match_id = m.match_id and me.event_type in ('penalty_goal', 'penalty_miss') --one sudije koje nisu dale penal su ispale sa innerom
where 1=1
and m.season = '2024/25'
group by
m.match_id,
m.referee_id,
r.referee_name
),

sve_utakmice as (
select 
m.match_id,
m.referee_id,
r.referee_name
from matches m
inner join referees r on r.referee_id = m.referee_id
where 1=1
and m.season = '2024/25'
),

--pazi 19 sudija u sezoni 2024/25
sve_sudije as (
select 
su.referee_id,
su.referee_name,
count(match_id) as uk_broj_utakmica_u_sezoni
from sve_utakmice su
group BY
su.referee_id,
su.referee_name)


select * from (
Select 
r.referee_id,
r.referee_name,
count(up.match_id) as broj_utakmica_sa_penalima,
ss.uk_broj_utakmica_u_sezoni,
100 * (count(up.match_id)/ss.uk_broj_utakmica_u_sezoni) as Udeo_utakmica_sa_penalima
from referees r
left join utakmice_sa_penalima up on up.referee_id = r.referee_id
left join sve_sudije ss on ss.referee_id = r.referee_id
WHERE 1=1
GROUP by
r.referee_id,
r.referee_name,
ss.uk_broj_utakmica_u_sezoni
)
order by Udeo_utakmica_sa_penalima DESC
limit 1;

--Opet Peter Lindgren je imao najivše udela utakmica sa penalima u sezoni 24/25 i to čak 45%

/*
--ukupno 212 utakmica je imalo penale
select 
me.match_id,
count(me.event_id) as broj_penala
from match_events me where me.event_type in ('penalty_goal', 'penalty_miss')
group by me.match_id
*/

--10. Који тренер је освојио највише бодова у 
--утакмицама у којима је његов тим губио на полувремену? da je imao 0 bodova na poluvremenu?
--Рачунајте и домаће и гостујуће утакмице.

with utakmice as (
select 
m.kickoff_ts,
m.match_id,
m.home_team_id as team_id,
case
when m.home_goals > m.away_goals then 3
when m.home_goals = m.away_goals then 1
when m.home_goals < m.away_goals then 0
end as broj_bodova_final,

case
when m.home_goals_ht > m.away_goals_ht then 3
when m.home_goals_ht = m.away_goals_ht then 1
when m.home_goals_ht < m.away_goals_ht then 0
end as broj_bodova_na_poluvremenu

from matches m

union 

select 
m.kickoff_ts,
m.match_id,
m.away_team_id as team_id,
case
when m.home_goals < m.away_goals then 3
when m.home_goals = m.away_goals then 1
when m.home_goals > m.away_goals then 0
end as broj_bodova_final,

case
when m.home_goals_ht > m.away_goals_ht then 3
when m.home_goals_ht = m.away_goals_ht then 1
when m.home_goals_ht < m.away_goals_ht then 0
end as broj_bodova_na_poluvremenu

from matches m
),

utakmice_sa_trenerima (

select 
u.*,
ms.manager_name as trener
from utakmice u
left join manager_spells ms on ms.team_id = u.team_id
where 1=1
--and u.match_id = 1001
and u.kickoff_ts > ms.start_date
and u.kickoff_ts < coalesce(ms.end_date,'9999-12-31')
)

select
ut.trener,
sum(broj_bodova_final) as ukupan_broj_bodova
from utakmice_sa_trenerima ut
where 1=1
and ut.broj_bodova_final = 3
and ut.broj_bodova_na_poluvremenu = 0

group by 
ut.trener
order by ukupan_broj_bodova desc
limit 1;

--najvise podova je osvojio trener Hans Flick i to čak 39

