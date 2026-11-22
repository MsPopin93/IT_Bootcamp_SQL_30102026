--modeliranje: zvezda za disciplinu
--sudija, klub, igrač i datum

--1) napravite i popunite tabele
--a) dim_team - svi klubovi iz team

 create or replace table dim_team AS
 select * from bootcamp.northern_star.teams;

select * from dim_team;

--b) dim_date - kalendar
  create or replace table dim_date as 
  select 
  cast(date_format(d, 'yyyyMMdd') as int) as date_key,
  d as full_date,
  date_format(d, 'EEEE') as weekday_name,
  dayofweek(d) in (1,7) as is_weekend,
  case 
  when month(d) >= 7 then concat(year(d), '/', substring(cast(year(d) + 1 as string), 3, 2))
  else concat(year(d)-1, '/', substring(cast(year(d) as string),3,2))
  end as season
  from (select explode(sequence(date'2023-07-01', date'2025-06-30', interval 1 day)) as d);

   select * from dim_date;

--c) dim_player - svi igrači iz players + nepoznati član sa player_id = -1

 create or replace table dim_player AS
 select * from bootcamp.northern_star.players
 union
 select -1, 'Nepoznato','Nepoznato','Nepoznato', null, 'Nepoznato', 'Nepoznato', 'Nepoznato', null;

  select * from dim_player;

  --d) dim_referees - sve sudije iz referees

 create or replace table dim_referee AS
 select * from bootcamp.northern_star.referees;

   select * from dim_referee;

    --e) fact_card - yellow_card, second_yellow, red_card iz match events
    --dogadjaji sa igračem koga nema u players dobijaju player_id = -1

 create or replace table fact_card AS
 select 
 me.event_id,
 me.match_id,
 cast(date_format(m.kickoff_ts, 'yyyyMMdd') as int) as date_key,
 me.team_id,

 case 
 when me.player_id = dp.player_id then me.player_id
 else -1
 end as player_id,

 m.referee_id,
 me.event_type as vrsta_kartona
 from bootcamp.northern_star.match_events me
 left join bootcamp.northern_star.matches m on m.match_id = me.match_id and  (m.home_team_id = me.team_id or m.away_team_id = me.team_id)
 left join dim_player dp on dp.player_id = me.player_id
  where me.event_type in ('yellow_card', 'second_yellow', 'red_card');

select * from fact_card;

--2. fact_card = broj_kartonskih dogadjaja

select 
count(*) as broj_redova,
count(me.event_id) as broj_kartonskih_dogadjaja,
broj_redova = broj_kartonskih_dogadjaja
 from fact_card
 cross join bootcamp.northern_star.match_events me where me.event_type in ('yellow_card', 'second_yellow', 'red_card');

 --3. koliko kartona ima player_id = -1

 select
 fc.player_id,
 count(fc.event_id) as broj_kartona
 from fact_card fc
 where fc.player_id = -1
 group by fc.player_id

 --ima 2 kartona

 --4. dopunjen README.md
 