CREATE TABLE User (
username VARCHAR(20) PRIMARY KEY,
password VARCHAR(20),
name VARCHAR(20),
surname VARCHAR(20),
nationality VARCHAR(20)

);

CREATE TABLE Player(
username VARCHAR(20),
elo_rating INT,
date_of_birth DATE,
fide_ID INT,

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