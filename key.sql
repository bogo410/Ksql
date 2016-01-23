//prova per primary key

CREATE DATABASE Spy;

CREATE TABLE Chiave (key SMALLINT PRIMARY KEY, notkey VARCHAR(4) );

INSERT INTO Chiave (key,notkey) VALUES (7,'"ciao"');
INSERT INTO Chiave (notkey,key) VALUES ('"ciao"',14);

INSERT INTO Chiave (key) VALUES (10);

INSERT INTO Chiave (key) VALUES (10);

//INSERT INTO Chiave (notkey) VALUES ('"ciao"');