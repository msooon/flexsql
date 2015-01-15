--term types
--1 (category_tag) [default]
--2 (system category) mit funktionalität verbunden
--3 feld

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

INSERT INTO "term" VALUES(1,'node',2);
INSERT INTO "term" VALUES(2,'check',2);
INSERT INTO "term" VALUES(3,'weekly',2);
INSERT INTO "term" VALUES(4,'monthly',2);
INSERT INTO "term" VALUES(5,'todo',2);
INSERT INTO "term" VALUES(6,'biweekly',2);
INSERT INTO "term" VALUES(7,'periodical',2);
INSERT INTO "term" VALUES(8,'blacklist',2);
INSERT INTO "term" VALUES(9,'yearly',2);
INSERT INTO "term" VALUES(10,'done',2);
INSERT INTO "term" VALUES(11,'person',2);
INSERT INTO "term" VALUES(12,'group',2);
--access rights
INSERT INTO "term" VALUES(13,'memberOf',2);
INSERT INTO "term" VALUES(14,'view',2);
INSERT INTO "term" VALUES(15,'edit',2);
INSERT INTO "term" VALUES(16,'grant',2);
--other system terms
INSERT INTO "term" VALUES(17,'date',2); --occurence
INSERT INTO "term" VALUES(18,'expiration',2); 
--INSERT INTO "term" VALUES( ,'exp_action,'3 --not needed
--INSERT INTO "term" VALUES(,'invite',2);
INSERT INTO "term" VALUES(19,'request',2);
INSERT INTO "term" VALUES(20,'accept',2);
INSERT INTO "term" VALUES(21,'privious_version',2);
INSERT INTO "term" VALUES(22,'participant',2);
INSERT INTO "term" VALUES(23,'place',2); --room,location
INSERT INTO "term" VALUES(24,'',2);
INSERT INTO "term" VALUES(25,'',2);
--objects and elements
INSERT INTO "term" VALUES(26,'name',3);
INSERT INTO "term" VALUES(27,'firstname',3);
INSERT INTO "term" VALUES(28,'sex',3);
INSERT INTO "term" VALUES(29,'birthday',3);
INSERT INTO "term" VALUES(30,'password',3);

INSERT INTO "term" VALUES(31,'post',3);
INSERT INTO "term" VALUES(32,'comment',3);
INSERT INTO "term" VALUES(33,'title',3);
INSERT INTO "term" VALUES(34,'text',3); -- /about/description',

INSERT INTO "term" VALUES(35,'exam',2); -- pruefung
INSERT INTO "term" VALUES(36,'version',3);
INSERT INTO "term" VALUES(37,'semester',3);
COMMIT;
