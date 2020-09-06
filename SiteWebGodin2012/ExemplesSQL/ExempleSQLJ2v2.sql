-- Script SQL Oracle de création de deux types avec relation 1-n bidirectionnelles
-- Suppression du schéma
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
DROP TYPE TypeDonnéesAnnée
/

-- Création du schéma
CREATE OR REPLACE TYPE TypeDonnéesAnnée AS OBJECT EXTERNAL NAME 'Typedonnéesannée'
LANGUAGE JAVA USING SQLData
(valeurAnnée	INTEGER EXTERNAL NAME 'valeurAnnée')
/
CREATE OR REPLACE TYPE EditeurType
/
CREATE TYPE LivreType AS OBJECT EXTERNAL NAME 'LivreTypePourUDT'
LANGUAGE JAVA USING SQLData
(ISBN		CHAR(13)	EXTERNAL NAME 'ISBN',
 titre		VARCHAR(50)	EXTERNAL NAME 'titre',
 annéeParution	TypeDonnéesAnnée EXTERNAL NAME 'annéeParution',
 éditeur	REF EditeurType EXTERNAL NAME 'éditeur',
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
CONSTRAINT annéeSup0 CHECK(annéeParution.valeurAnnée > 0),
CONSTRAINT referenceTableEditeur éditeur SCOPE IS Editeur)
/
-- Insertion de deux éditeurs 
INSERT INTO Editeur VALUES
 	('Loze-Dion', 'Longueuil',tableRefLivresType())
/
INSERT INTO Editeur VALUES
 	('Addison-Wesley', 'Reading, MA',tableRefLivresType())
/
-- Insertion de livres
INSERT INTO Livre
SELECT '0-201-12227-8', 'Automatic Text Processing',
 	TypeDonnéesAnnée(1989), REF(e)
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
 	TypeDonnéesAnnée(2000), REF(e)
	FROM Editeur e WHERE nomEditeur = 'Addison-Wesley'
/
INSERT INTO THE
 	(SELECT e.lesLivres FROM Editeur e 
 	 WHERE e.nomEditeur = 'Addison-Wesley')
	SELECT REF(l) FROM Livre l 
 	WHERE l.ISBN = '0-8053-1755-4'
/
-- Exemples de requêtes
SELECT l.getTitreEnMinuscules()
FROM Livre l
/
SELECT l.éditeur.nomEditeur, l.ISBN, l.getLengthTitre()
FROM Livre l
WHERE l.éditeur.ville = 'Reading, MA'
/
SELECT livres.livreRef.ISBN, livres.livreRef.titre
FROM THE 
(SELECT e.lesLivres FROM Editeur e WHERE nomEditeur = 'Addison-Wesley') livres
/