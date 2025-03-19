DROP DATABASE ChessDB;
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

CREATE TABLE Sponsor(
sponsor_ID INTEGER,
sponsor_name VARCHAR(50),

PRIMARY KEY (sponsor_ID)
);

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

-- RELATIONS

-- Relation between Title and Player
CREATE TABLE Assigned(
title_ID INTEGER,
username VARCHAR(50),

PRIMARY KEY (title_ID, username),
FOREIGN KEY (title_ID) REFERENCES Title(title_ID) ON DELETE CASCADE,
FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE,
UNIQUE (username)
);

CREATE TABLE arb_has_cert(
certificate_type VARCHAR(50) NOT NULL,
username VARCHAR(50) NOT NULL,

PRIMARY KEY (certificate_type, username),
FOREIGN KEY (username) REFERENCES Arbiter(username) ON DELETE CASCADE,
FOREIGN KEY (certificate_type) REFERENCES Certificate(certificate_type) ON DELETE CASCADE
);

CREATE TABLE coach_has_cert(
certificate_type VARCHAR(50) NOT NULL,
username VARCHAR(50) NOT NULL,

PRIMARY KEY (certificate_type, username),
FOREIGN KEY (username) REFERENCES Coach(username) ON DELETE CASCADE,
FOREIGN KEY (certificate_type) REFERENCES Certificate(certificate_type) ON DELETE CASCADE
);

CREATE TABLE has_spec(
speciality_type VARCHAR(50) NOT NULL,
username VARCHAR(50) NOT NULL,

PRIMARY KEY (speciality_type, username),
FOREIGN KEY (username) REFERENCES Coach(username) ON DELETE CASCADE,
FOREIGN KEY (speciality_type) REFERENCES Speciality(speciality_type) ON DELETE CASCADE
);

CREATE TABLE belongs_to(
username VARCHAR(50) NOT NULL,
team_ID INTEGER NOT NULL,

FOREIGN KEY (username) REFERENCES Player(username) ON DELETE CASCADE,
FOREIGN KEY (team_ID) REFERENCES Team(team_ID) ON DELETE CASCADE
);

/*

INSERT INTO User (username, password, name, surname, nationality)
VALUES ("usrnm", 123, "umut", "sendag", "tr");

Insert INTO Certificate (certificate_type)
VALUES("cert");

Insert INTO Certificate (certificate_type)
VALUES("art");

Insert INTO Speciality (speciality_type)
VALUES("spec");

Insert INTO Coach(username)
VALUES ("usrnm");

INSERT INTO coach_has_cert(username, certificate_type)
VALUES ("usrnm", "cert");

DELETE FROM Certificate WHERE certificate_type = "cert";

SELECT * FROM coach_has_cert;

*/
