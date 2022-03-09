/*1) What range of years for baseball games played does the provided database cover?*/

select 
	min(yearid) as first_year,
	max(yearid) as recent_year
from appearances;

-- 1871-2016

/*2) Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?*/

select
	p.playerid,
	namegiven,
	t.name,
	sum(g_all) as total_games_played,
	min(height) as height
from
	people as p
join
	appearances as a
on p.playerid = a.playerid
join
	teams as t
on a.teamid = t.teamid
group by 
	p.playerid,
	namegiven,
	t.name
order by height;

-- Edward Carl; ht = 3' 7"; gp = 52; team = St. Louis Browns

/*3) Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?*/

select
	p.playerid,
	namefirst,
	namelast,
	schoolid,
	sum(salary) as total_salary
from people as p
join collegeplaying as c
on p.playerid = c.playerid
join salaries as s
on c.playerid = s.playerid
where
	schoolid = 'vandy'
group by
	p.playerid,
	namefirst,
	namelast,
	schoolid
order by
	total_salary desc;

-- David Price; $245,553,888

/*4) Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.*/

select
	case when pos like 'OF' then 'Outfield'
	when pos in ('SS','1B','2B','3B') then 'Infield'
	when pos in ('P','C') then 'Battery'
	end as pos_group,
	sum(po) as putouts
from fielding
where yearid = '2016'
group by pos_group;

-- Battery: 41424; Infield: 58934; Outfield: 29560

/*5) Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/

select
	case when yearid >= '1920' and yearid <= '1929' then '1920-1929'
	when yearid >= '1930' and yearid <= '1939' then '1930-1939'
	when yearid >= '1940' and yearid <= '1949' then '1940-1949'
	when yearid >= '1950' and yearid <= '1959' then '1950-1959'
	when yearid >= '1960' and yearid <= '1969' then '1960-1969'
	when yearid >= '1970' and yearid <= '1979' then '1970-1979'
	when yearid >= '1980' and yearid <= '1989' then '1980-1989'
	when yearid >= '1990' and yearid <= '1999' then '1990-1999'
	when yearid >= '2000' and yearid <= '2009' then '2000-2009'
	when yearid >= '2010' and yearid <= '2016' then '2010-2016'
	else null end as decade,
	round((sum(so)/sum(g)),2) as avg_so_game,
	round((sum(hr)/sum(g)),2) as avg_hr_game
from teams
group by decade, so, g
order by avg_so_game desc;

select *
from teams;

-- Both strikouts per game and home runs per game have been increasing since 1920

/*6) Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/

select
	p.namefirst,
	p.namelast,
	p.playerid,
	b.cs,
	sum(b.sb) as sb,
	sum(b.sb + b.cs) as att_sb,
	(sum(b.sb))/(nullif(sum(b.sb + b.cs),0))  as sb_succ_rate
from people as p 
join batting as b 
on p.playerid = b.playerid
where 
	yearid = '2016'
group by p.namefirst, p.namelast, p.playerid, b.sb, b.cs
order by b.sb desc;

--

/*7) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/

select
	t.yearid,
	t.teamid,
	t.franchid,
	tf.franchname as team_name,
	t.g,
	t.w,
	t.l,
	t.wswin
from teams as t
join teamsfranchises as tf
on t.franchid = tf.franchid
where yearid >= '1970' and yearid <= '2016' and t.wswin like 'N'
group by
	t.yearid,
	t.teamid,
	t.franchid,
	tf.franchname,
	t.g,
	t.w,
	t.l,
	t.wswin
order by t.w desc;

--116 wins in 2001 by the Seattle Mariners

select
	t.yearid,
	t.teamid,
	t.franchid,
	tf.franchname as team_name,
	t.g,
	t.w,
	t.l,
	t.wswin
from teams as t
join teamsfranchises as tf
on t.franchid = tf.franchid
where yearid >= '1970' and yearid <= '2016' and t.wswin like 'Y'
group by
	t.yearid,
	t.teamid,
	t.franchid,
	tf.franchname,
	t.g,
	t.w,
	t.l,
	t.wswin
order by t.w asc;

--63 wins by the Los Angeles Dodgers in 1981; this is because of a labor strike initiated by the players from June through July during the middle of the 1981 season.  When the strike ended, the league decided to split up the first and second halves of the season, since a little more than a third of that season's games had already been cancelled.

select
	t.yearid,
	t.teamid,
	t.franchid,
	tf.franchname as team_name,
	t.g,
	t.w,
	t.l,
	t.wswin
from teams as t
join teamsfranchises as tf
on t.franchid = tf.franchid
where yearid >= '1970' and yearid <= '2016' and yearid <> '1981' and t.wswin like 'Y'
group by
	t.yearid,
	t.teamid,
	t.franchid,
	tf.franchname,
	t.g,
	t.w,
	t.l,
	t.wswin
order by t.w asc;

--After excluding the 1981 season, 83 wins for the St. Louis Cardinals in 2006

select

--

/*8) Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

--Top 5
select
	h.team,
	f.franchname,
	h.park,
	p.park_name,
	h.games,
	h.attendance,
	round((h.attendance/h.games),2) as avg_attend_game
from homegames as h
inner join parks as p
on h.park = p.park
inner join teams as t
on h.team = t.teamid
inner join teamsfranchises as f
on t.franchid = f.franchid
where h.year = '2016' and h.games >= '10'
group by
	h.team,
	f.franchname,
	h.park,
	p.park_name,
	h.games,
	h.attendance
order by avg_attend_game desc
limit 5;

--Bottom 5
select
	h.team,
	f.franchname,
	h.park,
	p.park_name,
	h.games,
	h.attendance,
	round((h.attendance/h.games),2) as avg_attend_game
from homegames as h
inner join parks as p
on h.park = p.park
inner join teams as t
on h.team = t.teamid
inner join teamsfranchises as f
on t.franchid = f.franchid
where h.year = '2016' and h.games >= '10'
group by
	h.team,
	f.franchname,
	h.park,
	p.park_name,
	h.games,
	h.attendance
order by avg_attend_game asc
limit 5;

/*9) Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.*/

select
	am.playerid,
	p.namefirst,
	p.namelast,
	am.awardid,
	am.yearid,
	am.lgid
from awardsmanagers as am
inner join people as p
on am.playerid = p.playerid
where awardid like '%TSN%' and lgid not like '%M%'
group by
	am.playerid,
	p.namefirst,
	p.namelast,
	am.awardid,
	am.yearid,
	am.lgid;