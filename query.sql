CREATE DATABASE ChessDB;
USE ChessDB;

CREATE TABLE User (
	username VARCHAR(20),
	password VARCHAR(20),
	name VARCHAR(20),
	surname VARCHAR(20),
	nationality VARCHAR(20),

	PRIMARY KEY (username)
);

CREATE TABLE Player(
	username VARCHAR(20),
	elo_rating INT CHECK (elo_rating > 1000),
	date_of_birth DATE,
	fide_ID INT,
-- teamlist will added

	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE
);

CREATE TABLE Coach(
	username VARCHAR(20),

	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE
);

CREATE TABLE Arbiter(
	username VARCHAR(20),
	experience_level ENUM('beginner', 'intermediate', 'advanced') NOT NULL,

	PRIMARY KEY (username),
	FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE
);


CREATE TABLE MatchTable(
	table_ID INT,
	hall_ID INT NOT NULL,
    
	PRIMARY KEY (table_ID),
    -- `table_is_in` key constraint & total participation relation
    FOREIGN KEY (hall_ID) REFERENCES Hall(hall_ID) ON DELETE CASCADE
);

CREATE TABLE Hall(
	hall_ID INT,
	hall_name VARCHAR(50) NOT NULL,
	hall_capacity INT NOT NULL,
	hall_country VARCHAR(50) NOT NULL,

	PRIMARY KEY (hall_ID)
);

CREATE TABLE Tournament(
	tournament_ID INT,
	tournament_name VARCHAR(50) NOT NULL,
	format VARCHAR(50) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	chief_arbiter VARCHAR(50) NOT NULL,

	PRIMARY KEY (tournament_ID),
	FOREIGN KEY (chief_arbiter) REFERENCES Arbiter(username) ON DELETE CASCADE
);

-- `utilizes` relationship (tournament utilizes at least one hall)
CREATE TABLE Utilizes (
    tournament_ID INT,
    hall_ID INT NOT NULL,
    
    PRIMARY KEY (tournament_ID, hall_ID),
    FOREIGN KEY (tournament_ID) REFERENCES Tournament(tournament_ID) ON DELETE CASCADE,
    FOREIGN KEY (hall_ID) REFERENCES Hall(hall_ID) ON DELETE CASCADE
);

CREATE TABLE ChessMatch(
	match_ID INT,
	date DATE NOT NULL,
	tournament_ID INT NOT NULL,
	time_slot INT NOT NULL CHECK (time_slot BETWEEN 1 AND 4),
	rating INT NOT NULL CHECK (rating BETWEEN 1 AND 10),
	black_player_team INT NOT NULL,
	black_player VARCHAR(50) NOT NULL,
	hall_ID INT NOT NULL,
	result ENUM('white wins', 'black wins', 'draw') NOT NULL,
	assigned_arbiter_username VARCHAR(50) NOT NULL,
	white_player_team INT NOT NULL,
	white_player VARCHAR(50) NOT NULL,
	table_ID INT NOT NULL,

	PRIMARY KEY (match_ID),
    -- match should be deleted when a tournament is deleted
	FOREIGN KEY (tournament_ID) REFERENCES Tournament(tournament_ID) ON DELETE CASCADE,
	FOREIGN KEY (hall_ID) REFERENCES Hall(hall_ID) ON DELETE CASCADE,
	FOREIGN KEY (white_player) REFERENCES Player(username) ON DELETE CASCADE,
	FOREIGN KEY (black_player) REFERENCES Player(username) ON DELETE CASCADE,
	FOREIGN KEY (white_player_team) REFERENCES Team(team_ID) ON DELETE CASCADE,
	FOREIGN KEY (black_player_team) REFERENCES Team(team_ID) ON DELETE CASCADE,
	FOREIGN KEY (assigned_arbiter_username) REFERENCES Arbiter(username) ON DELETE CASCADE,
    -- `played_in` key constraint & total participation 
    FOREIGN KEY (table_ID) REFERENCES MatchTable(table_ID) ON DELETE CASCADE,
	-- Constraint to prevent same team players competing against each other
	CONSTRAINT different_teams CHECK (white_player_team != black_player_team),
	-- Unique constraint for hall, table, date, and time slot
	CONSTRAINT unique_match_slot UNIQUE (hall_ID, table_ID, date, time_slot),
    -- Unique constraint to prevent arbiters managing more than one match at the same time
    CONSTRAINT unique_arbiter_time UNIQUE (assigned_arbiter_username, date, time_slot),
    -- A player cannot be assigned to matches with overlapping time_slots 
    -- It is not complately correct for 2 time slot check since we cannot use trigggers
    CONSTRAINT unique_white_player_time UNIQUE (white_player, date, time_slot),
    CONSTRAINT unique_black_player_time UNIQUE (black_player, date, time_slot)
);

-- `includes` relation. Tournament includes at least one ChessMatch
CREATE TABLE TournamentIncludesMatch(
	tournament_ID INT,
	match_ID INT NOT NULL,
	 
	PRIMARY KEY (tournament_ID, match_ID),
	FOREIGN KEY (tournament_ID) REFERENCES Tournament(tournament_ID) ON DELETE CASCADE,
	FOREIGN KEY (match_ID) REFERENCES ChessMatch(match_ID) ON DELETE CASCADE
);

 