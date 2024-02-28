# Soccer World Cup Database

## Introduction
This project is a relational database implemented in DB2 for World Cup Soccer games. The principle ideas of the tournaments are as follows. There are 32 teams. Matches (also referred to as games)
are played in rounds. The first round is called a group round. Each team is put into one of 8 groups (4 teams per
group), and each team plays against each other team in the group, i.e., 3 matches per team during the group round.
A match has a regular playing time of 90 minutes but typically there are a few extra minutes played to compensate
for pauses within the game due to injuries etc. A win brings 3 points, a loss brings 0 points, and a tie (same
number of goals at end of game) brings 1 point. Teams are ranked within their group according to the number
of points they have. If teams are tied in number of points, the team with the larger goal difference (total number
of goals scored in the three matches minus the total number of goals against them) will have the better position.
The best two teams of each group advance to the next round while the others are eliminated from the competition.
From there, a knockout phase has several further rounds: “round of 16”, “quarterfinals”, “semifinals”, “final / 3rd
place”. In the “round of 16”, each of the 16 qualifying teams of the previous round (two best of each group) plays
against one other team and the 8 winning teams advance to the next round while the loosing teams are out of the
competition. The same holds then for the quarterfinals (8 qualifying teams in 4 matches), leading to 4 qualifying
teams for the semifinals. In the semifinals, the winners of the two matches advance to the final to play for the
cup, and the losers play each other for 3rd place. In the context of this project, we are not interested in the rules
that decide who plays against whom in the round of 16, quarterfinals or semifinals. While matches in the group
round can be tied, all other matches must have a winner. Thus, if the scores are tied after the 90 minutes regular
time, there are 30 minutes extra time to play, called prolongation, and if the game is still tied after that, there
are penalty kicks. Each team has five penalty kicks and if they are still tied after that, the penalty shootout continues, with each team getting an extra penalty kick until tie breaks with the team that is first to have more goals.

## Entity-Relationship Model and Relational Translation
### Entity-Relationship Diagram
![ER](https://github.com/jsun51/Soccer-World-Cup-Database/blob/main/Images/ER.png)

### Relational Translation
Teams(<ins>country</ins>, status, goal_differential, web_URL, gname)  
  &emsp;web_URL foreign key referencing NationalAssociation  
  &emsp;web_URL NOT NULL  
  &emsp;gname foreign key referencing Groups  
  &emsp;gname NOT NULL  
  
Grouped(<ins>country</ins>, <ins>gname</ins>, points)  
  &emsp;country foreign key referencing Teams  
  &emsp;gname foreign key referencing Groups  

Groups(<ins>gname</ins>)
  
National Associations(<ins>web_URL</ins>, aname, country)  
  &emsp;country foreign key referencing Teams  
  &emsp;country NOT NULL  
  
Players(<ins>pid</ins>, pname, number, position, DOB, country)  
  &emsp;country foreign key referencing Teams  
  &emsp;country NOT NULL  
  
Coaches(<ins>cid</ins>, cname, DOB, role, country)  
  &emsp;country foreign key referencing Teams  
  &emsp;country NOT NULL  

Referees(<ins>rid</ins>, rname, country, experience)  

Stadiums(<ins>sname</ins>, capacity, location)  

Matches(<ins>mid</ins>, match_length, score, start_time, round, date, sname)  
  &emsp;sname foreign key referencing Stadiums  
  &emsp;sname NOT NULL  

Scheduled(<ins>country</ins>, <ins>mid</ins>)  
  &emsp;country foreign key referencing Teams   
  &emsp;mid foreign key referencing Matches  

Refereed(<ins>rid</ins>, <ins>mid</ins>, role)
  &emsp;rid foreign key referencing Referees  
  &emsp;mid foreign key referencing Matches  

Played(<ins>pid</ins>, <ins>mid</ins>, y_cards, r_card, specific_position, time_in, time_out)  
  &emsp;pid foreign key referencing Players  
  &emsp;mid foreign key referencing Matches  

Goals(<ins>gid</ins>, pid, mid, penalty, occurrence_order, scorer_name, time)  
  &emsp;pid foreign key referencing Players  
  &emsp;pid NOT NULL  
  &emsp;mid foreign key referencing Matches  
  &emsp;mid NOT NULL  

Seats(<ins>seatNumber</ins>, <ins>sname</ins>, sectionNumber)  
  &emsp;sname foreign key referencing Stadiums  
  &emsp;sname NOT NULL  

Clients(<ins>email</ins>, name, password)  

Tickets(<ins>date</ins>, <ins>seatNumber</ins>, <ins>sname</ins>, <ins>mid</ins>, price, purchase_status)  
  &emsp;seatNumber foreign key referencing Seat  
  &emsp;sname foreign key referencing Stadiums  
  &emsp;mid foreign key referencing Matches  

Buys(<ins>email</ins>, <ins>date</ins>, <ins>seatNumber</ins>, <ins>sname</ins>, <ins>mid</ins>)  
  &emsp;email foreign key referencing Client  
  &emsp;date foreign key referencing Tickets  
  &emsp;seatNumber foreign key referencing Seat  
  &emsp;sname foreign key referencing Stadiums  
  &emsp;mid foreign key referencing Matches  


## Database Creation 

### Create Tables
The tables created from the relational translation can be found here: [Create Table Script](SQL/create_table.sql).

Note that there are some key differences between the relational translation and the relations created in DB2:
  
**1.** ‘Scheduled’ relation expressing a participation constraint between ‘Teams’ and ‘Matches’ was
not implemented as its own relation table in the database, and was instead implemented as 2
attributes in the ‘Matches’ entities. They must be NOT NULL to ensure a Match doesn’t exist
without having 2 teams that will play in it (participation constraint).  

**2.** Score attribute in ‘Matches’ was implemented as separate t1_score and t2_score, as we now
have team1 and team2 attributes as defined above. The previously defined score attribute in the
Part1 relational schema would have needed to be a string because of our design, which would
not be useful in any types of queries. On the other hand, the new separate score attributes serve
the same purpose and can be queried appropriately, i.e. the score attribute didn’t store useful
data compared to the separate team1 score and team2 score attributes. However, most queries
can still use the ‘Goals’ relation to calculate scores of all matches, since the ‘Goals’ relation links
all goals to their scorer and respective match.

**3.** The National Association relation is represented within the Teams relation as name and URL
attributes, possible by the one-to-one constraint between them (i.e. no relation table created for
National Associations).

### Load Tables
The script used to load the tables with data can be found here: [Insert Data Script](SQL/load_data.sql).

The current data is just mock data used for testing our database and application. You can use it as a template for your own data.

### Queries
Helpful and interesting queries to run on the database can be found here: [Queries](SQL/queries.sql).

## Application
An application program witten in Java with a simple user-friendly interface can be found here: [Soccer Database Application](Application/Soccer.java).

## Contributors
 * *Dominic Weber*

