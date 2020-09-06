CREATE OR REPLACE PROCEDURE pStatutCommande 
(leNoCommande	Commande.noCommande%TYPE ) IS

	-- Déclaration de variables
leNoClient			Client.noClient%TYPE;
	laDateCommande		Commande.dateCommande%TYPE ;
	leNoArticle			Article.noArticle%TYPE ;
laQuantitéCommandée	LigneCommande.quantité%TYPE ;
laQuantitéLivrée		INTEGER;
laQuantitéEnAttente	INTEGER;

	-- Déclaration d'un curseur (CURSOR) PL/SQL pour itérer sur les lignes
	-- de la commande
	CURSOR lignesCommande(unNoCommande Commande.noCommande%TYPE)IS
    		SELECT 	noArticle, quantité
    		FROM		LigneCommande
    		WHERE 		LigneCommande.noCommande = unNoCommande ;

BEGIN
DBMS_OUTPUT.PUT_LINE('Commande #:'||TO_CHAR(leNoCommande));

	SELECT		noClient, dateCommande
	INTO		leNoClient, laDateCommande
	FROM		Commande
WHERE		noCommande = leNoCommande;

DBMS_OUTPUT.PUT_LINE('noClient:'||TO_CHAR(leNoClient));
DBMS_OUTPUT.PUT_LINE('dateCommande:'||TO_CHAR(laDateCommande));

	OPEN lignesCommande(leNoCommande);
	-- Le OPEN ouvre le CURSOR en lui passant les paramètres
	LOOP
		FETCH lignesCommande INTO leNoArticle, laQuantitéCommandée;
		-- Le FETCH retourne la ligne suivante

		EXIT WHEN lignesCommande%NOTFOUND;
		-- %NOTFOUND est un attribut du CURSOR qui permet de déterminer
		-- si le FETCH a atteint la fin de la table 
		DBMS_OUTPUT.PUT('noArticle :');
		DBMS_OUTPUT.PUT(leNoArticle);
		DBMS_OUTPUT.PUT(' quantité commandée:');
		DBMS_OUTPUT.PUT(laQuantitéCommandée);

		-- Chercher la quantité déjà livrée
		SELECT		SUM(quantitéLivrée)
		INTO		laQuantitéLivrée
		FROM		DétailLivraison
		WHERE 		noArticle = leNoArticle AND
				noCommande = leNoCommande ;

		IF (laQuantitéLivrée IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE(' livraison en attente');
		ELSE
			laQuantitéEnAttente:= laQuantitéCommandée -laQuantitéLivrée;
			IF (laQuantitéEnAttente = 0) THEN
				DBMS_OUTPUT.PUT_LINE(' livraison complétée');
			ELSE
				DBMS_OUTPUT.PUT (' quantité en attente :');
				DBMS_OUTPUT.PUT_LINE(laQuantitéEnAttente);
			END IF ;
		END IF ;
	END LOOP;
	-- Le CLOSE ferme le CURSOR	CLOSE lignesCommande;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Numéro de commande inexistant');
	WHEN	OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001,'Exception levée par la procédure');
END pStatutCommande;
/
SET SERVEROUTPUT ON
/
EXECUTE pStatutCommande(2)
/
CREATE OR REPLACE PROCEDURE pStatutCommande 
(leNoCommande	Commande.noCommande%TYPE ) IS

	-- Déclaration de variables
leNoClient			Client.noClient%TYPE;
	laDateCommande		Commande.dateCommande%TYPE ;
laQuantitéLivrée		INTEGER;
laQuantitéEnAttente	INTEGER;

	-- Déclaration d'un curseur (CURSOR) PL/SQL pour itérer sur les lignes
	-- de la commande
	CURSOR lignesCommande(unNoCommande Commande.noCommande%TYPE)IS
    		SELECT 	noArticle, quantité
    		FROM		LigneCommande
    		WHERE 		LigneCommande.noCommande = unNoCommande ;

BEGIN
DBMS_OUTPUT.PUT_LINE('Commande #:'||TO_CHAR(leNoCommande));

	SELECT		noClient, dateCommande
	INTO		leNoClient, laDateCommande
	FROM		Commande
WHERE		noCommande = leNoCommande;

DBMS_OUTPUT.PUT_LINE('noClient:'||TO_CHAR(leNoClient));
DBMS_OUTPUT.PUT_LINE('dateCommande:'||TO_CHAR(laDateCommande));

	FOR uneLigne IN lignesCommande(leNoCommande) LOOP

		DBMS_OUTPUT.PUT('noArticle :');
		DBMS_OUTPUT.PUT(uneLigne.noArticle);
		DBMS_OUTPUT.PUT(' quantité commandée:');
		DBMS_OUTPUT.PUT(uneLigne.quantité);

		-- Chercher la quantité déjà livrée
		SELECT		SUM(quantitéLivrée)
		INTO		laQuantitéLivrée
		FROM		DétailLivraison
		WHERE 		noArticle = uneLigne.noArticle AND
				noCommande = leNoCommande ;

		IF (laQuantitéLivrée IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE(' livraison en attente');
		ELSE
			laQuantitéEnAttente:= uneLigne.quantité -laQuantitéLivrée;
			IF (laQuantitéEnAttente = 0) THEN
				DBMS_OUTPUT.PUT_LINE(' livraison complétée');
			ELSE
				DBMS_OUTPUT.PUT (' quantité en attente :');
				DBMS_OUTPUT.PUT_LINE(laQuantitéEnAttente);
			END IF ;
		END IF ;
	END LOOP;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Numéro de commande inexistant');
	WHEN	OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001,'Exception levée par la procédure');
END pStatutCommande;
/
CREATE OR REPLACE FUNCTION fQuantitéEnStock
(unNoArticle 	Article.noArticle%TYPE)
RETURN Article.quantitéEnStock%TYPE IS

 	uneQuantitéEnStock 	Article.quantitéEnStock%TYPE;
BEGIN
	SELECT 	quantitéEnStock
	INTO 		uneQuantitéEnStock
	FROM 		Article
	WHERE 		noArticle = unNoArticle; 
	RETURN uneQuantitéEnStock;
END fQuantitéEnStock;
/
select fQuantitéEnStock(10) from dual
/
CREATE OR REPLACE PROCEDURE pModifierQuantitéEnStock
(unNoArticle 			Article.noArticle%TYPE, 
 nouvelleQuantitéEnStock 		Article.quantitéEnStock%TYPE) IS
BEGIN
 	UPDATE		Article
 	SET		quantitéEnStock = nouvelleQuantitéEnStock
 	WHERE		noArticle = unNoArticle;
END pModifierQuantitéEnStock;
/
EXECUTE pModifierQuantitéEnStock(10,20)
/
SELECT * FROM Article WHERE noArticle = 10
/
SELECT text
FROM   USER_SOURCE
WHERE  name = 'FQUANTITÉENSTOCK' AND type = 'FUNCTION'
ORDER BY  line
/

