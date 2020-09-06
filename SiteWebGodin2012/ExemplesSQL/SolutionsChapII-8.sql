SET ECHO ON
-- Script Oracle SQL*plus de création du schéma VentesPleinDeFoin 
-- volume 1 (Godin 2000a)
-- incluant des solutions aux exercices du chapitre 8 du volume II 

-- Création des tables
CREATE TABLE Client
(noClient 		INTEGER 		NOT NULL,
 nomClient 		VARCHAR(20) 	NOT NULL,
 noTéléphone 	VARCHAR(15) 	NOT NULL,
 PRIMARY KEY 	(noClient)
)
/
CREATE TABLE Article
(noArticle 		INTEGER		NOT NULL,
 description 	VARCHAR(20),
 prixUnitaire 	DECIMAL(10,2)	NOT NULL,
 quantitéEnStock	INTEGER		DEFAULT 0 NOT NULL 
 	CHECK (quantitéEnStock >= 0),
 PRIMARY KEY (noArticle))
/
CREATE TABLE Commande
(noCommande 	INTEGER 		NOT NULL,
 dateCommande	DATE			NOT NULL,
 noClient		INTEGER		NOT NULL,
 PRIMARY KEY 	(noCommande),
 FOREIGN KEY 	(noClient) REFERENCES Client
)
/
CREATE TABLE LigneCommande
(noCommande 	INTEGER		NOT NULL,
 noArticle 		INTEGER		NOT NULL,
 quantité 		INTEGER		NOT NULL
	CHECK (quantité > 0),
 PRIMARY KEY (noCommande, noArticle),
 FOREIGN KEY (noCommande) REFERENCES Commande,
 FOREIGN KEY (noArticle) REFERENCES Article
)
/
CREATE TABLE Livraison
(noLivraison 	INTEGER 		NOT NULL,
 dateLivraison	DATE			NOT NULL,
 PRIMARY KEY (noLivraison)
)
/
CREATE TABLE DétailLivraison
(noLivraison 	INTEGER 		NOT NULL,
 noCommande 	INTEGER		NOT NULL,
 noArticle 		INTEGER		NOT NULL,
 quantitéLivrée	INTEGER		NOT NULL
	CHECK (quantitéLivrée > 0),
 PRIMARY KEY (noLivraison, noCommande, noArticle),
 FOREIGN KEY (noLivraison) REFERENCES Livraison,
 FOREIGN KEY (noCommande, noArticle) REFERENCES LigneCommande
)
/

-- Chargement des données de l'exemple du livre (Godin 2000a)
INSERT INTO Client
 	VALUES(10,'Luc Sansom','(999)999-9999')
/
INSERT INTO Client
 	VALUES(20,'Dollard Tremblay','(888)888-8888')
/
INSERT INTO Client
 	VALUES(30,'Lin Bô','(777)777-7777')
/
INSERT INTO Client
 	VALUES(40,'Jean Leconte','(666)666-6666')
/
INSERT INTO Client
 	VALUES(50,'Hafed Alaoui','(555)555-5555')
/
INSERT INTO Client
 	VALUES(60,'Marie Leconte','(666)666-6666')
/
INSERT INTO Client
 	VALUES(70,'Simon Lecoq','(444)444-4419')
/
INSERT INTO Client
 	VALUES(80,'Dollard Tremblay','(333)333-3333')
/
INSERT INTO Article
 	VALUES(10,'Cèdre en boule',10.99,10)
/
INSERT INTO Article
 	VALUES(20,'Sapin',12.99,10)
/
INSERT INTO Article
 	VALUES(40,'Épinette bleue',25.99,10)
/
INSERT INTO Article
 	VALUES(50,'Chêne',22.99,10)
/
INSERT INTO Article
 	VALUES(60,'Érable argenté',15.99,10)
/
INSERT INTO Article
 	VALUES(70,'Herbe à puce',10.99,10)
/
INSERT INTO Article
 	VALUES(80,'Poirier',26.99,10)
/
INSERT INTO Article
 	VALUES(81,'Catalpa',25.99,10)
/
INSERT INTO Article
 	VALUES(90,'Pommier',25.99,10)
/
INSERT INTO Article
 	VALUES(95,'Génévrier',15.99,10)
/
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY'
/
INSERT INTO Commande 
 	VALUES(1,'01/06/2000',10)
/
INSERT INTO Commande 
 	VALUES(2,'02/06/2000',20)
/
INSERT INTO Commande 
 	VALUES(3,'02/06/2000',10)
/
INSERT INTO Commande 
 	VALUES(4,'05/07/2000',10)
/
INSERT INTO Commande 
 	VALUES(5,'09/07/2000',30)
/
INSERT INTO Commande 
 	VALUES(6,'09/07/2000',20)
/
INSERT INTO Commande 
 	VALUES(7,'15/07/2000',40)
/
INSERT INTO Commande 
 	VALUES(8,'15/07/2000',40)
/
INSERT INTO LigneCommande 
 	VALUES(1,10,10)
/
INSERT INTO LigneCommande 
 	VALUES(1,70,5)
/
INSERT INTO LigneCommande 
 	VALUES(1,90,1)
/
INSERT INTO LigneCommande 
 	VALUES(2,40,2)
/
INSERT INTO LigneCommande 
 	VALUES(2,95,3)
/
INSERT INTO LigneCommande 
 	VALUES(3,20,1)
/
INSERT INTO LigneCommande 
 	VALUES(4,40,1)
/
INSERT INTO LigneCommande 
 	VALUES(4,50,1)
/
INSERT INTO LigneCommande 
 	VALUES(5,70,3)
/
INSERT INTO LigneCommande 
 	VALUES(5,10,5)
/
INSERT INTO LigneCommande 
 	VALUES(5,20,5)
/
INSERT INTO LigneCommande 
 	VALUES(6,10,5)
/
INSERT INTO LigneCommande 
 	VALUES(6,40,1)
/
INSERT INTO LigneCommande 
 	VALUES(7,50,1)
/
INSERT INTO LigneCommande 
 	VALUES(7,95,2)
/
INSERT INTO LigneCommande
 	VALUES(8,20,3)
/
INSERT INTO Livraison
 	VALUES(100,'03/06/2000')
/
INSERT INTO Livraison
 	VALUES(101,'04/06/2000')
/
INSERT INTO Livraison
 	VALUES(102,'04/06/2000')
/
INSERT INTO Livraison
 	VALUES(103,'05/06/2000')
/
INSERT INTO Livraison
 	VALUES(104,'07/07/2000')
/
INSERT INTO Livraison
 	VALUES(105,'09/07/2000')
/
INSERT INTO DétailLivraison
 	VALUES(100,1,10,7)
/
INSERT INTO DétailLivraison
 	VALUES(100,1,70,5)
/
INSERT INTO DétailLivraison
 	VALUES(101,1,10,3)
/
INSERT INTO DétailLivraison
 	VALUES(102,2,40,2)
/
INSERT INTO DétailLivraison
 	VALUES(102,2,95,1)
/
INSERT INTO DétailLivraison
 	VALUES(100,3,20,1)
/
INSERT INTO DétailLivraison
 	VALUES(103,1,90,1)
/
INSERT INTO DétailLivraison
 	VALUES(104,4,40,1)
/
INSERT INTO DétailLivraison
 	VALUES(105,5,70,2)
/

-- 1 a) La quantité commandée ne peut être supérieure à 5 pour les
-- Articles dont le noArticle est supérieur à 10000.
-- Ajouter un CHECK sur la table LigneCommande :
ALTER TABLE LigneCommande 
ADD (CONSTRAINT XXX CHECK (noArticle <= 10000 OR quantité <= 5))
/

-- 1 b)Lorsqu'une augmentation du prixUnitaire d'un Article est tentée, 
-- il faut limiter l'augmentation à 10% du prix en cours
CREATE OR REPLACE TRIGGER BUArticleBornerAugPrix
BEFORE UPDATE OF prixUnitaire ON Article
REFERENCING
	OLD AS ligneAvant
	NEW AS ligneAprès
FOR EACH ROW
WHEN (ligneAprès.prixUnitaire > ligneAvant.prixUnitaire*1.1)
BEGIN
	:ligneAprès.prixUnitaire := :ligneAvant.prixUnitaire*1.1;
END;
/
-- Test du TRIGGER BUArticleBornerAugPrix
SELECT * FROM Article WHERE noArticle = 10
/
UPDATE 	Article
SET		prixUnitaire = 15.99
WHERE		noArticle = 10
/
SELECT * FROM Article WHERE noArticle = 10
/

-- 1 c)Lors d'une nouvelle livraison, la quantité à livrer ne peut dépasser
-- la quantité en stock disponible
CREATE OR REPLACE TRIGGER BIDétLivVérifierStock
BEFORE INSERT ON DétailLivraison
REFERENCING
	NEW AS ligneAprès
FOR EACH ROW
DECLARE
	laQuantitéEnStock	INTEGER;
-- N.B. Oracle ne supporte pas de SELECT dans le WHEN
-- Il faut donc utiliser un IF PL/SQL
BEGIN
	SELECT 	quantitéEnStock
	INTO 		laQuantitéEnStock
	FROM		Article
	WHERE 	noArticle = :ligneAprès.noArticle
	FOR UPDATE;

	IF :ligneAprès.quantitéLivrée > laQuantitéEnStock THEN
		raise_application_error(-20100, 'stock disponible insuffisant');
	END IF;
END;
/
-- Test du TRIGGER BIDétLivVérifierStock
SELECT * FROM Article WHERE noArticle = 10
/
INSERT INTO DétailLivraison
 	VALUES(105,5,10,30)
/
-- 1 d) Ne permettre que la modification de la quantitéLivrée 
-- dans la table DétailLivraison
CREATE OR REPLACE TRIGGER BUDétLivEmpêcherModif
BEFORE UPDATE OF noLivraison, noCommande, noArticle 
       ON DétailLivraison
BEGIN
	raise_application_error(-20101, 'Cette modification est interdite dans DétailLivraison');
END;
/
-- Test du TRIGGER BUDétLivEmpêcherModif
UPDATE 	DétailLivraison
SET		noArticle = 20
WHERE		noArticle = 10 AND noLivraison = 100 AND noCommande = 1
/

-- 1 e) Ajuster la quantitéEnStock dans le cas de l'insertion d'une 
-- nouvelle ligne dans DétailLivraison
CREATE OR REPLACE TRIGGER AIDétLivAjusterStock
AFTER INSERT ON DétailLivraison
REFERENCING
	NEW AS ligneAprès
FOR EACH ROW
BEGIN
	UPDATE Article
	SET quantitéEnStock = quantitéEnStock - :ligneAprès.quantitéLivrée
	WHERE noArticle = :ligneAprès.noArticle;
END;
/
-- Test du TRIGGER AIDétLivAjusterStock
SELECT * FROM Article WHERE noArticle = 10
/
INSERT INTO DétailLivraison
 	VALUES(105,5,10,5)
/
SELECT * FROM Article WHERE noArticle = 10
/

-- 1 f) Dans le cas d'une modification, il faut tenir compte de la différence entre 
--l'ancienne valeur et la nouvelle valeur de quantitéEnStock.
CREATE OR REPLACE TRIGGER AUDétLivAjusterStock
AFTER UPDATE OF quantitéLivrée ON DétailLivraison
REFERENCING
	OLD AS ligneAvant
	NEW AS ligneAprès
FOR EACH ROW
BEGIN
	UPDATE Article
	SET quantitéEnStock = quantitéEnStock -
	 (:ligneAprès.quantitéLivrée-:ligneAvant.quantitéLivrée)
	WHERE noArticle = :ligneAvant.noArticle;
END;
/
-- Test du TRIGGER AIDétLivAjusterStock
SELECT * FROM Article WHERE noArticle = 10
/
SELECT * FROM DétailLivraison WHERE noLivraison = 105
/
UPDATE 	DétailLivraison
SET		quantitéLivrée = 3
WHERE		noLivraison = 105 AND noCommande = 5 AND noArticle = 10
/
SELECT * FROM Article WHERE noArticle = 10
/
SELECT * FROM DétailLivraison WHERE noLivraison = 105
/

-- h) Le prixUnitaire d'un Article ne peut diminuer.
CREATE OR REPLACE TRIGGER prixNePeutDiminuer
BEFORE UPDATE OF prixUnitaire ON Article
FOR EACH ROW 
WHEN (OLD.prixUnitaire > NEW.prixUnitaire)
BEGIN
raise_application_error(-20100, 'le prix d''un produit ne peut diminuer');
END;
/
-- Test du TRIGGER prixNePeutDiminuer
UPDATE	Article
SET		prixUnitaire = prixUnitaire - 5
WHERE		noArticle = 10
/


-- 1 n) Une Livraison ne touche toujours qu'un seul Client, c'est-à-dire
--  ne peut être liée à des Commandes de plusieurs Clients.
-- On ne traite ici que le cas de l'insertion d'un DétailLivraison
CREATE OR REPLACE TRIGGER BIDetLivMemeClient
BEFORE INSERT ON DétailLivraison
REFERENCING
	OLD AS ligneAvant
	NEW AS ligneAprès
FOR EACH ROW
DECLARE
	leNouveauNoClient	INTEGER;
	leNoClient		INTEGER;
	CURSOR curseurLesNoClient(leNoLivraison DétailLivraison.noLivraison%TYPE)IS
		SELECT DISTINCT noClient
		FROM DétailLivraison D, Commande C
		WHERE C.noCommande = D.noCommande AND
			D.noLivraison = leNoLivraison;
BEGIN
	LOCK TABLE Commande IN SHARE MODE;
	LOCK TABLE DétailLivraison IN SHARE MODE;
	OPEN curseurLesNoClient(:ligneAprès.noLivraison);
	FETCH curseurLesNoClient INTO leNoClient;
	IF curseurLesNoClient%FOUND THEN
		CLOSE curseurLesNoClient;
		SELECT noClient
		INTO leNouveauNoClient
		FROM Commande C
		WHERE C.noCommande = :ligneAprès.noCommande;
		IF leNoClient <> leNouveauNoClient THEN
			raise_application_error(-20100, 'pas le même client pour les commandes');
		END IF;
	ELSE
		CLOSE curseurLesNoClient;
	END IF;
END;

/
-- Test du TRIGGER BIDetLivMemeClient
SELECT * FROM DétailLivraison WHERE noLivraison = 100
/
INSERT INTO DétailLivraison
 	VALUES(100,7,50,1)
/

-- N.B. Le TRIGGER suivant ne fait pas l'affaire car le SELECT ne voit pas
-- l'insertion en cours dans le contexte d'Oracle sous le mode de contrôle
-- de concurrence par défaut! Il va donc laisser passer
-- une première insertion fautive (mais pas la deuxième).
CREATE OR REPLACE TRIGGER BIDetLivMemeClient
BEFORE INSERT ON DétailLivraison
REFERENCING
	OLD AS ligneAvant
	NEW AS ligneAprès
FOR EACH ROW
DECLARE
	nombreClient	INTEGER;
	leNoClient		INTEGER;
BEGIN
	LOCK TABLE Commande IN SHARE MODE;
	LOCK TABLE DétailLivraison IN SHARE MODE;
	SELECT COUNT(DISTINCT noClient)
	INTO nombreClient
	FROM DétailLivraison D, Commande C
	WHERE C.noCommande = D.noCommande AND
		noLivraison = :ligneAprès.noLivraison;
	IF nombreClient > 1 THEN
		raise_application_error(-20100, 'pas le même client pour les commandes');
	END IF;
END;
/


-- 2 Produisez une procédure PL/SQL qui permet de supprimer le client et toutes
-- ses données en un appel et sans créer de table. Le numéro du client à 
-- supprimer sera un paramètre d'entrée de la procédure.

CREATE OR REPLACE PROCEDURE supprimerClient
(unNoClient 		Client.noClient%TYPE) IS
	noLivraisonASupprimer	Livraison.noLivraison%TYPE;
	noCommandeASupprimer	Commande.noCommande%TYPE;

	-- Déclaration d'un curseur (CURSOR) PL/SQL pour itérer sur les numéros
	-- des livraisons du client à supprimer
	CURSOR lesNoLivraisonsASupprimer(leNoClient Client.noClient%TYPE)IS
		SELECT 	DISTINCT noLivraison
		FROM 		DétailLivraison D, Commande C
		WHERE		C.noCommande = D.noCommande AND
				noClient = leNoClient;
	-- Déclaration d'un curseur (CURSOR) PL/SQL pour itérer sur les numéros
	-- des commandes du client à supprimer
	CURSOR lesNoCommandesASupprimer(leNoClient Client.noClient%TYPE)IS
		SELECT 	noCommande
		FROM 		Commande C
		WHERE		noClient = leNoClient
		FOR UPDATE;
BEGIN
	DBMS_OUTPUT.PUT('Suppression du client #:');
	DBMS_OUTPUT.PUT_LINE(unNoClient);

	LOCK TABLE Livraison IN SHARE UPDATE MODE; -- évite les fantomes

	OPEN lesNoLivraisonsASupprimer(unNoClient);
	-- Le OPEN ouvre le CURSOR en lui passant les paramètres

	LOOP
		FETCH lesNoLivraisonsASupprimer INTO noLivraisonASupprimer;
		-- Le FETCH retourne la ligne suivante

		EXIT WHEN lesNoLivraisonsASupprimer%NOTFOUND;
		-- %NOTFOUND est un attribut du CURSOR qui permet de déterminer
		-- si le FETCH a atteint la fin de la table 

		DBMS_OUTPUT.PUT('noLivraison à supprimer :');
		DBMS_OUTPUT.PUT_LINE(noLivraisonASupprimer);
		DELETE 	FROM DétailLivraison
		WHERE		noLivraison = noLivraisonASupprimer;
		DELETE 	FROM Livraison
		WHERE		noLivraison = noLivraisonASupprimer;
	END LOOP;

	CLOSE lesNoLivraisonsASupprimer;
	-- Le CLOSE ferme le CURSOR

	LOCK TABLE Commande IN SHARE UPDATE MODE; -- évite les fantomes

	OPEN lesNoCommandesASupprimer(unNoClient);
	-- Le OPEN ouvre le CURSOR en lui passant les paramètres

	LOOP
		FETCH lesNoCommandesASupprimer INTO noCommandeASupprimer;
		-- Le FETCH retourne la ligne suivante

		EXIT WHEN lesNoCommandesASupprimer%NOTFOUND;
		-- %NOTFOUND est un attribut du CURSOR qui permet de déterminer
		-- si le FETCH a atteint la fin de la table 

		DBMS_OUTPUT.PUT('noCommande à supprimer :');
		DBMS_OUTPUT.PUT_LINE(noCommandeASupprimer);
		DELETE 	FROM 	LigneCommande
		WHERE		noCommande = noCommandeASupprimer;
		DELETE 	Commande
		WHERE		CURRENT OF lesNoCommandesASupprimer;
	END LOOP;

	CLOSE lesNoCommandesASupprimer;
	-- Le CLOSE ferme le CURSOR

	DELETE FROM Client WHERE noClient = unNoClient;

EXCEPTION
	WHEN	OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001,'erreur interne à la procédure PL/SQL');
END supprimerClient;
/
-- Test de la procédure
SET SERVEROUTPUT ON
EXECUTE supprimerClient(10)
ROLLBACK
/

