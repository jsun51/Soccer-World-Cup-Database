import java.sql.* ;
import java.text.ParseException;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Scanner;
import java.util.Calendar;

public class Soccer {
    ////////////////////////////////////////////////////////////
    //We assume the string literal "unknown" is the placeholder for Matches that have undecided participating countries

    public static void main ( String [ ] args ) throws SQLException, NumberFormatException {

        // Register the driver.  You must register the driver before you can use it.
        try {
            DriverManager.registerDriver(new com.ibm.db2.jcc.DB2Driver());
        } catch (Exception cnfe) {
            System.out.println("Class not found");
        }

        // This is the url you must use for DB2.
        String url = "jdbc:db2://winter2023-comp421.cs.mcgill.ca:50000/cs421";

        ////////////////////////////////////////////////////////////////////////////////
        //REMEMBER to remove your user id and password before submitting your code!!
        String your_userid = null;
        String your_password = null;
        ////////////////////////////////////////////////////////////////////////////////

        if (your_userid == null && (your_userid = System.getenv("SOCSUSER")) == null) {
            System.err.println("Error!! do not have a user to connect to the database!");
            System.exit(1);
        }
        if (your_password == null && (your_password = System.getenv("SOCSPASSWD")) == null) {
            System.err.println("Error!! do not have a password to connect to the database!");
            System.exit(1);
        }
        Connection con = DriverManager.getConnection(url, your_userid, your_password);

        //Infinite while loop for program execution
        while(true) {
            printMainMenu();

            Scanner input  = new Scanner(System.in);
            int option = 0;
            try {
                option = Integer.parseInt(input.nextLine());
            }catch(NumberFormatException e){
                System.out.println("Error: Invalid Menu Input...");
                continue;
            }

            if (option == 1) {
                showMatchesOfCountry(con);
            } else if (option == 2) {
                insertPlayerInfo(con);
            } else if (option == 3) {
                clientTicketsMenu(con);
            } else if (option == 4) {
                System.out.println("Exit Application");
                con.close();
                break;
            } else {
                System.out.println("Error: Invalid Menu Input...");
            }

        }
    }

    public static void printMainMenu() {
        System.out.println("\nSoccer Main Menu");
        System.out.println("\t1. List information of matches of a country");
        System.out.println("\t2. Insert initial player information for a match");
        System.out.println("\t3. View and modify a client ticket portfolio");
        System.out.println("\t4. Exit Application");
        System.out.print("Please Enter Your Option:");
    }

    public static void showMatchesOfCountry(Connection con) throws SQLException{
        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd-MMM-yyyy");

        Scanner input = new Scanner(System.in);
        String country = "";

        while (true) {
            Date dateNow = new Date();
            Time timeNow = Time.valueOf(LocalTime.now());

            System.out.println("\nEnter a country for which the matches will be shown: ");
            country = input.nextLine();

            try
            {
                String querySQL = "SELECT m.team1, m.team2, m.date,m.start_time, m.round, COALESCE(m.t1_score, -1) AS t1_score," +
                        " COALESCE(m.t2_score, -1) AS t2_score, COALESCE(temp.soldTickets, 0) AS soldTickets" +
                        " FROM Matches m LEFT OUTER JOIN (SELECT b.mid, count(*) AS soldTickets" +
                        " FROM Buys b GROUP BY mid)temp ON temp.mid = m.mid" +
                        " WHERE m.team1 = \'" + country + "\' OR m.team2 = \'" + country + "\'";

                Statement statement = con.createStatement();
                java.sql.ResultSet rs = statement.executeQuery(querySQL);

                String score1;
                String score2;

                while (rs.next()) {
                    String country1 = rs.getString("team1");
                    String country2 = rs.getString("team2");
                    Date dateMatch = rs.getDate("date");
                    Time timeMatch = rs.getTime("start_time");
                    String round = rs.getString("round");

                    if (dateNow.compareTo(dateMatch) < 0 || (dateNow.compareTo(dateMatch) == 0 && timeNow.compareTo(timeMatch) < 0)) {
                        // dateNow is smaller than dateMatch i.e. Match has not occurred
                        score1 = "N/A";
                        score2 = "N/A";
                    } else {    // Match has either just started, is ongoing or has finished.
                        /*  We assume match tuples are updated in real-time while a match is being played. Thus, if
                        the query is made during the match, we can assume that the score attributes will be not NULL
                        (i.e. t1_score and t2_score will contain an integer value of 0 or larger). */
                        score1 = "" + rs.getInt("t1_score");
                        score2 = "" + rs.getInt("t2_score");
                    }
                    int tickets = rs.getInt("soldTickets");
                    String date = dateFormatter.format(dateMatch);

                    System.out.printf("%-15s %-15s %-15s %-17s %-3s %-5s %s\n", country1, country2, date, round, score1, score2, tickets);
                }
                statement.close();
            } catch (SQLException e) {
                int sqlCode = e.getErrorCode(); // Get SQLCODE
                String sqlState = e.getSQLState(); // Get SQLSTATE

                System.out.println("Code: " + sqlCode + "  sqlState: " + sqlState);
                System.out.println(e);
            }

            System.out.println("\nEnter [A/a] to find matches of another country, [P/p] to go to the previous menu:");
            String option = input.nextLine();

            if (option.equals("P") || option.equals("p")) {
                break;
            } else if (option.equals("A") || option.equals("a")) {
                continue;
            } else {
                System.out.println("Error: Invalid Menu Input...");
                break;
            }
        }
    }

    public static void insertPlayerInfo(Connection con) throws SQLException{
        while(true) {
            printUpcomingMatches(con);

            Scanner in = new Scanner(System.in);
            String matchID;
            String country;
            System.out.println("Enter a match identifier from the list above or press [P] to return to the previous menu: ");
            matchID = in.nextLine();
            if (matchID.equals("P") || matchID.equals("p")) {
                return;
            }
            System.out.println("Enter a country from the selected match or press [P] to return to the previous menu: ");
            country = in.nextLine();
            if (country.equals("P") || country.equals("p")) {
                return;
            }

            //main logic of actually inserting players
            while (true) {
                int numRows = printPlayers(matchID, country, con);

                try {
                    String querySQL = "SELECT pid, pname, number, position" +
                            " FROM Players" +
                            " WHERE country = " + "\'" + country + "\'" + " AND pid NOT IN (SELECT pid" +
                            " FROM Played WHERE mid = " + matchID + ")";

                    Statement statement = con.createStatement();
                    java.sql.ResultSet rs = statement.executeQuery(querySQL);

                    int[] pids = new int[200];
                    String[] pnames = new String[200];
                    int[] numbers = new int[200];
                    int counter = 0;

                    System.out.println("Possible players from " + country + " not yet selected:\n");
                    while (rs.next()) {
                        counter++;
                        pids[counter] = rs.getInt("pid");
                        pnames[counter] = rs.getString("pname");
                        numbers[counter] = rs.getInt("number");
                        String position = rs.getString("position");

                        //print out players that are not yet playing in the game
                        System.out.println(counter + ". " + pnames[counter] + " " + numbers[counter] + " " + position);
                    }
                    System.out.print("\n");
                    System.out.println("Enter the number of the player you want to insert or [P] to go to the previous menu.");
                    String player_option = in.nextLine();
                    String spec_pos;
                    if (player_option.equals("P") || player_option.equals("p")) {
                        break;
                    } else {
                        System.out.println("Enter the specific position the player is playing in the match.");
                        spec_pos = in.nextLine();

                        int p_option = Integer.parseInt(player_option);
                        statement.close();

                        if(numRows < 11) {
                            Statement statement2 = con.createStatement();
                            statement2.executeUpdate("INSERT INTO Played " +
                                    "VALUES (" + pids[p_option] + ", " + matchID + ", 0, 0, " + "\'" + spec_pos + "\'" + ", " + "'00:00:00', null)");
                            statement2.close();
                        }
                        else{
                            System.out.println("Maximum number of players for " + country + " in match " + matchID + " has been reached. Your player has not been inserted.");
                            break;
                        }

                    }
                } catch (SQLException e) {
                    int sqlCode = e.getErrorCode(); // Get SQLCODE
                    String sqlState = e.getSQLState(); // Get SQLSTATE

                    // Your code to handle errors comes here;
                    // something more meaningful than a print would be good
                    return;
                }
            }
        }
    }

    public static void clientTicketsMenu(Connection con) throws NumberFormatException, SQLException {

        System.out.println("Enter email: ");

        Scanner in = new Scanner(System.in);
        String email = in.nextLine();
        // Menu loop to display specific client portfolio
        while (true) {

            System.out.println("\nTicket Portfolio Manager: \'" + email + "\'");
            System.out.println("\t1. View owned tickets");
            System.out.println("\t2. Buy new tickets");
            System.out.println("\t3. Return to previous Menu");
            System.out.print("Please Enter Your Option:");

            Scanner input = new Scanner(System.in);

            int option = 0;
            try {
                option = Integer.parseInt(input.nextLine());
            } catch (NumberFormatException n) {
                System.out.println("Error: Invalid Menu Input...");
                continue;
            }

            if (option == 1) {
                printTickets(con, email);
            } else if (option == 2) {
                buyTickets(con, email);
            } else if (option == 3) {
                break;
            } else {
                System.out.println("Error: Invalid Menu Input...");
            }
        }
    }

    public static void buyTickets(Connection con, String email) throws SQLException{
        SimpleDateFormat printFormatter = new SimpleDateFormat("dd-MMM-yyyy");
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        while (true) {
            System.out.println("\n-------------------All upcoming matches------------------");
            int midArr[] = new int[65];
            String teamArr[] = new String[65];
            Date dateArr[] = new Date[65];
            String startArr[] = new String[65];
            String roundArr[] = new String[65];
            String stadiumArr[] = new String[65];
            int counter = 0;

            try
            {
                String dateNow = dateFormatter.format(new Date());

                String querySQL = "SELECT mid, team1, team2, date, start_time, round, sname FROM Matches" +
                        " WHERE date >= \'" + dateNow + "\' ORDER BY date";

                Statement statement = con.createStatement();
                java.sql.ResultSet rs = statement.executeQuery ( querySQL );

                while ( rs.next ( ) ) {
                    counter++;
                    midArr[counter] = rs.getInt("mid");
                    String teams = rs.getString("team1") + "  @  " + rs.getString("team2");
                    String timeMatch = rs.getTime("start_time").toString();
                    Date dateMatch = rs.getDate("date");
                    String round = rs.getString("round");
                    String stadium = rs.getString("sname");

                    System.out.printf(counter + ". %-25s %-13s %-10s %s\n", teams, printFormatter.format(dateMatch), timeMatch, round);

                    teamArr[counter] = teams;
                    dateArr[counter] = dateMatch;
                    startArr[counter] = timeMatch;
                    roundArr[counter] = round;
                    stadiumArr[counter] = stadium;
                }
                statement.close();
            }
            catch (SQLException e)
            {
                int sqlCode = e.getErrorCode(); // Get SQLCODE
                String sqlState = e.getSQLState(); // Get SQLSTATE

                // something more meaningful than a print would be good
                System.out.println("Code: " + sqlCode + "  sqlState: " + sqlState);
                System.out.println(e);
            }

            System.out.println("Select one of the upcoming matches by entering the line number or press [P/p] to return to the previous Menu:");
            Scanner input = new Scanner(System.in);
            String option = input.nextLine();

            if(option.equals("P") || option.equals("p")) {
                break;
            } else {
                int index = Integer.parseInt(option);
                int matchID = midArr[index];
                while (true) {
                    System.out.println("--------------------------------All available tickets for the selected match-------------------------------");
                    System.out.println("| Teams: " + teamArr[index] + " | Date: " + printFormatter.format(dateArr[index]) + " | Start Time: " + startArr[index] + " | Match Round: " + roundArr[index] + " | Stadium: " + stadiumArr[index] + " |");

                    printMatchAvailableTickets(con, matchID);

                    System.out.println("Enter the seat number of the ticket to purchase or press [P/p] to return to the previous Menu:");
                    option = input.nextLine();

                    if(option.equals("P") || option.equals("p")) {
                        break;
                    } else {
                        int seatNum = Integer.parseInt(option);
                        processTicketPurchase(con, email, matchID, seatNum, dateFormatter.format(dateArr[index]), stadiumArr[index]);
                    }
                }
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////Helper Methods for all Menu functions///////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static void printUpcomingMatches(Connection con) throws SQLException{
        //Printing all matches between now and 3 days from now
        try
        {
            Date currentDate = new Date();
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");

            Calendar cal = Calendar.getInstance();
            cal.setTime(currentDate);

            cal.add(Calendar.DAY_OF_MONTH, 3);
            String threeDaysLater = formatter.format(cal.getTime());
            String today = formatter.format(currentDate);

            String querySQL = "SELECT mid, team1, team2, date, round FROM Matches" +
                    " WHERE date >= " + "\'" + today + "\'" + " AND date <= " + "\'" + threeDaysLater + "\'" +
                    " AND NOT team1 = 'unknown' AND NOT team2 = 'unknown'";

            Statement statement = con.createStatement();
            java.sql.ResultSet rs = statement.executeQuery ( querySQL );

            while ( rs.next ( ) ) {
                int mid = rs.getInt("mid");
                String team1 = rs.getString("team1");
                String team2 = rs.getString("team2");
                Date date = rs.getDate("date");
                String round = rs.getString("round");
                String matchDate = formatter.format(date);

                //print out mid, team1, team2, date, round
                System.out.println("\t" + mid + " " + team1 + " " + team2 + " " + matchDate + " " + round);
            }
            statement.close();
        }
        catch (SQLException e)
        {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE

            // Your code to handle errors comes here;
            // something more meaningful than a print would be good
            System.out.println("Code: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println(e);
        }
    }

    //To print the players associated with the match that the user chose; print players in the match and not yet in the match
    public static int printPlayers(String matchID, String country, Connection con) throws SQLException{
        try
        {
            String querySQL = "SELECT p2.pname, p2.number, p.specific_position, p.time_in, p.time_out, p.y_cards, p.r_card" +
                    " FROM Played p, Players p2" +
                    " WHERE p.pid = p2.pid AND p.mid = " + matchID + " AND p2.country = " + "\'" + country + "\'";


            Statement statement = con.createStatement();
            java.sql.ResultSet rs = statement.executeQuery ( querySQL );

            System.out.println("The following players from " + country + " are already entered for match " + matchID + ":\n");
            while ( rs.next ( ) ) {
                String pname = rs.getString("pname");
                int number = rs.getInt("number");
                String spec_pos = rs.getString("specific_position");
                Time time_in = rs.getTime("time_in");
                Time time_out = rs.getTime("time_out");
                int y_cards = rs.getInt("y_cards");
                int r_card = rs.getInt("r_card");

                //print out players that are still
                System.out.println(pname + " " + number + " " + spec_pos + " from time " + time_in + " to time " + time_out + " yellow: " + y_cards + " red: " + r_card);
            }
            System.out.print("\n");

            String querySQL2 = "SELECT COUNT(*) AS numRows FROM " +
                    "(SELECT p2.pname, p2.number, p.specific_position, p.time_in, p.time_out, p.y_cards, p.r_card" +
                    " FROM Played p, Players p2" +
                    " WHERE p.pid = p2.pid AND p.mid = " + matchID + " AND p2.country = " + "\'" + country + "\'" + ")";


            Statement statement2 = con.createStatement();
            java.sql.ResultSet rs2 = statement2.executeQuery ( querySQL2 );
            int numRows = 0;

            while(rs2.next()){
                numRows = rs2.getInt("numRows");
            }
            statement.close();
            statement2.close();
            return numRows;
        }
        catch (SQLException e)
        {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE

            // Your code to handle errors comes here;
            // something more meaningful than a print would be good
            System.out.println(e);
            System.out.println("Please enter valid inputs from the list below.");
            insertPlayerInfo(con);
        }
        return 11;
    }

    public static void printTickets(Connection con, String email) throws SQLException{
        System.out.println("\n------------All tickets owned by user \'" + email + "\'---------------");
        try
        {
            String querySQL = "SELECT m.team1, m.team2, m.round, m.start_time, temp.date, temp.seatnumber, temp.sname, temp.price" +
                    " FROM Matches m, (SELECT t.mid, t.date, t.seatnumber, t.sname, t.price" +
                    " FROM Tickets t, Buys b WHERE t.mid = b.mid AND t.seatnumber = b.seatnumber\n" +
                    " AND b.email = \'" + email +"\'" +
                    " ORDER BY t.date)temp\n" +
                    " WHERE m.mid = temp.mid;";

            Statement statement = con.createStatement();
            java.sql.ResultSet rs = statement.executeQuery ( querySQL );

            while ( rs.next ( ) ) {
                String teams = rs.getString("team1") + "  @  " + rs.getString("team2");
                String round = rs.getString("round");
                String time = rs.getTime("start_time").toString();
                Date dateMatch = rs.getDate("date");
                int seatnumber = rs.getInt("seatnumber");
                String stadium = rs.getString("sname");
                String price = rs.getFloat("price") + "$";

                SimpleDateFormat dateFormatter = new SimpleDateFormat("dd-MMM-yyyy");
                String date = dateFormatter.format(dateMatch);

                System.out.printf("%-25s %-13s %-9s %-13s %-4d %-10s %s\n", teams, round, time, date, seatnumber, price, stadium);
            }
            statement.close();
        }
        catch (SQLException e)
        {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE

            // something more meaningful than a print would be good
            System.out.println("Code: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println(e);
        }
    }

    public static void printMatchAvailableTickets(Connection con, int matchID) throws SQLException{
        try
        {
            String querySQL = "SELECT seatNumber, price FROM Tickets WHERE mid = " + matchID + " AND purchase_status = 0 ORDER BY date";

            Statement statement = con.createStatement();
            java.sql.ResultSet rs = statement.executeQuery(querySQL);

            while (rs.next()) {
                int seatNumber = rs.getInt("seatNumber");
                String price = rs.getFloat("price") + "$";

                System.out.printf("|%-5d |%-8s |\n", seatNumber, price);
            }
            statement.close();
        } catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE

            // something more meaningful than a print would be good
            System.out.println("Code: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println(e);
        }
    }

    public static void processTicketPurchase(Connection con, String email, int mid, int seatNumber, String date, String stadium) throws SQLException{
        System.out.println("Purchasing...");

        try
        {
            Statement statement = con.createStatement();
            String insertSQL = "INSERT INTO Buys VALUES" +
                    " (\'"+ email + "\', \'" + date + "\', " + seatNumber + ", \'" + stadium + "\', " + mid + ")";

            statement.executeUpdate(insertSQL);

            String updateSQL = "UPDATE Tickets SET purchase_status = 1 WHERE" +
                    " mid = " + mid + " AND seatNumber = " + seatNumber + "";

            statement.executeUpdate(updateSQL);
            statement.close();
        } catch (SQLException e) {
            int sqlCode = e.getErrorCode(); // Get SQLCODE
            String sqlState = e.getSQLState(); // Get SQLSTATE

            // something more meaningful than a print would be good
            System.out.println("Code: " + sqlCode + "  sqlState: " + sqlState);
            System.out.println(e);
        }
    }
}
