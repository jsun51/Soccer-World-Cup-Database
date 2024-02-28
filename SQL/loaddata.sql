-- Include your INSERT SQL statements in this file.
-- Make sure to terminate each statement with a semicolon (;)

-- It is required to connect to your database.
CONNECT TO cs421;

INSERT INTO Groups(gname) VALUES
('Group A'),('Group B'),('Group C'),('Group D'),('Group E'),('Group F'),('Group G'), ('Group H'),
('Group I'),('Group J'),('Group K'),('Group L'),('Group M'),('Group N'),('Group O'),('Group P');

INSERT INTO Teams(country, status, goal_differential, web_URL, association_name, gname) VALUES
('Argentina', 'TBD', 2, 'https://www.afa.com.ar/es/', 'Argentine Football Association', 'Group A'),
('France', 'TBD', -3, 'https://www.franceA.com', 'France Association', 'Group A'),
('Germany', 'TBD', -1, 'https://www.germanyA.com', 'Germany Association', 'Group A'),
('Canada', 'TBD', 1, 'https://www.CanadaA.com', 'Canada Association', 'Group A'),
('Saudi Arabia', 'TBD', 1, 'https://www.saudiarabiaA.com', 'Saudi Arabia Association', 'Group B'),
('Cuba', 'TBD', 5, 'https://www.cubalibre.com', 'Cuba Super Soccer Association', 'Group B'),
('T7', 'TBD', 99, 'https://www.t7.com', 'T7 Association', 'Group C'),
('T8', 'TBD', 99, 'https://www.t8.com', 'T8 Association', 'Group D'),
('T9', 'TBD', 99, 'https://www.t9.com', 'T9 Association', 'Group E'),
('T10', 'TBD', 99, 'https://www.t10.com', 'T10 Association', 'Group F'),
('T11', 'TBD', 99, 'https://www.t11.com', 'T11 Association', 'Group G'),
('T12', 'TBD', 99, 'https://www.t12.com', 'T12 Association', 'Group H'),
('T13', 'TBD', 99, 'https://www.t13.com', 'T13 Association', 'Group I'),
('T14', 'TBD', 99, 'https://www.t14.com', 'T14 Association', 'Group J'),
('T15', 'TBD', 99, 'https://www.t15.com', 'T15 Association', 'Group K'),
('T16', 'TBD', 99, 'https://www.t16.com', 'T16 Association', 'Group L'),
('T17', 'TBD', 99, 'https://www.t17.com', 'T17 Association', 'Group M'),
('T18', 'TBD', 99, 'https://www.t18.com', 'T18 Association', 'Group N'),
('T19', 'TBD', 99, 'https://www.t19.com', 'T19 Association', 'Group O'),
('T20', 'TBD', 99, 'https://www.t20.com', 'T20 Association', 'Group P');


INSERT INTO Players(pid, pname, number, position, DOB, country) VALUES
    (1, 'Lionel Messi', 10, 'Forward', '1987-06-24', 'Argentina'),
    (2, 'Justin Sun', 24, 'Forward', '1998-12-03', 'Canada'),
    (3, 'Dominic Wener', 13, 'Center Midfield', '1999-04-21', 'Canada'),
    (4, 'Kylian Mbappé', 15, 'Forward', '1997-03-03', 'France'),
    (5, 'Alex Megos', 1, 'Forward', '1998-06-07', 'Germany'),
    (6, 'Peter Pan', 5, 'Center Midfield', '1991-09-29', 'Saudi Arabia')
;

INSERT INTO Referees(rid, name, country, experience) VALUES
(1, 'Fernando Rapallini', 'Argentina', 7),
(2, 'Chris Lang', 'France', 5),
(3, 'Roberto Lee', 'Germany', 6),
(4, 'Mitch Taylor', 'Canada', 1),
(5, 'Christian Wiebe', 'Saudi Arabia', 3)
;

INSERT INTO Grouped(country, gname, points) VALUES
    ('Argentina', 'Group A', 7),
    ('Canada', 'Group A', 3),
    ('Germany', 'Group A', 3),
    ('Saudi Arabia', 'Group E', 3),
    ('France', 'Group A', 3)
;



INSERT INTO Coaches(cid, cname, role, DOB, country) VALUES
    (1, 'Lionel Scaloni', 'Head', '1978-05-16', 'Argentina'),
    (2, 'Naruto Uzumaki', 'Assistant', '1974-04-17', 'Canada'),
    (3, 'Kakashi Hatake', 'Head', '1950-05-17', 'Germany'),
    (4, 'Jiraiya', 'Head', '1940-05-16', 'Saudi Arabia'),
    (5, 'Sasuke Uchiha', 'Assistant', '1974-10-16', 'France')
;


INSERT INTO Stadiums(sname, capacity, location) VALUES
    ('Estadio José María Minella', 35180, 'Av. de las Olimpiadas 760, Peralta Ramos Oeste, B7608DKP Mar del Plata, Provincia de Buenos Aires, Argentina'),
    ('BC Place', 54000, '123 Hastings St, BC'),
    ('Allianz Arena', 45093, '7829 German St, Germany'),
    ('King Fahd International Stadium', 37829, '782 Saudi Arabia St, Saudi Arabia'),
    ('Stade De France', 28291, '292 France St, France')

;

INSERT INTO Matches(mid, match_length, t1_score, t2_score, team1, team2, start_time, date, round, sname) VALUES
    (1, '090:00', 2, 1, 'Argentina', 'France', '15:00:00','2022-12-03','Group','Estadio José María Minella')
    ,(2, '090:00', 3, 1, 'Argentina', 'Germany', '18:00:00', '2022-11-25', 'Group', 'Allianz Arena')
    ,(3, '100:00', 3, 2, 'Saudi Arabia', 'Argentina', '09:00:00', '2022-10-15', 'Semi Final', 'King Fahd International Stadium')
    ,(4, '090:00', 1, 2, 'France', 'Germany', '08:00:00', '2022-10-20', 'Group', 'Stade De France')
    ,(5, '090:00', 2, 3, 'France', 'Canada', '08:00:00', '2022-11-10', 'Group', 'BC Place')
    ,(6, '095:00', 9, 9, 'Canada', 'Germany', '16:00:00','2023-02-10','Quarter Final','BC Place')
;

INSERT INTO Refereed(rid, mid, role) VALUES
(1, 1, 'Head'),
(2, 2, 'Head'),
(3, 2, 'Assistant'),
(5, 3, 'Head'),
(5, 4, 'Head'),
(2, 4, 'Assistant'),
(5, 5, 'Head'),
(4, 5, 'Assistant'),
(1, 6, 'Head')
;

INSERT INTO Played(pid, mid, y_cards, r_card, specfic_position, time_in, time_out) VALUES
    (1, 1, 2, 0, 'Forward', '15:30:00', '16:30:00'),
    (1, 2, 1, 1, 'Forward', '18:00:00', '19:45:00'),
    (1, 3, 1, 0, 'Forward', '09:00:00', '09:09:09'),
    (2, 5, 1, 0, 'Forward', '08:00:00', '08:30:00'),
    (3, 5, 0, 0, 'Center Midfield', '8:15:00', '9:00:00'),
    (4, 5, 0, 1, 'Forward', '8:00:00', '8:25:26'),
    (2, 6, 0, 0, 'Defense', '16:30:00', '17:35:00'),
    (3, 6, 2, 0, 'Forward', '16:30:00', '17:35:00'),
    (4, 6, 1, 1, 'Forward', '16:30:00', '17:35:00'),
    (5, 6, 1, 0, 'Forward', '16:30:00', '17:35:00');

INSERT INTO Goals(gid, pid, mid, penalty, occurence_order, scorer_name, time) VALUES
    (1, 1, 1, 0, 1, 'Lionel Messi', '15:45:00'),
    (2, 1, 2, 1, 2, 'Lionel Messi', '19:00:19'),
    (3, 2, 5, 1, 1, 'Justin Sun', '8:15:44'),
    (4, 3, 5, 0, 2, 'Dominic Wener', '08:45:56'),
    (5, 3, 5, 1, 3, 'Dominic Wener', '08:50:08')
;

INSERT INTO Seats(seatNumber, sname, sectionNumber) VALUES
    (25, 'Estadio José María Minella', 105),
    (25, 'BC Place', 105),
    (25, 'Stade De France', 105),
    (5, 'Estadio José María Minella', 124),
    (25, 'King Fahd International Stadium', 105),
    (26, 'Estadio José María Minella', 105)
;

INSERT INTO Clients(email, name, password) VALUES
    ('john.doe@gmail.com', 'John Doe', 'JD69'),
    ('jane.doe@gmail.com', 'Jane Doe', 'JaneD69'),
    ('js@gmail.com', 'Jason Sun', 'JS69'),
    ('d.w@gmail.com', 'Devin Wener', 'DW69'),
    ('cw@gmail.com', 'Christina Wiebe', 'CW69')
;

INSERT INTO Tickets(date, seatNumber, sname, mid, price, purchase_status) VALUES
    ('2022-12-03', 25, 'Estadio José María Minella', 1, 100.00, 0),
    ('2022-11-10', 25, 'BC Place', 5, 100.00, 0),
    ('2022-10-20', 25, 'Stade De France', 4, 100.00, 0),
    ('2022-12-03', 5, 'Estadio José María Minella', 1, 100.00, 0),
    ('2022-10-15', 25, 'King Fahd International Stadium', 3, 200.00, 0),
    ('2022-12-03', 26, 'Estadio José María Minella', 1, 100.00, 0)
;

INSERT INTO Buys(email, date, seatNumber, sname, mid) VALUES
    ('john.doe@gmail.com', '2022-12-03', 25, 'Estadio José María Minella', 1),
    ('jane.doe@gmail.com', '2022-12-03', 5, 'Estadio José María Minella', 1),
    ('js@gmail.com', '2022-11-10', 25, 'BC Place', 5),
    ('d.w@gmail.com', '2022-10-15', 25, 'King Fahd International Stadium', 3),
    ('cw@gmail.com', '2022-10-20', 25, 'Stade De France', 4),
    ('john.doe@gmail.com', '2022-12-03', 26, 'Estadio José María Minella', 1)
;

-- Constraint check

INSERT INTO Groups(gname) VALUES
    ('Group Z');
