--term types
--1 (system category) connected with funcionallity
--2 feld

--person = user? (channel?) (profile-def simple, normal, expert ,' default, private) 
--name, firstname, sex, birthday, password?,

--event
--name, ort, ..

--exam
--stg, pnr, 

--post
--title, text/description, 

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE term(id integer PRIMARY KEY,name text, type integer);

INSERT INTO "term" VALUES(1,'node',1);
INSERT INTO "term" VALUES(2,'check',1);
INSERT INTO "term" VALUES(3,'weekly',1);
INSERT INTO "term" VALUES(4,'monthly',1);
INSERT INTO "term" VALUES(5,'todo',1);
INSERT INTO "term" VALUES(6,'biweekly',1);
INSERT INTO "term" VALUES(7,'periodical',1);
INSERT INTO "term" VALUES(8,'blacklist',1);
INSERT INTO "term" VALUES(9,'yearly',1);
INSERT INTO "term" VALUES(10,'done',1);
INSERT INTO "term" VALUES(11,'person',1);
INSERT INTO "term" VALUES(12,'group',1);
--access rights
INSERT INTO "term" VALUES(13,'memberOf',1);
INSERT INTO "term" VALUES(14,'view',1);
INSERT INTO "term" VALUES(15,'edit',1);
INSERT INTO "term" VALUES(16,'grant',1);
--other system terms
INSERT INTO "term" VALUES(17,'date',1); --occurence
INSERT INTO "term" VALUES(18,'expiration',1); 
--INSERT INTO "term" VALUES( ,'exp_action,'3 --not needed
--INSERT INTO "term" VALUES(,'invite',1);
INSERT INTO "term" VALUES(19,'request',1);
INSERT INTO "term" VALUES(20,'accept',1);
INSERT INTO "term" VALUES(21,'privious_version',1);
INSERT INTO "term" VALUES(22,'participant',1);
INSERT INTO "term" VALUES(23,'place',1); --room,location
INSERT INTO "term" VALUES(24,'form',1); --input mask
INSERT INTO "term" VALUES(25,'tag',1); --category tag
--objects and elements
INSERT INTO "term" VALUES(26,'name',2);
INSERT INTO "term" VALUES(27,'firstname',2);
INSERT INTO "term" VALUES(28,'sex',2);
INSERT INTO "term" VALUES(29,'birthday',2);
INSERT INTO "term" VALUES(30,'password',2);

INSERT INTO "term" VALUES(31,'post',2);
INSERT INTO "term" VALUES(32,'comment',2);
INSERT INTO "term" VALUES(33,'title',2);
INSERT INTO "term" VALUES(34,'text',2); -- /about/description',

INSERT INTO "term" VALUES(35,'exam',1); -- pruefung
INSERT INTO "term" VALUES(36,'version',2);
INSERT INTO "term" VALUES(37,'semester',2);

INSERT INTO "term" VALUES(38,'',2);
INSERT INTO "term" VALUES(39,'',2);

INSERT INTO "term" VALUES(40,'alias',2);

COMMIT;
