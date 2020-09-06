SET ECHO ON
-- Script Oracle SQL*plus de création du schéma SyLeRat 
-- Les TRIGGER ne sont pas tous implémentés

-- Création des tables
CREATE TABLE Utilisateur
(idUtilisateur 			VARCHAR(10)	NOT NULL,
 motPasse	 			VARCHAR(10)	NOT NULL,
 nom 					VARCHAR(10)	NOT NULL,
 prénom 				VARCHAR(10)	NOT NULL,
 catégorieUtilisateur 	VARCHAR(14)  	NOT NULL
 	CHECK(catégorieUtilisateur IN ('employé', 'membre')),
 PRIMARY KEY (idUtilisateur)
)
/
CREATE TABLE Employé
(idUtilisateur 			VARCHAR(10)	NOT NULL,
 codeMatricule	 		CHAR(6)	NOT NULL,
 catégorieEmployé			VARCHAR(15) NOT NULL 
	CHECK(catégorieEmployé IN ('biblothécaire', 'commis')),
 PRIMARY KEY (idUtilisateur),
 UNIQUE (codeMatricule),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur
)
/
CREATE OR REPLACE TRIGGER AIEmployéModifierCatégorie
AFTER INSERT ON Employé
REFERENCING
	NEW AS ligneAprès
FOR EACH ROW
BEGIN
	UPDATE 	Utilisateur
	SET 		catégorieUtilisateur = 'employé'
	WHERE 	idUtilisateur = :ligneAprès.idUtilisateur;
END AIEmployéModifierCatégorie ;
/
CREATE OR REPLACE TRIGGER BDUEmployéInterdiction
BEFORE DELETE OR UPDATE ON Employé
BEGIN
	raise_application_error(-20200,'DELETE et UPDATE interdit pour Employé');
END BDUEmployéInterdiction;
/
CREATE TABLE Membre
(idUtilisateur 			VARCHAR(10)	NOT NULL,
 téléphoneRésidence	 	VARCHAR(15)	NOT NULL,
 PRIMARY KEY (idUtilisateur),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur
)
/
CREATE OR REPLACE TRIGGER AIMembreModifierCatégorie
AFTER INSERT ON Membre
REFERENCING
	NEW AS ligneAprès
FOR EACH ROW
BEGIN
	UPDATE 	Utilisateur
	SET 		catégorieUtilisateur = 'membre'
	WHERE 	idUtilisateur = :ligneAprès.idUtilisateur;
END AIMembreModifierCatégorie ;
/
CREATE OR REPLACE TRIGGER BDUMembreInterdiction
BEFORE DELETE OR UPDATE ON Membre
BEGIN
	raise_application_error(-20201,'DELETE et UPDATE interdit pour Membre');
END BDUMembreInterdiction;
/
CREATE TABLE MembreGénéral
(noSequence 			NUMBER(10)		NOT NULL,
 nbMaxPrêts	 			NUMBER(10)		DEFAULT 5 NOT NULL,
 duréeMaxPrêts			NUMBER(10)		DEFAULT 7 NOT NULL,
 PRIMARY KEY (noSequence)
)
/
CREATE OR REPLACE TRIGGER BDMembreGénéral
BEFORE DELETE ON MembreGénéral
BEGIN
	raise_application_error(-20201,'DELETE interdit pour MembreGénéral');
END BDMembreGénéral;
/
CREATE OR REPLACE TRIGGER BUMembreGénéral
BEFORE UPDATE OF nbMaxPrêts ON MembreGénéral
FOR EACH ROW
WHEN (NEW.nbMaxPrêts < OLD.nbMaxPrêts)
BEGIN
	raise_application_error(-20212,'Interdit de diminuer nbMaxPrêts');
END BUMembreGénéral;
/
CREATE TABLE Editeur
(nomEditeur 			VARCHAR(20)	NOT NULL,
 ville 				VARCHAR(20)	NOT NULL,
 PRIMARY KEY (nomEditeur)
)
/
CREATE TABLE Catégorie
(code					VARCHAR(10)	NOT NULL,
 descripteur 			VARCHAR(20)	NOT NULL,
 codeParent				VARCHAR(10),
 PRIMARY KEY (code),
 FOREIGN KEY (codeParent) REFERENCES Catégorie
)
/
CREATE TABLE Livre
(ISBN 				CHAR(13)		NOT NULL,
 titre 				VARCHAR(50)		NOT NULL,
 annéeParution 			NUMBER(4)		NOT NULL
CHECK(annéeParution > 0),
 nomEditeur 			VARCHAR(20)	NOT NULL,
 code					VARCHAR(10)	NOT NULL,
 PRIMARY KEY (ISBN),
 FOREIGN KEY (nomEditeur) REFERENCES Editeur
 	DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (code) REFERENCES Catégorie
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
	CHECK(statut IN ('prêté', 'disponible','retiré')),
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
		raise_application_error(-20110,'l''éditeur doit avoir au moins un livre');
	WHEN	OTHERS THEN
		raise_application_error(-20105,'erreur interne');
END BIEditeurAuMoinsUnLivre;
/
CREATE TABLE PrêtEnCours
(idExemplaire 			VARCHAR(10)	NOT NULL,
 datePrêt 				DATE	DEFAULT SYSDATE NOT NULL,
 idUtilisateur 			VARCHAR(10)	NOT NULL,
 PRIMARY KEY (idExemplaire),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur,
 FOREIGN KEY (idExemplaire) REFERENCES Exemplaire
)
/
CREATE OR REPLACE TRIGGER BIPrêtEnCoursVérifier
 BEFORE INSERT ON PrêtEnCours
 FOR EACH ROW
DECLARE
	statutExemplaire 		Exemplaire.statut%TYPE;
	idUtilisateurMembre	Membre.idUtilisateur%TYPE;
	datePrêt			PrêtEnCours.datePrêt%TYPE;
	nombrePrêtsEnCours 	INTEGER;
	nombreMaximalPrêts 	INTEGER;
	duréeMaximalePrêts 	INTEGER;
	exemplaireNonDisponible EXCEPTION;
	nombreMaximalAtteint 	EXCEPTION;
	prêtEnRetard 		EXCEPTION;
	-- Curseur pour vérifier si membre
	CURSOR leMembre(unIdUtilisateur PrêtEnCours.idUtilisateur%TYPE)IS
		SELECT idUtilisateur
		FROM Membre WHERE idUtilisateur = unIdUtilisateur;
	-- Curseur (CURSOR) PL/SQL pour itérer sur les prêts
	CURSOR lignesPrêts(unIdUtilisateur PrêtEnCours.idUtilisateur%TYPE)IS
    		SELECT 	datePrêt
    		FROM		PrêtEnCours
    		WHERE 	idUtilisateur = unIdUtilisateur;
BEGIN
	--  Vérifier si statut de l'exemplaire = disponible
	SELECT 	statut
	INTO 		statutExemplaire
	FROM 		Exemplaire
	WHERE 	idExemplaire = :NEW.idExemplaire
	FOR UPDATE; /* pour sérialisabilité*/
	IF statutExemplaire <> 'disponible' THEN
		RAISE exemplaireNonDisponible;
	END IF;
	-- Vérifier si l'emprunteur est un membre
	OPEN leMembre(:NEW.idUtilisateur);
	FETCH leMembre INTO idUtilisateurMembre;
	IF leMembre%FOUND THEN
	-- Vérifier si le nombre maximal d'emprunts est atteint ou si un retard existe
		SELECT	nbMaxPrêts, duréeMaxPrêts
		INTO		nombreMaximalPrêts, duréeMaximalePrêts
		FROM		MembreGénéral;
		LOCK TABLE PrêtEnCours IN SHARE ROW EXCLUSIVE MODE;
		nombrePrêtsEnCours := 0;
		OPEN lignesPrêts(:NEW.idUtilisateur);
		LOOP
			FETCH lignesPrêts INTO datePrêt;
			EXIT WHEN lignesPrêts%NOTFOUND;
			IF (SYSDATE-datePrêt > duréeMaximalePrêts) THEN
				RAISE prêtEnRetard;
			END IF;
			nombrePrêtsEnCours := nombrePrêtsEnCours + 1;
		END LOOP;
		CLOSE lignesPrêts;
		IF nombrePrêtsEnCours >= nombreMaximalPrêts THEN
			RAISE nombreMaximalAtteint;
		END IF;
	END IF;
	CLOSE leMembre;
EXCEPTION
	WHEN exemplaireNonDisponible THEN
		raise_application_error(-20103,'l''exemplaire n''a pas le statut disponible');
	WHEN nombreMaximalAtteint THEN
		raise_application_error(-20101,'le nombre maximal d''emprunts est atteint');
	WHEN prêtEnRetard THEN
		raise_application_error(-20104,'emprunt interdit à cause de retard');
	WHEN	OTHERS THEN
		raise_application_error(-20105,'erreur interne');
END BIPrêtEnCoursVérifier;
/
CREATE OR REPLACE TRIGGER BUPrêtEnCours
BEFORE UPDATE ON PrêtEnCours
BEGIN
	raise_application_error(-20203,'UPDATE interdit pour PrêtEnCours');
END BUPrêtEnCours;
/
CREATE OR REPLACE TRIGGER AIPrêtEnCoursModifStatutEx
AFTER INSERT ON PrêtEnCours
REFERENCING
	NEW AS ligneAprès
FOR EACH ROW
BEGIN
	UPDATE 	Exemplaire
	SET 		statut = 'prêté'
	WHERE 	idExemplaire = :ligneAprès.idExemplaire;
END AIPrêtEnCoursModifStatutEx;
/
-- On utilise le mécanisme de SEQUENCE Oracle pour générer les valeurs de
-- la clé primaire noSequence de la table PrêtArchivé
CREATE SEQUENCE SequenceNoPrêtArchivé
/
CREATE TABLE PrêtArchivé
(noSequence				NUMBER(10)		NOT NULL,
 datePrêt 				DATE			NOT NULL,
 dateRetour 			DATE			NOT NULL,
 idUtilisateur 			VARCHAR(10)		NOT NULL,
 idExemplaire 			VARCHAR(10)		NOT NULL,
 PRIMARY KEY (noSequence),
 FOREIGN KEY (idUtilisateur) REFERENCES Utilisateur,
 FOREIGN KEY (idExemplaire) REFERENCES Exemplaire,
 CHECK (dateRetour >= datePrêt)
)
/
CREATE OR REPLACE TRIGGER ADPrêtEnCours
AFTER DELETE ON PrêtEnCours
FOR EACH ROW
BEGIN
 	UPDATE 	Exemplaire
 	SET 		statut = 'disponible'
 	WHERE 	idExemplaire = :OLD.idExemplaire;

 	INSERT INTO PrêtArchivé VALUES
 		(SequenceNoPrêtArchivé.NEXTVAL, :OLD.datePrêt, SYSDATE,
		:OLD.idUtilisateur,:OLD.idExemplaire);
	-- SequenceNoPrêtArchivé.NEXTVAL retourne la prochaine valeur de la SEQUENCE
END ADPrêtEnCours;
/

CREATE TABLE Auteur
(noSequence				NUMBER(10)		NOT NULL,
 nom	 				VARCHAR(20)		NOT NULL,
 prénom 				VARCHAR(20)		NOT NULL,
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
PROMPT Quelques exemples de manipulations de données
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY'
/
ALTER SESSION SET NLS_DATE_LANGUAGE = ENGLISH
/

INSERT INTO Catégorie VALUES('10','Sciences',NULL)
/
INSERT INTO Catégorie VALUES('20','Philosophie',NULL)
/
INSERT INTO Catégorie VALUES('30','Histoire', NULL)
/
INSERT INTO Catégorie VALUES('40','Arts', NULL)
/
INSERT INTO Catégorie VALUES('50','Littérature', NULL) 
/
INSERT INTO Catégorie VALUES('101','Informatique','10')
/
INSERT INTO Catégorie VALUES('102','Mathématiques','10')
/
INSERT INTO Catégorie VALUES('103','Chimie','10')
/
INSERT INTO Catégorie VALUES('501','Roman','50') 
/
INSERT INTO Catégorie VALUES('502','Poésie','50')
/
COMMIT
/
SELECT * FROM Catégorie
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
INSERT INTO Livre VALUES('0-394-74502-7', 'Gödel, Escher, Bach : An Eternal Golden Braid', 1980, 'Random House', '20')
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

INSERT INTO MembreGénéral VALUES(1, 2, 7)
/
COMMIT
/
SELECT * FROM MembreGénéral
/

INSERT INTO Utilisateur VALUES(1,'cocorico','Marshal', 'Amanda', 'membre')
/
INSERT INTO Membre VALUES(1,'(111)111-1111')
/

INSERT INTO Utilisateur VALUES(2,'cocorico','Degas', 'Edgar', 'membre')
/
INSERT INTO Membre VALUES(2,'(222)222-2222')
/

INSERT INTO Utilisateur VALUES(3,'cocorico','Lecommis', 'Coco', 'employé')
/
INSERT INTO Employé VALUES(3,'LECC01','commis')
/
INSERT INTO Utilisateur VALUES(4,'cocorico','Lecommis', 'Toto', 'employé')
/
INSERT INTO Employé VALUES(4,'LECT01','commis')
/
SELECT * FROM Utilisateur
/
COMMIT
/

PROMPT Editeur sans Livre
INSERT INTO Editeur VALUES ('Eyrolles','Paris')
/
PROMPT Prêt correct
INSERT INTO PrêtEnCours VALUES(1,'20-jul-1999',1)
/
PROMPT cas de retard
INSERT INTO PrêtEnCours VALUES(3,'30-jul-1999',1)
/
PROMPT cas non disponible
INSERT INTO PrêtEnCours VALUES(1,'30-jul-1999',2)
/
DELETE FROM PrêtEnCours WHERE idExemplaire = 1
/
SELECT * FROM PrêtEnCours
/
SELECT * FROM PrêtArchivé
/
PROMPT defaut pour la date de prêt
INSERT INTO PrêtEnCours(idExemplaire, idUtilisateur) VALUES(1,1)
/
INSERT INTO PrêtEnCours(idExemplaire, idUtilisateur) VALUES(3,1)
/
PROMPT cas de maximum atteint (2 dans cet essai)
INSERT INTO PrêtEnCours(idExemplaire, idUtilisateur) VALUES(5,1)
/
SELECT * FROM PrêtEnCours
/
PROMPT maximum dépassé pour Commis
INSERT INTO PrêtEnCours(idExemplaire, idUtilisateur) VALUES(2,3)
/
INSERT INTO PrêtEnCours(idExemplaire, idUtilisateur) VALUES(4,3)
/
INSERT INTO PrêtEnCours(idExemplaire, idUtilisateur) VALUES(5,3)
/

