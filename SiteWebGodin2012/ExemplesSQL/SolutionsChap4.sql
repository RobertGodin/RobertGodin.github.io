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
-- Contenu de la table DétailLivraison
SELECT * FROM DétailLivraison
/
-- a) Les Clients  dont le noTéléphone = (999)999-9999 
SELECT	*
FROM 		Client
WHERE		noTéléphone = '(999)999-9999'
/
-- b) Le noCommande et la dateCommande des Commandes du Client #10
-- dont le noCommande est supérieur à 2.
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
-- d) Le noClient, noTéléphone du Client et noCommande pour les 
-- Commandes faites le 02/06/2000.
SELECT	Client.noClient, noTéléphone, noCommande
FROM 		Client, Commande
WHERE		Client.noCLient = Commande.noClient AND
 		DateCommande = '02/06/2000'
/
-- e) Les noArticles commandés au moins une fois par le Client #10
-- après le 01/06/2000.
SELECT	DISTINCT noArticle
FROM 		Commande, LigneCommande
WHERE		Commande.noCommande = LigneCommande.noCommande AND
 		noClient = 10 AND
 		DateCommande > '1/06/2000'
/
-- Solution avec SELECT imbriqué
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
FROM 		Commande C, DétailLivraison D
WHERE	C.noCommande = D.noCommande AND
 		noClient = 10
/
-- Solution avec SELECT imbriqué
SELECT	DISTINCT noLivraison
 	FROM 		DétailLivraison
 	WHERE		noCommande IN
		(SELECT 	noCommande
		 FROM		Commande
		 WHERE 	noClient = 10)
/
-- g) Les noCommandes des Commandes qui ont été placées 
-- à la même date que la Commande #2.
SELECT	Commande.noCommande
FROM 		Commande, Commande C2
WHERE		Commande.dateCommande = C2.dateCommande AND
 		C2.noCommande = 2
/
-- h) Les noLivraison faites à la même date qu'une des Commandes
--  correspondant à la Livraison.
SELECT	DISTINCT V.noLivraison
FROM 		Commande C, DétailLivraison D, Livraison V
WHERE		C.noCommande = D.noCommande AND
		D.noLivraison = V.noLivraison AND
		C.dateCommande = V.dateLivraison
/
-- i) La liste des noCommande avec les noLivraisons associées 
-- incluant les noCommandes sans livraison.
-- N.B. La solution SQL2 suivante n'est pas supportée par anciennes versions Oracle 
SELECT	DISTINCT noCommande, noLivraison
FROM 		Commande NATURAL LEFT OUTER JOIN DétailLivraison
/
-- Solution avec le dialecte Oracle
SELECT 	DISTINCT C.noCommande, D.noLivraison
FROM		Commande C,DétailLivraison D
WHERE		C.noCommande = D.noCommande (+)
/
-- j) Les noClient, nomClient des Clients qui n'ont pas 
-- placé de Commande au mois de mars de l'année 2000.
SELECT	noClient, nomClient
FROM 		Client
WHERE		NOT EXISTS
 	(SELECT 	*
 	 FROM 	Commande
 	 WHERE 	noClient = Client.noClient AND
 			dateCommande BETWEEN '01/03/2000' AND '31/03/2000')
/
-- solution avec MINUS (N.B. Oracle utilise MINUS plutôt que EXCEPT)
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
-- autre solution pour l) (N.B. Oracle utilise MINUS plutôt que EXCEPT)
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
-- autre solution pour m) (N.B. Oracle utilise MINUS plutôt que EXCEPT)
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
-- n) Les Articles dont la description débute par la lettre " C ".
SELECT	*
FROM 		Article
WHERE		description LIKE 'C%'
/
-- o) Le Clients dont le noTéléphone n'est pas NULL.
SELECT	*
FROM 		Client
WHERE		noTéléphone IS NOT NULL
/
-- p) Les Articles dont le prix est supérieur à la moyenne.
SELECT	*
FROM 		Article
WHERE		prixUnitaire >
	(SELECT AVG(prixUnitaire)
	 FROM Article)
/
-- q) Le montant total de la Commande #1 avant et après la taxe de 15%.
SELECT 	SUM(quantité*prixUnitaire)AS totalCommande,
 		SUM(quantité*prixUnitaire*1.15)AS totalPlusTaxe
FROM 		LigneCommande L, Article A
WHERE		L.noArticle = A.noArticle AND
 		noCommande = 1
/
-- r) Le montant total de la Livraison #100 avant et après la taxe de 15%
SELECT 	SUM(quantitéLivrée*prixUnitaire)AS totalLivraison,
 		SUM(quantitéLivrée*prixUnitaire*1.15)AS totalPlusTaxe
FROM 		DétailLivraison D, Article A
WHERE		D.noArticle = A.noArticle AND
 		noLivraison = 100
/
-- s) La quantité commandée et quantité en attente pour chaque LigneCommande.
-- N.B. La solution SQL2 suivante n'est pas supportée par les anciennes versions d'Oracle
SELECT 	noCommande, noArticle, quantité, 
 	quantité-CASE WHEN SUM(quantitéLivrée) IS NULL THEN 0
				ELSE SUM(quantitéLivrée) END
 	AS quantitéEnAttente
FROM 		LigneCommande NATURAL LEFT OUTER JOIN DétailLivraison
GROUP BY	noCommande, noArticle, quantité

-- Solution avec le dialecte Oracle :
SELECT 	L.noCommande, L.noArticle, quantité, 
 		quantité-NVL(SUM(quantitéLivrée),0) 
 		AS quantitéEnAttente
FROM 		LigneCommande L, DétailLivraison D
WHERE		L.noArticle = D.noArticle (+) AND
		L.noCommande = D.noCommande (+)
GROUP BY	L.noCommande, L.noArticle, quantité
/
-- Ou encore avec DECODE
SELECT 	L.noCommande, L.noArticle, quantité, 
 	quantité-DECODE(SUM(quantitéLivrée),NULL,0,SUM(quantitéLivrée)) 
 	AS quantitéEnAttente
FROM 		LigneCommande L, DétailLivraison D
WHERE		L.noArticle = D.noArticle (+) AND
		L.noCommande = D.noCommande (+)
GROUP BY	L.noCommande, L.noArticle, quantité
/
-- t) La quantité commandée et quantité en attente pour chaque LigneCommande
--  dont la quantité en attente est supérieur à 0.
-- N.B. La solution SQL2 suivante n'est pas supportée par Oracle
SELECT 	noCommande, noArticle, quantité, 
 	quantité-CASE WHEN SUM(quantitéLivrée) IS NULL THEN 0
				ELSE SUM(quantitéLivrée) END
 	AS quantitéEnAttente
FROM 		LigneCommande NATURAL LEFT OUTER JOIN DétailLivraison
GROUP BY	noCommande, noArticle, quantité
HAVING	(quantité-
 		 CASE WHEN SUM(quantitéLivrée) IS NULL THEN 0
				ELSE SUM(quantitéLivrée) END )  > 0
/
-- Solution avec le dialecte Oracle :
SELECT 	L.noCommande, L.noArticle, quantité, 
 		quantité-NVL(SUM(quantitéLivrée),0) 
 		AS quantitéEnAttente
FROM 		LigneCommande L, DétailLivraison D
WHERE		L.noArticle = D.noArticle (+) AND
		L.noCommande = D.noCommande (+)
GROUP BY	L.noCommande, L.noArticle, quantité
HAVING	(quantité-NVL(SUM(quantitéLivrée),0)) > 0
/
-- u) L'article de prix minimum
SELECT	*
FROM 		Article
WHERE		prixUnitaire =
	(SELECT MIN(prixUnitaire)
	 FROM Article)
/
-- v) Les noLivraison des Livraisons effectuées le 4/06/2000 qui contiennent au moins deux DétailLivraison. Le résultat doit être trié par le noLivraison.
SELECT	L.noLivraison
FROM 		Livraison L, DétailLivraison D
WHERE		L.noLivraison = D.noLivraison AND
		dateLivraison = '4/06/2000'
GROUP BY	L.noLivraison
HAVING	count(*) >=2
ORDER BY 	L.noLivraison
/
-- w) Les noArticle avec la quantité totale commandée depuis le 05/07/2000
--  dans le cas où cette quantité dépasse 10.
SELECT	noArticle, SUM(quantité)
FROM 		Commande C, LigneCommande L
WHERE		C.noCommande = L.noCommande AND
 	dateCommande > '5/07/2000'
GROUP BY	noArticle
HAVING	SUM(quantité) >=10
/
-- x) Supprimer les Articles qui n'ont jamais été commandés.
DELETE 	FROM Article
WHERE		NOT EXISTS
	(SELECT *
 	 FROM LigneCommande
 	 WHERE noArticle = Article.noArticle)
/
ROLLBACK
/
-- y) Augmenter le la quantité commandée de 2 unités pour la 
-- Commande #1 et l'Article #10.
UPDATE 	LigneCommande
SET		quantité = quantité + 2
WHERE		noCommande = 1 AND noArticle = 10
/
ROLLBACK
/
-- z) Supprimer le Client # 10 avec toutes les données qui lui sont associées 
--(Commandes, Livraisons, etc.)
-- La solution suivante n'est pas la plus efficace car elle crée une table 
-- intermédiaire pour stocker temporairement les numéros de livraison des 
-- livraisons du client #10. Cette liste pourrait être conservée en mémoire 
-- centrale en utilisant un langage procédural. Dans la solution, on ne 
-- considère pas cette possibilité et tout doit être fait directement en 
-- SQL. 
-- Il est nécessaire de stocker temporairement les numéros de livraison des 
-- livraisons du client #10 car il faut supprimer les DétailLivraisons avant 
-- les Livraisons. Mais après avoir supprimer les DétailLivraisons, il 
-- devient impossible de savoir le numéro du client correspondant à une 
-- Livraison !
-- N.B. On suppose ON DELETE NO ACTION pour les contraintes d'intégrité 
-- référentielles et il faut donc supprimer les DétailLivraison avant la
-- Livraison et avant les LigneCommande qui y correspondent.

CREATE TABLE noLivraisonDuClient1(noLivraison INTEGER PRIMARY KEY)
/
INSERT INTO noLivraisonDuClient1
SELECT 	DISTINCT noLivraison
FROM 		DétailLivraison D, Commande C
WHERE		C.noCommande = D.noCommande AND
		noClient = 10
/
DELETE 	FROM DétailLivraison
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

-- Une autre alternative beaucoup plus performante consiste à créer une
-- procédure SQL qui effectue tout le traitement au niveau du serveur.
-- En plus d'éviter de créer la table temporaire afin de conserver les
-- numéros de livraison du client 10, cette solution améliore la performance
-- en évitant les aller-retours entre le client et le serveur de BD. 
-- Eh effet chacun des énoncés SQL de la solution précédente est exécuté
-- par un appel distinct au serveur de BD. 
-- (voir chap.5, exercice 2)

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
SET SERVEROUTPUT ON
EXECUTE supprimerClient(10)
ROLLBACK
/
-- 2. Exercices supplémentaires 

-- a) Le noClient, son nom, le numéro de téléphone du client, le montant total 
-- commandé pour les articles dispendieux dont le prix unitaire est supérieur à 
-- $20, et le montant total commandé pour les articles à prix modiques dont le 
-- prix unitaire est inférieur à $15 pour les clients qui ont commandé un
-- montant moins élevé d'articles dispendieux que d'articles à prix modique.
SELECT Client.noClient, nomClient, noTéléphone, Dispendieux.total, Modique.total
FROM	Client,
	(SELECT 	noClient, SUM(quantité*prixUnitaire) AS total
	 FROM 	Commande C, LigneCommande L, Article A
	 WHERE	L.noArticle = A.noArticle AND 
			C.noCommande = L.noCommande AND
			prixUnitaire >20 
	 GROUP BY	noClient) Dispendieux,
	(SELECT 	noClient, SUM(quantité*prixUnitaire) AS total
	 FROM 	Commande C, LigneCommande L, Article A
	 WHERE	L.noArticle = A.noArticle AND 
			C.noCommande = L.noCommande AND
			prixUnitaire < 15 
	 GROUP BY	noClient) Modique
WHERE 	Client.noClient = Dispendieux.noClient AND
		Client.noClient = Modique.noClient AND
	 	Dispendieux.total < Modique.total
/
