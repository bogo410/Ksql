CREATE DATABASE Spy; 
CREATE TABLE Student();
CREATE TABLE Students(Id SMALLINT, Name VARCHAR, Surname VARCHAR, Prova VARCHAR);
CREATE TABLE Newtable1();
CREATE TABLE Newtable2();
CREATE TABLE Newtable3();
ALTER TABLE Student ADD Anno SMALLINT;
ALTER TABLE Students ADD Anno SMALLINT;
ALTER TABLE Students DROP COLUMN Surname;
ALTER TABLE Student DROP COLUMN Anno;
ALTER TABLE Student ADD AnnnoAccademico SMALLINT;
ALTER TABLE Student RENAME COLUMN AnnnoAccademico TO NewAnnnoAccademico;
ALTER TABLE Students DROP Prova;
DROP TABLE NewTable1;
DROP TABLE NewTable2, Newtable3;
ALTER TABLE Student RENAME TO NewStudent;