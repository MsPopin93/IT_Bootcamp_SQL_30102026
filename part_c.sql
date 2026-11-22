--Deo C - prozorske funkcije

CREATE OR REPLACE VIEW bootcamp.northern_star.team_matches AS
WITH sides AS (
SELECT match_id, season, matchday, kickoff_ts,
home_team_id AS team_id, away_team_id AS opponent_id, 'home' AS
venue,
home_goals AS goals_for, away_goals AS goals_against
FROM bootcamp.northern_star.matches WHERE status = 'played'
UNION ALL
SELECT match_id, season, matchday, kickoff_ts,
away_team_id, home_team_id, 'away',
away_goals, home_goals
FROM bootcamp.northern_star.matches WHERE status = 'played'
)
SELECT *,
CASE WHEN goals_for > goals_against THEN 'W'
WHEN goals_for = goals_against THEN 'D' ELSE 'L' END AS result,
CASE WHEN goals_for > goals_against THEN 3
WHEN goals_for = goals_against THEN 1 ELSE 0 END AS points
FROM sides;

--1. Udeo u uk broju golova lige u sezoni 24/25 ima svaki klub?
--Najveći udeo ima - Kingsbridge City


SELECT DISTINCT
t.team_id,
t.team_name,
coalesce(sum(tm.goals_for) over (partition by t.team_id),0) as broj_golova_timova,
sum(tm.goals_for) over () as broj_golova_lige,
round(100 * broj_golova_timova / broj_golova_lige,2) as pct
FROM teams t
left join team_matches tm on t.team_id = tm.team_id and tm.season = '2024/25'
order by pct desc;

--2. 3 stadiona sa najvecom prosecnom posetom u sezoni 24/25

SELECT DISTINCT
m.stadium_id,
s.stadium_name,
round(avg(m.attendance),2) as prosecna_poseta,
row_number() over (order by avg(m.attendance) desc ) as rn
FROM matches m 
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id

WHERE m.season = '2024/25'
group by 
m.stadium_id,
s.stadium_name
qualify rn <= 3
order by prosecna_poseta DESC;


 --3. Za svaki klub: Ko je dao poslednji gol kluba u sezoni 24/25 i kada?
 --Koji je klub poslendji god dao najranije

--a
WITH LAST_GOAL AS (
 SELECT 
tm.kickoff_ts,
me.match_id,
me.team_id,
me.player_id,
p.first_name,
p.last_name,
me.minute,
row_number() over (
    partition by me.team_id
    order by tm.kickoff_ts desc, me.minute desc
) as poslednji_gol
from match_events me
INNER join team_matches tm ON tm.match_id = me.match_id and tm.team_id = me.team_id and tm.season = '2024/25'
INNER join players p on p.player_id = me.player_id
where 1=1
--and me.team_id = 1
and me.event_type in ('goal', 'penalty_goal')

Qualify poslednji_gol = 1

order by tm.kickoff_ts desc, me.minute desc
)

--deo b - poslednji gol najranije
SELECT
lg.kickoff_ts,
lg.match_id,
lg.team_id,
t.team_name,
lg.player_id,
lg.first_name,
lg.last_name,
lg.minute,
row_number() over (
    order by lg.kickoff_ts asc, lg.minute asc
) as poslednji_gol_najranije
 FROM last_goal lg
 left join teams t on t.team_id = lg.team_id
 QUALIFY poslednji_gol_najranije = 1;

 --POslednji gol je najranije dao tim 8 - Elmsworth Wanderers i njegov igrač Makro Stanković

 --4. Domaće utakmice kluba Northport United u sezoni 24/25 prikazite posetu i promenu u odnosu na posetu
 --Najveći pad

 SELECT 
 m.match_id,
 m.kickoff_ts,
 m.attendance,
 lag(m.attendance) over(partition by m.home_team_id order by kickoff_ts) as prev_attendance,
(m.attendance - prev_attendance) as diff
 FROM matches m
 WHERE 1=1
 and m.season = '2024/25'
 and m.home_team_id in (Select team_id from teams where team_name = 'Northport United')
 QUALIFY prev_attendance is not null
 order by diff asc
 limit 1;
--Najveći pad i promena u odnosu na prošlu posetu je kod utakmice 2110 i to sa cca 49.000 na 39.000

--5. Bodovi kluba Northport City u sezoni 24/25, utakmicu po utakmicu
 --U kojoj utakmici po redu i kog datuma je prešao 50 bodova


    SELECT
    season,
    team_id,
    match_id,
    kickoff_ts,
    row_number() over w AS games_played,
    sum(points) over w as pts_so_far
    from team_matches
    WHERE team_id in (Select team_id from teams where team_name = 'Northport City')
    AND season = '2024/25'
    WINDOW w AS (
        PARTITION BY season, team_id
        ORDER BY kickoff_ts, match_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
    QUALIFY pts_so_far > 50
    ORDER BY kickoff_ts, match_id
    limit 1;
    --Northport City je prešao 50 bodova u 21. utakmici po redu i to 12-01-2025
