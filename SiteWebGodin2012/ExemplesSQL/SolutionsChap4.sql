-- Solutions aux exercices du chapitre 4 sous forme de script SQL*plus
-- N.B. Certaines solutions SQL2 ne sont pas compatibles avec des anciennes versions 
-- du dialecte Oracle !

-- Contenu de la table Client
SELECT * FROM Client
/
-- Contenu de la table Commande
SELECT * FROM Commande
/
-- Contenu de la table LigneCommande
SELECT * FROM LigneCommande
/
-- Contenu de la table Article
SELECT * FROM Article
/
-- Contenu de la table Livraison
SELECT * FROM Livraison
/
-- Contenu de la table D�tailLivraison
SELECT * FROM D�tailLivraison
/
-- a) Les Clients  dont le noT�l�phone = (999)999-9999 
SELECT	*
FROM 		Client
WHERE		noT�l�phone = '(999)999-9999'
/
-- b) Le noCommande et la dateCommande des Commandes du Client #10
-- dont le noCommande est sup�rieur � 2.
SELECT	noCommande, dateCommande
FROM 		Commande
WHERE		noClient = 10 AND noCommande > 2 
/
-- c) Les noArticle et description des Articles dont le prixUnitaire
-- est entre $10 et $20.
SELECT	noArticle, description
FROM 		Article
WHERE		prixUnitaire BETWEEN 10 AND 20 
/
-- autre solution pour c)
SELECT	noArticle, description
FROM 		Article
WHERE		prixUnitaire >= 10 AND prixUnitaire <= 20
/
-- d) Le noClient, noT�l�phone du Client et noCommande pour les 
-- Commandes faites le 02/06/2000.
SELECT	Client.noClient, noT�l�phone, noCommande
FROM 		Client, Commande
WHERE		Client.noCLient = Commande.noClient AND
 		DateCommande = '02/06/2000'
/
-- e) Les noArticles command�s au moins une fois par le Client #10
-- apr�s le 01/06/2000.
SELECT	DISTINCT noArticle
FROM 		Commande, LigneCommande
WHERE		Commande.noCommande = LigneCommande.noCommande AND
 		noClient = 10 AND
 		DateCommande > '1/06/2000'
/
-- Solution avec SELECT imbriqu�
SELECT	DISTINCT noArticle
FROM 		LigneCommande
WHERE		noCommande IN
	(SELECT 	noCommande 
	 FROM		Commande
 	 WHERE 	noClient = 10 AND
 			DateCommande > '1/06/2000')
/
-- f) Les noLivraisons correspondant aux Commandes faites par le Client #10.
SELECT	DISTINCT noLivraison
FROM 		Commande C, D�tailLivraison D
WHERE	C.noCommande = D.noCommande AND
 		noClient = 10
/
-- Solution avec SELECT imbriqu�
SELECT	DISTINCT noLivraison
 	FROM 		D�tailLivraison
 	WHERE		noCommande IN
		(SELECT 	noCommande
		 FROM		Commande
		 WHERE 	noClient = 10)
/
-- g) Les noCommandes des Commandes qui ont �t� plac�es 
-- � la m�me date que la Commande #2.
SELECT	Commande.noCommande
FROM 		Commande, Commande C2
WHERE		Commande.dateCommande = C2.dateCommande AND
 		C2.noCommande = 2
/
-- h) Les noLivraison faites � la m�me date qu'une des Commandes
--  correspondant � la Livraison.
SELECT	DISTINCT V.noLivraison
FROM 		Commande C, D�tailLivraison D, Livraison V
WHERE		C.noCommande = D.noCommande AND
		D.noLivraison = V.noLivraison AND
		C.dateCommande = V.dateLivraison
/
-- i) La liste des noCommande avec les noLivraisons associ�es 
-- incluant les noCommandes sans livraison.
-- N.B. La solution SQL2 suivante n'est pas support�e par anciennes versions Oracle 
SELECT	DISTINCT noCommande, noLivraison
FROM 		Commande NATURAL LEFT OUTER JOIN D�tailLivraison
/
-- Solution avec le dialecte Oracle
SELECT 	DISTINCT C.noCommande, D.noLivraison
FROM		Commande C,D�tailLivraison D
WHERE		C.noCommande = D.noCommande (+)
/
-- j) Les noClient, nomClient des Clients qui n'ont pas 
-- plac� de Commande au mois de mars de l'ann�e 2000.
SELECT	noClient, nomClient
FROM 		Client
WHERE		NOT EXISTS
 	(SELECT 	*
 	 FROM 	Commande
 	 WHERE 	noClient = Client.noClient AND
 			dateCommande BETWEEN '01/03/2000' AND '31/03/2000')
/
-- solution avec MINUS (N.B. Oracle utilise MINUS plut�t que EXCEPT)
(SELECT	noClient, nomClient
 FROM 	Client)
MINUS
(SELECT	Client.noClient, nomClient
 FROM 	Client, Commande
 WHERE 	Commande. noClient = Client.noClient AND
 		dateCommande BETWEEN '01/03/2000' AND '31/03/2000')
/
-- k) Les noCommandes qui ne contiennent pas l'Article # 10.
SELECT	noCommande
FROM 		Commande
WHERE		NOT EXISTS
 	(SELECT 	*
 	 FROM 	LigneCommande
 	 WHERE 	Commande.noCommande = noCommande AND
 			noArticle =10)
/
-- l) Les noArticle qui apparaissent dans toutes les Commandes.
SELECT 	noArticle
FROM		Article
WHERE		NOT EXISTS
    	(SELECT 	noCommande
      FROM		Commande
      WHERE NOT EXISTS
     		(SELECT 	*
      	 FROM		LigneCommande
      	 WHERE	noArticle = Article.noArticle AND
				noCommande = Commande.noCommande))
/
-- autre solution pour l) (N.B. Oracle utilise MINUS plut�t que EXCEPT)
SELECT 	noArticle
FROM		Article
WHERE		NOT EXISTS
    ((SELECT 	noCommande
      FROM		Commande
     )
       MINUS
     (SELECT 	noCommande
      FROM		LigneCommande
      WHERE	noArticle = Article.noArticle
     )
    )
/
-- m) Les noArticles qui apparaissent dans toutes les 
-- Commandes du Client #20.
SELECT 	noArticle
FROM		Article
WHERE		NOT EXISTS
    	(SELECT 	noCommande
      FROM		Commande
 	 WHERE	noClient = 20 AND NOT EXISTS
     		(SELECT 	*
      	 FROM		LigneCommande
      	 WHERE	noArticle = Article.noArticle AND
				noCommande = Commande.noCommande))
/
-- autre solution pour m) (N.B. Oracle utilise MINUS plut�t que EXCEPT)
SELECT 	noArticle
FROM		Article
WHERE		NOT EXISTS
    ((SELECT 	noCommande
      FROM		Commande
      WHERE	noClient = 20
     )
       MINUS
     (SELECT 	C.noCommande
      FROM		Commande C, LigneCommande L
      WHERE	noArticle = Article.noArticle AND
      		C.noCommande = L.noCommande AND
			noClient = 20))
/
-- n) Les Articles dont la description d�bute par la lettre " C ".
SELECT	*
FROM 		Article
WHERE		description LIKE 'C%'
/
-- o) Le Clients dont le noT�l�phone n'est pas NULL.
SELECT	*
FROM 		Client
WHERE		noT�l�phone IS NOT NULL
/
-- p) Les Articles dont le prix est sup�rieur � la moyenne.
SELECT	*
FROM 		Article
WHERE		prixUnitaire >
	(SELECT AVG(prixUnitaire)
	 FROM Article)
/
-- q) Le montant total de la Commande #1 avant et apr�s la taxe de 15%.
SELECT 	SUM(quantit�*prixUnitaire)AS totalCommande,
 		SUM(quantit�*prixUnitaire*1.15)AS totalPlusTaxe
FROM 		LigneCommande L, Article A
WHERE		L.noArticle = A.noArticle AND
 		noCommande = 1
/
-- r) Le montant total de la Livraison #100 avant et apr�s la taxe de 15%
SELECT 	SUM(quantit�Livr�e*prixUnitaire)AS totalLivraison,
 		SUM(quantit�Livr�e*prixUnitaire*1.15)AS totalPlusTaxe
FROM 		D�tailLivraison D, Article A
WHERE		D.noArticle = A.noArticle AND
 		noLivraison = 100
/
-- s) La quantit� command�e et quantit� en attente pour chaque LigneCommande.
-- N.B. La solution SQL2 suivante n'est pas support�e par les anciennes versions d'Oracle
SELECT 	noCommande, noArticle, quantit�, 
 	quantit�-CASE WHEN SUM(quantit�Livr�e) IS NULL THEN 0
				ELSE SUM(quantit�Livr�e) END
 	AS quantit�EnAttente
FROM 		LigneCommande NATURAL LEFT OUTER JOIN D�tailLivraison
GROUP BY	noCommande, noArticle, quantit�

-- Solution avec le dialecte Oracle :
SELECT 	L.noCommande, L.noArticle, quantit�, 
 		quantit�-NVL(SUM(quantit�Livr�e),0) 
 		AS quantit�EnAttente
FROM 		LigneCommande L, D�tailLivraison D
WHERE		L.noArticle = D.noArticle (+) AND
		L.noCommande = D.noCommande (+)
GROUP BY	L.noCommande, L.noArticle, quantit�
/
-- Ou encore avec DECODE
SELECT 	L.noCommande, L.noArticle, quantit�, 
 	quantit�-DECODE(SUM(quantit�Livr�e),NULL,0,SUM(quantit�Livr�e)) 
 	AS quantit�EnAttente
FROM 		LigneCommande L, D�tailLivraison D
WHERE		L.noArticle = D.noArticle (+) AND
		L.noCommande = D.noCommande (+)
GROUP BY	L.noCommande, L.noArticle, quantit�
/
-- t) La quantit� command�e et quantit� en attente pour chaque LigneCommande
--  dont la quantit� en attente est sup�rieur � 0.
-- N.B. La solution SQL2 suivante n'est pas support�e par Oracle
SELECT 	noCommande, noArticle, quantit�, 
 	quantit�-CASE WHEN SUM(quantit�Livr�e) IS NULL THEN 0
				ELSE SUM(quantit�Livr�e) END
 	AS quantit�EnAttente
FROM 		LigneCommande NATURAL LEFT OUTER JOIN D�tailLivraison
GROUP BY	noCommande, noArticle, quantit�
HAVING	(quantit�-
 		 CASE WHEN SUM(quantit�Livr�e) IS NULL THEN 0
				ELSE SUM(quantit�Livr�e) END )  > 0
/
-- Solution avec le dialecte Oracle :
SELECT 	L.noCommande, L.noArticle, quantit�, 
 		quantit�-NVL(SUM(quantit�Livr�e),0) 
 		AS quantit�EnAttente
FROM 		LigneCommande L, D�tailLivraison D
WHERE		L.noArticle = D.noArticle (+) AND
		L.noCommande = D.noCommande (+)
GROUP BY	L.noCommande, L.noArticle, quantit�
HAVING	(quantit�-NVL(SUM(quantit�Livr�e),0)) > 0
/
-- u) L'article de prix minimum
SELECT	*
FROM 		Article
WHERE		prixUnitaire =
	(SELECT MIN(prixUnitaire)
	 FROM Article)
/
-- v) Les noLivraison des Livraisons effectu�es le 4/06/2000 qui contiennent au moins deux D�tailLivraison. Le r�sultat doit �tre tri� par le noLivraison.
SELECT	L.noLivraison
FROM 		Livraison L, D�tailLivraison D
WHERE		L.noLivraison = D.noLivraison AND
		dateLivraison = '4/06/2000'
GROUP BY	L.noLivraison
HAVING	count(*) >=2
ORDER BY 	L.noLivraison
/
-- w) Les noArticle avec la quantit� totale command�e depuis le 05/07/2000
--  dans le cas o� cette quantit� d�passe 10.
SELECT	noArticle, SUM(quantit�)
FROM 		Commande C, LigneCommande L
WHERE		C.noCommande = L.noCommande AND
 	dateCommande > '5/07/2000'
GROUP BY	noArticle
HAVING	SUM(quantit�) >=10
/
-- x) Supprimer les Articles qui n'ont jamais �t� command�s.
DELETE 	FROM Article
WHERE		NOT EXISTS
	(SELECT *
 	 FROM LigneCommande
 	 WHERE noArticle = Article.noArticle)
/
ROLLBACK
/
-- y) Augmenter le la quantit� command�e de 2 unit�s pour la 
-- Commande #1 et l'Article #10.
UPDATE 	LigneCommande
SET		quantit� = quantit� + 2
WHERE		noCommande = 1 AND noArticle = 10
/
ROLLBACK
/
-- z) Supprimer le Client # 10 avec toutes les donn�es qui lui sont associ�es 
--(Commandes, Livraisons, etc.)
-- La solution suivante n'est pas la plus efficace car elle cr�e une table 
-- interm�diaire pour stocker temporairement les num�ros de livraison des 
-- livraisons du client #10. Cette liste pourrait �tre conserv�e en m�moire 
-- centrale en utilisant un langage proc�dural. Dans la solution, on ne 
-- consid�re pas cette possibilit� et tout doit �tre fait directement en 
-- SQL. 
-- Il est n�cessaire de stocker temporairement les num�ros de livraison des 
-- livraisons du client #10 car il faut supprimer les D�tailLivraisons avant 
-- les Livraisons. Mais apr�s avoir supprimer les D�tailLivraisons, il 
-- devient impossible de savoir le num�ro du client correspondant � une 
-- Livraison !
-- N.B. On suppose ON DELETE NO ACTION pour les contraintes d'int�grit� 
-- r�f�rentielles et il faut donc supprimer les D�tailLivraison avant la
-- Livraison et avant les LigneCommande qui y correspondent.

CREATE TABLE noLivraisonDuClient1(noLivraison INTEGER PRIMARY KEY)
/
INSERT INTO noLivraisonDuClient1
SELECT 	DISTINCT noLivraison
FROM 		D�tailLivraison D, Commande C
WHERE		C.noCommande = D.noCommande AND
		noClient = 10
/
DELETE 	FROM D�tailLivraison
WHERE		noLivraison IN
(SELECT * FROM noLivraisonDuClient1)
/
DELETE FROM Livraison
WHERE		noLivraison IN 
(SELECT * FROM noLivraisonDuClient1)
/
DELETE 	FROM LigneCommande
WHERE		noCommande IN 
	(SELECT 	noCommande
	 FROM 	Commande
	 WHERE 	noCLient = 10)
/
DELETE 	FROM Commande
WHERE		noCLient = 10
/
DELETE 	FROM Client
WHERE		noCLient = 10
/
ROLLBACK
/
DROP TABLE noLivraisonDuClient1
/

-- Une autre alternative beaucoup plus performante consiste � cr�er une
-- proc�dure SQL qui effectue tout le traitement au niveau du serveur.
-- En plus d'�viter de cr�er la table temporaire afin de conserver les
-- num�ros de livraison du client 10, cette solution am�liore la performance
-- en �vitant les aller-retours entre le client et le serveur de BD. 
-- Eh effet chacun des �nonc�s SQL de la solution pr�c�dente est ex�cut�
-- par un appel distinct au serveur de BD. 
-- (voir chap.5, exercice 2)

CREATE OR REPLACE PROCEDURE supprimerClient
(unNoClient 		Client.noClient%TYPE) IS
	noLivraisonASupprimer	Livraison.noLivraison%TYPE;
	noCommandeASupprimer	Commande.noCommande%TYPE;

	-- D�claration d'un curseur (CURSOR) PL/SQL pour it�rer sur les num�ros
	-- des livraisons du client � supprimer
	CURSOR lesNoLivraisonsASupprimer(leNoClient Client.noClient%TYPE)IS
		SELECT 	DISTINCT noLivraison
		FROM 		D�tailLivraison D, Commande C
		WHERE		C.noCommande = D.noCommande AND
				noClient = leNoClient;
	-- D�claration d'un curseur (CURSOR) PL/SQL pour it�rer sur les num�ros
	-- des commandes du client � supprimer
	CURSOR lesNoCommandesASupprimer(leNoClient Client.noClient%TYPE)IS
		SELECT 	noCommande
		FROM 		Commande C
		WHERE		noClient = leNoClient
		FOR UPDATE;
BEGIN
	DBMS_OUTPUT.PUT('Suppression du client #:');
	DBMS_OUTPUT.PUT_LINE(unNoClient);

	LOCK TABLE Livraison IN SHARE UPDATE MODE; -- �vite les fantomes

	OPEN lesNoLivraisonsASupprimer(unNoClient);
	-- Le OPEN ouvre le CURSOR en lui passant les param�tres

	LOOP
		FETCH lesNoLivraisonsASupprimer INTO noLivraisonASupprimer;
		-- Le FETCH retourne la ligne suivante

		EXIT WHEN lesNoLivraisonsASupprimer%NOTFOUND;
		-- %NOTFOUND est un attribut du CURSOR qui permet de d�terminer
		-- si le FETCH a atteint la fin de la table 

		DBMS_OUTPUT.PUT('noLivraison � supprimer :');
		DBMS_OUTPUT.PUT_LINE(noLivraisonASupprimer);
		DELETE 	FROM D�tailLivraison
		WHERE		noLivraison = noLivraisonASupprimer;
		DELETE 	FROM Livraison
		WHERE		noLivraison = noLivraisonASupprimer;
	END LOOP;

	CLOSE lesNoLivraisonsASupprimer;
	-- Le CLOSE ferme le CURSOR

	LOCK TABLE Commande IN SHARE UPDATE MODE; -- �vite les fantomes

	OPEN lesNoCommandesASupprimer(unNoClient);
	-- Le OPEN ouvre le CURSOR en lui passant les param�tres

	LOOP
		FETCH lesNoCommandesASupprimer INTO noCommandeASupprimer;
		-- Le FETCH retourne la ligne suivante

		EXIT WHEN lesNoCommandesASupprimer%NOTFOUND;
		-- %NOTFOUND est un attribut du CURSOR qui permet de d�terminer
		-- si le FETCH a atteint la fin de la table 

		DBMS_OUTPUT.PUT('noCommande � supprimer :');
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
		RAISE_APPLICATION_ERROR(-20001,'erreur interne � la proc�dure PL/SQL');
END supprimerClient;
/
SET SERVEROUTPUT ON
EXECUTE supprimerClient(10)
ROLLBACK
/
-- 2. Exercices suppl�mentaires 

-- a) Le noClient, son nom, le num�ro de t�l�phone du client, le montant total 
-- command� pour les articles dispendieux dont le prix unitaire est sup�rieur � 
-- $20, et le montant total command� pour les articles � prix modiques dont le 
-- prix unitaire est inf�rieur � $15 pour les clients qui ont command� un
-- montant moins �lev� d'articles dispendieux que d'articles � prix modique.
SELECT Client.noClient, nomClient, noT�l�phone, Dispendieux.total, Modique.total
FROM	Client,
	(SELECT 	noClient, SUM(quantit�*prixUnitaire) AS total
	 FROM 	Commande C, LigneCommande L, Article A
	 WHERE	L.noArticle = A.noArticle AND 
			C.noCommande = L.noCommande AND
			prixUnitaire >20 
	 GROUP BY	noClient) Dispendieux,
	(SELECT 	noClient, SUM(quantit�*prixUnitaire) AS total
	 FROM 	Commande C, LigneCommande L, Article A
	 WHERE	L.noArticle = A.noArticle AND 
			C.noCommande = L.noCommande AND
			prixUnitaire < 15 
	 GROUP BY	noClient) Modique
WHERE 	Client.noClient = Dispendieux.noClient AND
		Client.noClient = Modique.noClient AND
	 	Dispendieux.total < Modique.total
/
