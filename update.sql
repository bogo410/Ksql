//update.sql

CREATE DATABASE Spy; 

CREATE TABLE Prova (Try SMALLINT , Pry VARCHAR(10), Cry VARCHAR);
INSERT INTO Prova (Try) VALUES (5);
INSERT INTO Prova (Try,Pry) VALUES (7,'"ciao"');

UPDATE Prova SET Try = '10';
UPDATE Prova SET Pry = '"miao"';
UPDATE Prova SET Cry = '"biao"';

UPDATE Prova SET Cry = '5';
UPDATE Prova SET Pry = '"miao5678910"';

//UPDATE Prova SET Try = 10 , Pry = '"def"';