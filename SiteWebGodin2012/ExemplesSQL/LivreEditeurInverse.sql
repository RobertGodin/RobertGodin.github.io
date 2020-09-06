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
DROP TABLE Utilisateur
/
DROP TYPE UtilisateurType
/
DROP TYPE PersonneType
/

-- Création du schéma
CREATE OR REPLACE TYPE TypeDonnéesAnnée AS OBJECT
(valeurAnnée	INTEGER)
/
CREATE OR REPLACE TYPE EditeurType
/
CREATE TYPE LivreType AS OBJECT
(ISBN				CHAR(13),
 titre			VARCHAR(50),
 annéeParution		TypeDonnéesAnnée,
 éditeur			REF EditeurType
)
/
CREATE OR REPLACE TYPE LivreRefType AS OBJECT
(livreRef	REF	LivreType)
/
CREATE TYPE tableRefLivresType AS
TABLE OF LivreRefType
/
CREATE OR REPLACE TYPE EditeurType AS OBJECT
(nomEditeur 		VARCHAR(20),
 ville 			VARCHAR(20),
 lesLivres			tableRefLivresType
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
SELECT l.éditeur.nomEditeur, l.ISBN
FROM Livre l
WHERE l.éditeur.ville = 'Reading, MA'
/
SELECT livres.livreRef.ISBN, livres.livreRef.titre
FROM THE 
(SELECT e.lesLivres FROM Editeur e WHERE nomEditeur = 'Addison-Wesley') livres
/
CREATE TYPE PersonneType AS OBJECT
(nom		VARCHAR(10),
 prénom 	VARCHAR(10)) NOT FINAL
/
CREATE TYPE UtilisateurType UNDER PersonneType
(idUtilisateur		VARCHAR(10),
 motPasse		VARCHAR(10),
 catégorieUtilisateur	VARCHAR(14))
/
CREATE TABLE Utilisateur OF UtilisateurType
/
INSERT INTO Utilisateur VALUES(1,'cocorico','Marshal', 'Amanda', 'membre')
/
INSERT INTO Utilisateur VALUES(2,'cocorico','Degas', 'Edgar', 'membre')
/
INSERT INTO Utilisateur VALUES(3,'cocorico','Lecommis', 'Coco', 'employé')
/
INSERT INTO Utilisateur VALUES(4,'cocorico','Lecommis', 'Toto', 'employé')
/