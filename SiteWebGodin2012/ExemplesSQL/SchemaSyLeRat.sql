SET ECHO ON
-- Script Oracle SQL*plus de cr�ation du sch�ma SyLeRat 
-- Les TRIGGER ne sont pas tous impl�ment�s

-- Cr�ation des tables
CREATE TABLE Utilisateur
(idUtilisateur 			VARCHAR(10)	NOT NULL,
 motPasse	 			VARCHAR(10)	NOT NULL,
 nom 					VARCHAR(10)	NOT NULL,
 pr�nom 				VARCHAR(10)	NOT NULL,
 cat�gorieUtilisateur 	VARCHAR(14)  	NOT NULL
 	CHECK(cat�gorieUtilisateur IN ('employ�', 'membre')),
 PRIMARY KEY (idUtilisateur)
)
/
CREATE TABLE Employ�
(idUtilisateur 			VARCHAR(10)	NOT NULL,
 codeMatricule	 		CHAR(6)	NOT NULL,
 cat�gorieEmploy�			VARCHAR(15) NOT NULL 
	CHECK(cat�gorieEmploy� IN ('bibloth�caire', 'commis')),
 PRIMARY KEY (idUtilisateur),
 UNIQUE (codeMatricule),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur
)
/
CREATE OR REPLACE TRIGGER AIEmploy�ModifierCat�gorie
AFTER INSERT ON Employ�
REFERENCING
	NEW AS ligneApr�s
FOR EACH ROW
BEGIN
	UPDATE 	Utilisateur
	SET 		cat�gorieUtilisateur = 'employ�'
	WHERE 	idUtilisateur = :ligneApr�s.idUtilisateur;
END AIEmploy�ModifierCat�gorie ;
/
CREATE OR REPLACE TRIGGER BDUEmploy�Interdiction
BEFORE DELETE OR UPDATE ON Employ�
BEGIN
	raise_application_error(-20200,'DELETE et UPDATE interdit pour Employ�');
END BDUEmploy�Interdiction;
/
CREATE TABLE Membre
(idUtilisateur 			VARCHAR(10)	NOT NULL,
 t�l�phoneR�sidence	 	VARCHAR(15)	NOT NULL,
 PRIMARY KEY (idUtilisateur),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur
)
/
CREATE OR REPLACE TRIGGER AIMembreModifierCat�gorie
AFTER INSERT ON Membre
REFERENCING
	NEW AS ligneApr�s
FOR EACH ROW
BEGIN
	UPDATE 	Utilisateur
	SET 		cat�gorieUtilisateur = 'membre'
	WHERE 	idUtilisateur = :ligneApr�s.idUtilisateur;
END AIMembreModifierCat�gorie ;
/
CREATE OR REPLACE TRIGGER BDUMembreInterdiction
BEFORE DELETE OR UPDATE ON Membre
BEGIN
	raise_application_error(-20201,'DELETE et UPDATE interdit pour Membre');
END BDUMembreInterdiction;
/
CREATE TABLE MembreG�n�ral
(noSequence 			NUMBER(10)		NOT NULL,
 nbMaxPr�ts	 			NUMBER(10)		DEFAULT 5 NOT NULL,
 dur�eMaxPr�ts			NUMBER(10)		DEFAULT 7 NOT NULL,
 PRIMARY KEY (noSequence)
)
/
CREATE OR REPLACE TRIGGER BDMembreG�n�ral
BEFORE DELETE ON MembreG�n�ral
BEGIN
	raise_application_error(-20201,'DELETE interdit pour MembreG�n�ral');
END BDMembreG�n�ral;
/
CREATE OR REPLACE TRIGGER BUMembreG�n�ral
BEFORE UPDATE OF nbMaxPr�ts ON MembreG�n�ral
FOR EACH ROW
WHEN (NEW.nbMaxPr�ts < OLD.nbMaxPr�ts)
BEGIN
	raise_application_error(-20212,'Interdit de diminuer nbMaxPr�ts');
END BUMembreG�n�ral;
/
CREATE TABLE Editeur
(nomEditeur 			VARCHAR(20)	NOT NULL,
 ville 				VARCHAR(20)	NOT NULL,
 PRIMARY KEY (nomEditeur)
)
/
CREATE TABLE Cat�gorie
(code					VARCHAR(10)	NOT NULL,
 descripteur 			VARCHAR(20)	NOT NULL,
 codeParent				VARCHAR(10),
 PRIMARY KEY (code),
 FOREIGN KEY (codeParent) REFERENCES Cat�gorie
)
/
CREATE TABLE Livre
(ISBN 				CHAR(13)		NOT NULL,
 titre 				VARCHAR(50)		NOT NULL,
 ann�eParution 			NUMBER(4)		NOT NULL
CHECK(ann�eParution > 0),
 nomEditeur 			VARCHAR(20)	NOT NULL,
 code					VARCHAR(10)	NOT NULL,
 PRIMARY KEY (ISBN),
 FOREIGN KEY (nomEditeur) REFERENCES Editeur
 	DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (code) REFERENCES Cat�gorie
)
/
CREATE OR REPLACE TRIGGER BDULivreInterdiction
BEFORE DELETE OR UPDATE ON Livre
BEGIN
	raise_application_error(-20202,'DELETE et UPDATE interdit pour Livre');
END BDULivreInterdiction;
/
CREATE TABLE Exemplaire
(idExemplaire 			VARCHAR(10)		NOT NULL,
 dateAchat 				DATE			NOT NULL,
 statut 				VARCHAR(15)		NOT NULL
	CHECK(statut IN ('pr�t�', 'disponible','retir�')),
 ISBN 				CHAR(13)		NOT NULL,
 PRIMARY KEY (idExemplaire),
 FOREIGN KEY (ISBN) REFERENCES Livre
)
/
CREATE OR REPLACE TRIGGER BIEditeurAuMoinsUnLivre
BEFORE INSERT ON Editeur
FOR EACH ROW
DECLARE
	nbEditeur 		INTEGER;
	editeurSansLivre 	EXCEPTION;
BEGIN
	SELECT COUNT(*) INTO nbEditeur FROM Livre
	WHERE nomEditeur = :NEW.nomEditeur;
	IF nbEditeur = 0 THEN
		RAISE editeurSansLivre;
	END IF;
EXCEPTION
	WHEN editeurSansLivre THEN
		raise_application_error(-20110,'l''�diteur doit avoir au moins un livre');
	WHEN	OTHERS THEN
		raise_application_error(-20105,'erreur interne');
END BIEditeurAuMoinsUnLivre;
/
CREATE TABLE Pr�tEnCours
(idExemplaire 			VARCHAR(10)	NOT NULL,
 datePr�t 				DATE	DEFAULT SYSDATE NOT NULL,
 idUtilisateur 			VARCHAR(10)	NOT NULL,
 PRIMARY KEY (idExemplaire),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur,
 FOREIGN KEY (idExemplaire) REFERENCES Exemplaire
)
/
CREATE OR REPLACE TRIGGER BIPr�tEnCoursV�rifier
 BEFORE INSERT ON Pr�tEnCours
 FOR EACH ROW
DECLARE
	statutExemplaire 		Exemplaire.statut%TYPE;
	idUtilisateurMembre	Membre.idUtilisateur%TYPE;
	datePr�t			Pr�tEnCours.datePr�t%TYPE;
	nombrePr�tsEnCours 	INTEGER;
	nombreMaximalPr�ts 	INTEGER;
	dur�eMaximalePr�ts 	INTEGER;
	exemplaireNonDisponible EXCEPTION;
	nombreMaximalAtteint 	EXCEPTION;
	pr�tEnRetard 		EXCEPTION;
	-- Curseur pour v�rifier si membre
	CURSOR leMembre(unIdUtilisateur Pr�tEnCours.idUtilisateur%TYPE)IS
		SELECT idUtilisateur
		FROM Membre WHERE idUtilisateur = unIdUtilisateur;
	-- Curseur (CURSOR) PL/SQL pour it�rer sur les pr�ts
	CURSOR lignesPr�ts(unIdUtilisateur Pr�tEnCours.idUtilisateur%TYPE)IS
    		SELECT 	datePr�t
    		FROM		Pr�tEnCours
    		WHERE 	idUtilisateur = unIdUtilisateur;
BEGIN
	--  V�rifier si statut de l'exemplaire = disponible
	SELECT 	statut
	INTO 		statutExemplaire
	FROM 		Exemplaire
	WHERE 	idExemplaire = :NEW.idExemplaire
	FOR UPDATE; /* pour s�rialisabilit�*/
	IF statutExemplaire <> 'disponible' THEN
		RAISE exemplaireNonDisponible;
	END IF;
	-- V�rifier si l'emprunteur est un membre
	OPEN leMembre(:NEW.idUtilisateur);
	FETCH leMembre INTO idUtilisateurMembre;
	IF leMembre%FOUND THEN
	-- V�rifier si le nombre maximal d'emprunts est atteint ou si un retard existe
		SELECT	nbMaxPr�ts, dur�eMaxPr�ts
		INTO		nombreMaximalPr�ts, dur�eMaximalePr�ts
		FROM		MembreG�n�ral;
		LOCK TABLE Pr�tEnCours IN SHARE ROW EXCLUSIVE MODE;
		nombrePr�tsEnCours := 0;
		OPEN lignesPr�ts(:NEW.idUtilisateur);
		LOOP
			FETCH lignesPr�ts INTO datePr�t;
			EXIT WHEN lignesPr�ts%NOTFOUND;
			IF (SYSDATE-datePr�t > dur�eMaximalePr�ts) THEN
				RAISE pr�tEnRetard;
			END IF;
			nombrePr�tsEnCours := nombrePr�tsEnCours + 1;
		END LOOP;
		CLOSE lignesPr�ts;
		IF nombrePr�tsEnCours >= nombreMaximalPr�ts THEN
			RAISE nombreMaximalAtteint;
		END IF;
	END IF;
	CLOSE leMembre;
EXCEPTION
	WHEN exemplaireNonDisponible THEN
		raise_application_error(-20103,'l''exemplaire n''a pas le statut disponible');
	WHEN nombreMaximalAtteint THEN
		raise_application_error(-20101,'le nombre maximal d''emprunts est atteint');
	WHEN pr�tEnRetard THEN
		raise_application_error(-20104,'emprunt interdit � cause de retard');
	WHEN	OTHERS THEN
		raise_application_error(-20105,'erreur interne');
END BIPr�tEnCoursV�rifier;
/
CREATE OR REPLACE TRIGGER BUPr�tEnCours
BEFORE UPDATE ON Pr�tEnCours
BEGIN
	raise_application_error(-20203,'UPDATE interdit pour Pr�tEnCours');
END BUPr�tEnCours;
/
CREATE OR REPLACE TRIGGER AIPr�tEnCoursModifStatutEx
AFTER INSERT ON Pr�tEnCours
REFERENCING
	NEW AS ligneApr�s
FOR EACH ROW
BEGIN
	UPDATE 	Exemplaire
	SET 		statut = 'pr�t�'
	WHERE 	idExemplaire = :ligneApr�s.idExemplaire;
END AIPr�tEnCoursModifStatutEx;
/
-- On utilise le m�canisme de SEQUENCE Oracle pour g�n�rer les valeurs de
-- la cl� primaire noSequence de la table Pr�tArchiv�
CREATE SEQUENCE SequenceNoPr�tArchiv�
/
CREATE TABLE Pr�tArchiv�
(noSequence				NUMBER(10)		NOT NULL,
 datePr�t 				DATE			NOT NULL,
 dateRetour 			DATE			NOT NULL,
 idUtilisateur 			VARCHAR(10)		NOT NULL,
 idExemplaire 			VARCHAR(10)		NOT NULL,
 PRIMARY KEY (noSequence),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur,
 FOREIGN KEY (idExemplaire) REFERENCES Exemplaire,
 CHECK (dateRetour >= datePr�t)
)
/
CREATE OR REPLACE TRIGGER ADPr�tEnCours
AFTER DELETE ON Pr�tEnCours
FOR EACH ROW
BEGIN
 	UPDATE 	Exemplaire
 	SET 		statut = 'disponible'
 	WHERE 	idExemplaire = :OLD.idExemplaire;

 	INSERT INTO Pr�tArchiv� VALUES
 		(SequenceNoPr�tArchiv�.NEXTVAL, :OLD.datePr�t, SYSDATE,
		:OLD.idUtilisateur,:OLD.idExemplaire);
	-- SequenceNoPr�tArchiv�.NEXTVAL retourne la prochaine valeur de la SEQUENCE
END ADPr�tEnCours;
/

CREATE TABLE Auteur
(noSequence				NUMBER(10)		NOT NULL,
 nom	 				VARCHAR(20)		NOT NULL,
 pr�nom 				VARCHAR(20)		NOT NULL,
 PRIMARY KEY (noSequence)
)
/
CREATE TABLE AuteurLivre
(noSequence				NUMBER(10)		NOT NULL,
 ISBN 				CHAR(13)		NOT NULL,
 ordreAuteur 			NUMBER(10)		NOT NULL,
 PRIMARY KEY (noSequence, ISBN),
 UNIQUE (ISBN, ordreAuteur),
 FOREIGN KEY (noSequence) REFERENCES Auteur,
 FOREIGN KEY (ISBN) REFERENCES Livre
)
/
PROMPT Quelques exemples de manipulations de donn�es
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY'
/
ALTER SESSION SET NLS_DATE_LANGUAGE = ENGLISH
/

INSERT INTO Cat�gorie VALUES('10','Sciences',NULL)
/
INSERT INTO Cat�gorie VALUES('20','Philosophie',NULL)
/
INSERT INTO Cat�gorie VALUES('30','Histoire', NULL)
/
INSERT INTO Cat�gorie VALUES('40','Arts', NULL)
/
INSERT INTO Cat�gorie VALUES('50','Litt�rature', NULL) 
/
INSERT INTO Cat�gorie VALUES('101','Informatique','10')
/
INSERT INTO Cat�gorie VALUES('102','Math�matiques','10')
/
INSERT INTO Cat�gorie VALUES('103','Chimie','10')
/
INSERT INTO Cat�gorie VALUES('501','Roman','50') 
/
INSERT INTO Cat�gorie VALUES('502','Po�sie','50')
/
COMMIT
/
SELECT * FROM Cat�gorie
/

INSERT INTO Auteur VALUES(1,'Knuth','Donald') 
/
INSERT INTO Auteur VALUES(2,'Salton','Gerard') 
/
INSERT INTO Auteur VALUES(3,'Blaha','Michael') 
/
INSERT INTO Auteur VALUES(4,'Premerlani','Henry F.') 
/
INSERT INTO Auteur VALUES(5,'Hofstadter','Douglas,R.')
/
COMMIT
/
SELECT * FROM Auteur
/

INSERT INTO Livre VALUES('3-333-3333333', 'The Art of Computer Programming',1973, 'Addison Wesley', '101') 
/
INSERT INTO Livre VALUES('0-201-12227-8','Automatic Text Processing',1989, 'Addison Wesley', '101') 
/
INSERT INTO Livre VALUES('0-13-123829-9','Object-Oriented Modeling and Design for DB App.',1998, 'Prentice Hall', '101') 
/
INSERT INTO Livre VALUES('0-394-74502-7', 'G�del, Escher, Bach : An Eternal Golden Braid', 1980, 'Random House', '20')
/
SELECT * FROM Livre
/

INSERT INTO Editeur VALUES ('Addison Wesley', 'Reading,MA')
/
INSERT INTO Editeur VALUES ('Prentice Hall', 'U.Sad.Riv.')
/
INSERT INTO Editeur VALUES ('Random House', 'NewYork,NY')
/
COMMIT
/
SELECT * FROM Editeur
/

INSERT INTO AuteurLivre VALUES(1, '3-333-3333333', 1)
/
INSERT INTO AuteurLivre VALUES(2, '0-201-12227-8', 1)
/
INSERT INTO AuteurLivre VALUES(3, '0-13-123829-9', 1)
/
INSERT INTO AuteurLivre VALUES(4, '0-13-123829-9', 2)
/
INSERT INTO AuteurLivre VALUES(5, '0-394-74502-7', 1)
/
COMMIT
/

INSERT INTO Exemplaire VALUES(1, '10-dec-1975', 'disponible','3-333-3333333')
/
INSERT INTO Exemplaire VALUES(2, '10-dec-1975', 'disponible','3-333-3333333')
/
INSERT INTO Exemplaire VALUES(3, '15-jan-1990', 'disponible','0-201-12227-8')
/
INSERT INTO Exemplaire VALUES(4, '20-mar-1999', 'disponible', '0-13-123829-9')
/
INSERT INTO Exemplaire VALUES(5, '22-mar-1999', 'disponible', '0-13-123829-9')
/
INSERT INTO Exemplaire VALUES(6, '12-sep-1982', 'disponible', '0-394-74502-7')
/
COMMIT
/
SELECT * FROM Exemplaire;
/

INSERT INTO MembreG�n�ral VALUES(1, 2, 7)
/
COMMIT
/
SELECT * FROM MembreG�n�ral
/

INSERT INTO Utilisateur VALUES(1,'cocorico','Marshal', 'Amanda', 'membre')
/
INSERT INTO Membre VALUES(1,'(111)111-1111')
/

INSERT INTO Utilisateur VALUES(2,'cocorico','Degas', 'Edgar', 'membre')
/
INSERT INTO Membre VALUES(2,'(222)222-2222')
/

INSERT INTO Utilisateur VALUES(3,'cocorico','Lecommis', 'Coco', 'employ�')
/
INSERT INTO Employ� VALUES(3,'LECC01','commis')
/
INSERT INTO Utilisateur VALUES(4,'cocorico','Lecommis', 'Toto', 'employ�')
/
INSERT INTO Employ� VALUES(4,'LECT01','commis')
/
SELECT * FROM Utilisateur
/
COMMIT
/

PROMPT Editeur sans Livre
INSERT INTO Editeur VALUES ('Eyrolles','Paris')
/
PROMPT Pr�t correct
INSERT INTO Pr�tEnCours VALUES(1,'20-jul-1999',1)
/
PROMPT cas de retard
INSERT INTO Pr�tEnCours VALUES(3,'30-jul-1999',1)
/
PROMPT cas non disponible
INSERT INTO Pr�tEnCours VALUES(1,'30-jul-1999',2)
/
DELETE FROM Pr�tEnCours WHERE idExemplaire = 1
/
SELECT * FROM Pr�tEnCours
/
SELECT * FROM Pr�tArchiv�
/
PROMPT defaut pour la date de pr�t
INSERT INTO Pr�tEnCours(idExemplaire, idUtilisateur) VALUES(1,1)
/
INSERT INTO Pr�tEnCours(idExemplaire, idUtilisateur) VALUES(3,1)
/
PROMPT cas de maximum atteint (2 dans cet essai)
INSERT INTO Pr�tEnCours(idExemplaire, idUtilisateur) VALUES(5,1)
/
SELECT * FROM Pr�tEnCours
/
PROMPT maximum d�pass� pour Commis
INSERT INTO Pr�tEnCours(idExemplaire, idUtilisateur) VALUES(2,3)
/
INSERT INTO Pr�tEnCours(idExemplaire, idUtilisateur) VALUES(4,3)
/
INSERT INTO Pr�tEnCours(idExemplaire, idUtilisateur) VALUES(5,3)
/

