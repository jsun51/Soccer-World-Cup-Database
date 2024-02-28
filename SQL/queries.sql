/* Lists all the stadium names and their locations and the match date of matches in which player 
Lionel Messi has played and scored at least one goal */
SELECT s.sname, s.location, temp.date
FROM Stadiums s, (SELECT m.sname, m.date
                  FROM Matches m
                  WHERE mid IN (SELECT g.mid
                                FROM Goals g
                                WHERE g.scorer_name = 'Lionel Messi'
                  )
)temp
WHERE s.sname = temp.sname
;


/* Lists the name, shirt number and country of all players that have played in all matches of their teams */
SELECT final.pname, final.number, final.Team, final.nummatches
FROM (SELECT p.pid, p.pname, p.number, temp2.Team, temp2.nummatches
      FROM Players p, (SELECT temp1.Team, count(*) AS nummatches
                       FROM (SELECT m1.mid, m1.team1 AS Team
                             FROM Matches m1
                             UNION
                             SELECT m2.mid, m2.team2 AS Team
                             FROM Matches m2
                            )temp1
                       GROUP BY temp1.Team
      )temp2
      WHERE p.country = temp2.Team
     )final, (SELECT pid, count(*) AS numgamesplayed
              FROM Played
              GROUP BY pid
     )temp3
WHERE final.pid =temp3.pid and final.nummatches = temp3.numgamesplayed
;

/* Lists for each team, the country, the number of matches they have played and the total number
of goals they have scored during normal play */
SELECT final1.country AS Team, final1.nummatches, final2.numgoals
FROM (SELECT t.country, COALESCE(nummatches, 0) AS nummatches
      FROM Teams t LEFT OUTER JOIN (SELECT temp1.Team, count(*) AS nummatches
                                    FROM (SELECT m1.mid, m1.team1 AS Team
                                          FROM Matches m1
                                          UNION
                                          SELECT m2.mid, m2.team2 AS Team
                                          FROM Matches m2
                                         )temp1
                                    GROUP BY temp1.Team
      )temp2
                                   ON t.country = temp2.Team
     )final1, (SELECT p.country, count(*) AS numgoals
               FROM Goals g, Players p
               WHERE g.penalty = 0 AND g.pid = p.pid
               GROUP BY p.country
     )final2
WHERE final1.country = final2.country
ORDER BY Team
;

/* This query returns the email and the total amount of money spent by theclients that have spent the most money when buying 
tickets across all the games in thetournaments.*/
SELECT temp1.email, temp2.MostSpent
FROM
    (SELECT b.email,SUM(t.price) AS TotalSpent
     FROM Buys b,
          Tickets t
     WHERE b.date = t.date
       AND b.seatNumber = t.seatNumber
       AND b.sname = t.sname
       AND b.mid = t.mid
       AND t.purchase_status = 0
     GROUP BY b.email
    )temp1,
    (SELECT MAX(prices.TotalSpent) AS MostSpent
     FROM (SELECT b.email, SUM(t.price) AS TotalSpent
           FROM Buys b,
                Tickets t
           WHERE b.date = t.date
             AND b.seatNumber = t.seatNumber
             AND b.sname = t.sname
             AND b.mid = t.mid
             AND t.purchase_status = 0
           GROUP BY b.email
          )prices
    )temp2
WHERE temp1.TotalSpent = temp2.MostSpent
;

/* This query returns information about the head referee for every unique game
played in the tournament, as well as sanctions given to the players in that match. In other words,
for every match in the database, this query returns the head referee name, their country, the 2
teams (country names) that played in the match, the match date and the total amount of yellow
cards and red cards given to the players during this match.*/
SELECT final2.name AS Referee, final2.refcountry, COALESCE(final1.numyellowcards, 0) AS match_yellowcards,
       COALESCE(final1.numredcards, 0) AS match_redcards, final2.date, final2.team1 AS Match_Team1, final2.team2 AS Match_Team2
FROM (SELECT DISTINCT temp1.mid, temp1.numyellowcards, temp2.numredcards
      FROM (SELECT mid, sum(y_cards) AS numyellowcards
            FROM Played
            WHERE y_cards > 0
            GROUP BY mid
           )temp1, (SELECT mid, count(*) AS numredcards
                    FROM Played
                    WHERE r_card = 1
                    GROUP BY mid
           )temp2
     )final1 RIGHT OUTER JOIN (SELECT rs.name, rs.country AS refcountry, rd.role, rd.mid, m.date, m.team1, m.team2
                               FROM Referees rs, Refereed rd, Matches m
                               WHERE rs.rid = rd.rid AND rd.mid = m.mid AND role = 'Head'
)final2
                              ON final1.mid = final2.mid
ORDER BY final2.name
;




