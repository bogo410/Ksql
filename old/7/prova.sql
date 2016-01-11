//prova.sql

CREATE DATABASE Spy; 
CREATE TABLE Student();
CREATE TABLE Students(Id SMALLINT, Name VARCHAR, Surname VARCHAR);
ALTER TABLE Student ADD Anno SMALLINT;
ALTER TABLE Students ADD Anno SMALLINT;

CREATE TABLE Newtable1();
CREATE TABLE Newtable2();
CREATE TABLE Newtable3();
ALTER TABLE Students DROP COLUMN Surname;
ALTER TABLE Student DROP COLUMN Anno;
ALTER TABLE Student ADD AnnnoAccademico SMALLINT;

ALTER TABLE Student RENAME COLUMN AnnnoAccademico TO NewAnnnoAccademico;

ALTER TABLE Student RENAME TO NewStudent;
ALTER TABLE Students DROP Name;

DROP TABLE Newtable3;
DROP TABLE Students;

DROP TABLE NewTable2 , Newtable3;

//ALTER TABLE NewStudent ADD Name VARCHAR, DROP COLUMN NewAnnnoAccademico;
//DROP TABLE NewTable2 , Newtable3;

