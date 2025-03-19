CREATE DATABASE ChessDB;
USE ChessDB;

-- ENTITIES

-- Table for User Entities
CREATE TABLE User (
	username VARCHAR(50),
	password VARCHAR(50),
	name VARCHAR(50),
	surname VARCHAR(50),
	nationality VARCHAR(50) NOT NULL,

	PRIMARY KEY (username)
);

-- Table for the Player Entities (ISA relationship between User)
CREATE TABLE Player(
    username VARCHAR(50),
    elo_rating INT CHECK (elo_rating > 1000),
    date_of_birth DATE,
    fide_ID INT,
-- Didn't use add team_list since it can be accessed through the belongs to relation


    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE
);

CREATE TABLE Certificate(
    certificate_type VARCHAR(50),

    PRIMARY KEY (certificate_type)
);

CREATE TABLE Speciality(
    speciality_type VARCHAR(50),

    PRIMARY KEY (speciality_type)
);

-- Table for the Coach Entites (ISA relationship between User)
CREATE TABLE Coach(
    username VARCHAR(50),

    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE
);

-- Table for the Arbiter Entities (ISA relationship between User)
CREATE TABLE Arbiter(
    username VARCHAR(50),
    experience_level ENUM('beginner', 'intermediate', 'advanced') NOT NULL,

    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE
);

-- Table for Title Entities
CREATE TABLE Title(
    title_ID INTEGER,
    title_name VARCHAR(50),

    PRIMARY KEY (title_ID),
    UNIQUE (title_ID)
    );
-- Table for Sponsor Entities
CREATE TABLE Sponsor(
    sponsor_ID INTEGER,
    sponsor_name VARCHAR(50),

    PRIMARY KEY (sponsor_ID)
);

-- Table for Team Entities
CREATE TABLE Team(
    team_ID INTEGER,
    team_name VARCHAR(50),
    contract_start DATE,
    contract_end DATE,
    coach_username VARCHAR(50) NOT NULL,
    sponsor_ID INT NOT NULL,

    PRIMARY KEY (team_ID),
    FOREIGN KEY (sponsor_ID) REFERENCES Sponsor(sponsor_ID),
    FOREIGN KEY (coach_username) REFERENCES Coach(username),
    UNIQUE(coach_username),
    UNIQUE(sponsor_ID)
);

CREATE TABLE Hall(
	hall_ID INT,
	hall_name VARCHAR(50) NOT NULL,
	hall_capacity INT NOT NULL,
	hall_country VARCHAR(50) NOT NULL,

	PRIMARY KEY (hall_ID)
);

CREATE TABLE MatchTable(
	table_ID INT,
	hall_ID INT NOT NULL,
    
	PRIMARY KEY (table_ID),
    -- `table_is_in` key constraint & total participation relation
    FOREIGN KEY (hall_ID) REFERENCES Hall(hall_ID) ON DELETE CASCADE
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

-- Relations

-- Relation between Title and Player (Player is assigned to at most one Title)
CREATE TABLE Assigned(
	title_ID INTEGER,
	username VARCHAR(50),

	PRIMARY KEY (title_ID, username),
	FOREIGN KEY (title_ID) REFERENCES Title(title_ID) ON DELETE CASCADE,
	FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE,
	UNIQUE (username)
);

-- Relation betwween Arbiter and Certificate (Arbiter has at least one Certificate)
CREATE TABLE ArbiterHasCertificate(
    certificate_type VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL,

    PRIMARY KEY (certificate_type, username),
    FOREIGN KEY (username) REFERENCES Arbiter(username) ON DELETE CASCADE,
    FOREIGN KEY (certificate_type) REFERENCES Certificate(certificate_type) ON DELETE CASCADE
);

-- Relation between Coach and Certificate (Coach has at least one Certificate)
CREATE TABLE CoachHasCertificate(
    certificate_type VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL,

    PRIMARY KEY (certificate_type, username),
    FOREIGN KEY (username) REFERENCES Coach(username) ON DELETE CASCADE,
    FOREIGN KEY (certificate_type) REFERENCES Certificate(certificate_type) ON DELETE CASCADE
);

-- Relation between Coach and Speciality (Coach has at least one Speciality)
CREATE TABLE HasSpeciality(
    speciality_type VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL,

    PRIMARY KEY (speciality_type, username),
    FOREIGN KEY (username) REFERENCES Coach(username) ON DELETE CASCADE,
    FOREIGN KEY (speciality_type) REFERENCES Speciality(speciality_type) ON DELETE CASCADE
);

-- Relation between player and team (A player belongs to at least one Team)
CREATE TABLE BelongsTo(
    username VARCHAR(50) NOT NULL,
    team_ID INTEGER NOT NULL,

    FOREIGN KEY (username) REFERENCES Player(username) ON DELETE CASCADE,
    FOREIGN KEY (team_ID) REFERENCES Team(team_ID) ON DELETE CASCADE
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

-- Relation between Team and Tournament
CREATE TABLE CompetesIn(
	team_ID INT,
    tournament_ID INT,
    win_count INT,
    
    PRIMARY KEY (team_ID, tournament_ID),
    FOREIGN KEY (team_ID) REFERENCES Team(team_ID) ON DELETE CASCADE,
	FOREIGN KEY (tournament_ID) REFERENCES Tournament(tournament_ID) ON DELETE CASCADE
);

 