-- Script SQL Oracle de cr�ation de deux types avec relation 1-n bidirectionnelles
-- Suppression du sch�ma
DROP TABLE Livre 
/
DROP TABLE Editeur 
/
DROP TYPE tableRefLivresType FORCE
/
DROP TYPE LivreRefType 
/
DROP TYPE LivreType 
/
DROP TYPE EditeurType
/
DROP TYPE TypeDonn�esAnn�e
/

-- Cr�ation du sch�ma
CREATE OR REPLACE TYPE TypeDonn�esAnn�e AS OBJECT EXTERNAL NAME 'Typedonn�esann�e'
LANGUAGE JAVA USING SQLData
(valeurAnn�e	INTEGER EXTERNAL NAME 'valeurAnn�e')
/
CREATE OR REPLACE TYPE EditeurType
/
CREATE TYPE LivreType AS OBJECT EXTERNAL NAME 'LivreTypePourUDT'
LANGUAGE JAVA USING SQLData
(ISBN		CHAR(13)	EXTERNAL NAME 'ISBN',
 titre		VARCHAR(50)	EXTERNAL NAME 'titre',
 ann�eParution	TypeDonn�esAnn�e EXTERNAL NAME 'ann�eParution',
 �diteur	REF EditeurType EXTERNAL NAME '�diteur',
 MEMBER FUNCTION getLengthTitre return NUMBER
	EXTERNAL NAME 'getLengthTitre () return int',
 MEMBER FUNCTION getTitreEnMinuscules RETURN VARCHAR2
	EXTERNAL NAME 'getTitreEnMinuscules() return String'
)
/
CREATE OR REPLACE TYPE LivreRefType AS OBJECT
(livreRef	REF	LivreType)
/
CREATE TYPE tableRefLivresType AS
TABLE OF LivreRefType
/
CREATE OR REPLACE TYPE EditeurType AS OBJECT EXTERNAL NAME 'LivreTypePourUDT'
LANGUAGE JAVA USING SQLData
(nomEditeur 	VARCHAR(20)	EXTERNAL NAME 'nomEditeur',
 ville 		VARCHAR(20)	EXTERNAL NAME 'ville',
 lesLivres	tableRefLivresType EXTERNAL NAME 'lesLivres'
)
/
CREATE TABLE Editeur OF EditeurType
(PRIMARY KEY(nomEditeur))
NESTED TABLE lesLivres STORE AS tableLesLivres
/
CREATE TABLE Livre OF LivreType
(PRIMARY KEY(ISBN),
CONSTRAINT ann�eSup0 CHECK(ann�eParution.valeurAnn�e > 0),
CONSTRAINT referenceTableEditeur �diteur SCOPE IS Editeur)
/
-- Insertion de deux �diteurs 
INSERT INTO Editeur VALUES
 	('Loze-Dion', 'Longueuil',tableRefLivresType())
/
INSERT INTO Editeur VALUES
 	('Addison-Wesley', 'Reading, MA',tableRefLivresType())
/
-- Insertion de livres
INSERT INTO Livre
SELECT '0-201-12227-8', 'Automatic Text Processing',
 	TypeDonn�esAnn�e(1989), REF(e)
	FROM Editeur e WHERE nomEditeur = 'Addison-Wesley'
/
INSERT INTO THE
 	(SELECT e.lesLivres FROM Editeur e 
 	 WHERE e.nomEditeur = 'Addison-Wesley')
	SELECT REF(l) FROM Livre l 
 	WHERE l.ISBN = '0-201-12227-8'
/
INSERT INTO Livre
SELECT '0-8053-1755-4', 'Fundamentals of Database Systems',
 	TypeDonn�esAnn�e(2000), REF(e)
	FROM Editeur e WHERE nomEditeur = 'Addison-Wesley'
/
INSERT INTO THE
 	(SELECT e.lesLivres FROM Editeur e 
 	 WHERE e.nomEditeur = 'Addison-Wesley')
	SELECT REF(l) FROM Livre l 
 	WHERE l.ISBN = '0-8053-1755-4'
/
-- Exemples de requ�tes
SELECT l.getTitreEnMinuscules()
FROM Livre l
/
SELECT l.�diteur.nomEditeur, l.ISBN, l.getLengthTitre()
FROM Livre l
WHERE l.�diteur.ville = 'Reading, MA'
/
SELECT livres.livreRef.ISBN, livres.livreRef.titre
FROM THE 
(SELECT e.lesLivres FROM Editeur e WHERE nomEditeur = 'Addison-Wesley') livres
/