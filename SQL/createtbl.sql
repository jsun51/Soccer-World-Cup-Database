
-- It is required to connect to your database.
CONNECT TO cs421;

-- Remember to put the create table ddls for the tables with foreign key references
--    ONLY AFTER the parent tables has already been created.

/*          CREATE TABLE NationalAssociation
National Associations are one-to-one with Teams table, so its unique attributes are added to the teams table
Otherwise, creating tables for each of 'National Association' and 'Teams' causes issues during the creation because
they are dependent on each other already existing in the database. Thus, they are combined into one large table.
*/
CREATE TABLE Groups
(
    gname CHAR(7) NOT NULL,
    PRIMARY KEY (gname),
    CONSTRAINT CHK_gName CHECK (gname='Group A' OR gname='Group B' OR gname='Group C' OR gname='Group D' OR gname='Group E' OR
                                gname='Group F' OR gname='Group G' OR gname='Group H' OR gname='Group I' OR gname='Group J' OR
                                gname='Group K' OR gname='Group L' OR gname='Group M' OR gname='Group N' OR gname='Group O' OR
                                gname='Group P')
);

CREATE TABLE Teams
(
    country VARCHAR(56) NOT NULL,
    status VARCHAR(100),
    goal_differential INTEGER,
    web_URL VARCHAR(100) NOT NULL,
    association_name VARCHAR(100) NOT NULL,
    gname CHAR(7) NOT NULL,
    PRIMARY KEY(country),
    FOREIGN KEY(gname) references Groups(gname)
);

CREATE TABLE Players
(
    pid INTEGER NOT NULL,
    pname VARCHAR(100),
    number INTEGER,
    position VARCHAR(25),
    DOB DATE,
    country VARCHAR(56) NOT NULL,
    PRIMARY KEY (pid),
    FOREIGN KEY (country) REFERENCES Teams(country)
);

CREATE TABLE Referees
(
    rid INTEGER NOT NULL ,
    name VARCHAR(100),
    country VARCHAR(56),
    experience INTEGER,
    PRIMARY KEY (rid)
);

CREATE TABLE Grouped
(
    country VARCHAR(56) NOT NULL,
    gname CHAR(7) NOT NULL,
    points INTEGER,
    PRIMARY KEY (country,gname),
    FOREIGN KEY (country) references Teams(country),
    FOREIGN KEY (gname) references Groups(gname)
);

CREATE TABLE Coaches
(
    cid INTEGER NOT NULL,
    cname VARCHAR(100),
    role VARCHAR(25),
    DOB DATE,
    country VARCHAR(56) NOT NULL,
    PRIMARY KEY (cid),
    FOREIGN KEY (country) REFERENCES Teams(country)
);

CREATE TABLE Stadiums
(
    sname VARCHAR(100) NOT NULL,
    capacity INTEGER,
    location VARCHAR(200),
    PRIMARY KEY (sname)
);

-- Participation constraint captured by adding team1 and team2 as attributes to the Matches entity set, such that
-- they have to be not null (i.e. a Match cannot exist without having 2 teams that will play in it).
-- Otherwise, the participation constraint would not be possible to enforce using a table for the "Scheduled"
-- relation, as a Match and a Team would need to exist before we can create a scheduled entry => A match would
-- exist without having assigned teams. Also, more than 2 scheduled entries could exist for the same mid, which
-- cannot be allowed.
 CREATE TABLE Matches
(
    mid INTEGER NOT NULL,
    match_length  CHAR(6),
    t1_score INTEGER,
    t2_score INTEGER,
    team1 VARCHAR(56) NOT NULL,
    team2 VARCHAR(56) NOT NULL,
    start_time TIME,
    date DATE,
    round VARCHAR(20),
    sname VARCHAR(100),
    PRIMARY KEY (mid),
    FOREIGN KEY (team1) REFERENCES Teams(country),
    FOREIGN KEY (team2) REFERENCES Teams(country),
    FOREIGN KEY (sname) REFERENCES Stadiums(sname)
);

/*CREATE TABLE Scheduled
(
    country NOT NULL,
    mid NOT NULL,
    PRIMARY KEY (country, mid),
    FOREIGN KEY (country) REFERENCES Teams(country),
    FOREIGN KEY (mid) REFERENCES Matches(mid)
);*/

CREATE TABLE Refereed
(
    rid INTEGER NOT NULL,
    mid INTEGER NOT NULL,
    role VARCHAR(25),
    PRIMARY KEY (rid, mid),
    FOREIGN KEY (rid) REFERENCES Referees(rid),
    FOREIGN KEY (mid) REFERENCES Matches(mid)
);

CREATE TABLE Played
(
    pid INTEGER NOT NULL ,
    mid INTEGER NOT NULL,
    y_cards INTEGER,
    r_card INTEGER,
    specfic_position VARCHAR(25),
    time_in TIME,
    time_out TIME,
    PRIMARY KEY (pid,mid),
    FOREIGN KEY (pid) REFERENCES Players(pid),
    FOREIGN KEY (mid) REFERENCES Matches(mid)
);

CREATE TABLE Goals
(
    gid INTEGER NOT NULL,
    pid INTEGER NOT NULL,
    mid INTEGER NOT NULL ,
    penalty INTEGER,
    occurence_order INTEGER,
    scorer_name VARCHAR(100),
    time TIME,
    PRIMARY KEY (gid),
    FOREIGN KEY (pid) REFERENCES Players(pid),
    FOREIGN KEY (mid) REFERENCES Matches(mid)
);

CREATE TABLE Seats
(
    seatNumber INTEGER NOT NULL,
    sname VARCHAR(100) NOT NULL,
    sectionNumber INTEGER,
    PRIMARY KEY (seatNumber, sname),
    FOREIGN KEY (sname) REFERENCES Stadiums(sname)
);

CREATE TABLE Clients
(
    email VARCHAR(100) NOT NULL,
    name VARCHAR(100),
    password VARCHAR(100),
    PRIMARY KEY (email)
);

CREATE TABLE Tickets
(
    date DATE NOT NULL,
    seatNumber INTEGER NOT NULL,
    sname VARCHAR(100) NOT NULL,
    mid INTEGER NOT NULL,
    price FLOAT,
    purchase_status INTEGER,
    PRIMARY KEY (date, seatNumber, sname, mid),
    FOREIGN KEY (seatNumber, sname) REFERENCES Seats(seatNumber, sname),
    FOREIGN KEY (mid) REFERENCES Matches(mid)
);

CREATE TABLE Buys
(
    email VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    seatNumber INTEGER NOT NULL,
    sname VARCHAR(100) NOT NULL,
    mid INTEGER NOT NULL,
    PRIMARY KEY (email, date, seatNumber, sname, mid),
    FOREIGN KEY (email) REFERENCES Clients(email),
    FOREIGN KEY (date, seatNumber, sname, mid) REFERENCES Tickets(date, seatNumber, sname, mid)
);

CREATE VIEW playerinfo(name, ShirtNumber, DOB, country, NationalAssociation, group)
AS SELECT p.pname, p.number, p.DOB, p.country, t.association_name, t.gname
   FROM Players p, Teams t
   WHERE p.country = t.country
;
--FOR THE VIEW
--C
SELECT * FROM playerinfo
LIMIT 5
;
--D
SELECT * FROM playerinfo
WHERE group = 'Group A'
Limit 5
;
--E
INSERT INTO playerinfo VALUES ('John Doe', 20, '1990-12-09', 'Canada', 'CA', 'Group B');

