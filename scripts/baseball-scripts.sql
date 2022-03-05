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
	avg(so) avg_ko,
	avg(hr) avg_hr
from batting
group by decade
order by avg_ko desc;

-- Both strikouts per game and home runs per game have been increasing since 1920

/*6) Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/

select
	playerid,
	sb,
	cs,
	sum(sb+cs) as att_sb,
	sb / (sb+cs) as sb_succ_rate
from batting
where 
	yearid = '2016'
	and att_sb >= 20
group by playerid, sb, cs
order by sb_succ_rate desc;
