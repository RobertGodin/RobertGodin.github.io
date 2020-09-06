CREATE OR REPLACE PROCEDURE pStatutCommande 
(leNoCommande	Commande.noCommande%TYPE ) IS

	-- D�claration de variables
leNoClient			Client.noClient%TYPE;
	laDateCommande		Commande.dateCommande%TYPE ;
	leNoArticle			Article.noArticle%TYPE ;
laQuantit�Command�e	LigneCommande.quantit�%TYPE ;
laQuantit�Livr�e		INTEGER;
laQuantit�EnAttente	INTEGER;

	-- D�claration d'un curseur (CURSOR) PL/SQL pour it�rer sur les lignes
	-- de la commande
	CURSOR lignesCommande(unNoCommande Commande.noCommande%TYPE)IS
    		SELECT 	noArticle, quantit�
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
	-- Le OPEN ouvre le CURSOR en lui passant les param�tres
	LOOP
		FETCH lignesCommande INTO leNoArticle, laQuantit�Command�e;
		-- Le FETCH retourne la ligne suivante

		EXIT WHEN lignesCommande%NOTFOUND;
		-- %NOTFOUND est un attribut du CURSOR qui permet de d�terminer
		-- si le FETCH a atteint la fin de la table 
		DBMS_OUTPUT.PUT('noArticle :');
		DBMS_OUTPUT.PUT(leNoArticle);
		DBMS_OUTPUT.PUT(' quantit� command�e:');
		DBMS_OUTPUT.PUT(laQuantit�Command�e);

		-- Chercher la quantit� d�j� livr�e
		SELECT		SUM(quantit�Livr�e)
		INTO		laQuantit�Livr�e
		FROM		D�tailLivraison
		WHERE 		noArticle = leNoArticle AND
				noCommande = leNoCommande ;

		IF (laQuantit�Livr�e IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE(' livraison en attente');
		ELSE
			laQuantit�EnAttente:= laQuantit�Command�e -laQuantit�Livr�e;
			IF (laQuantit�EnAttente = 0) THEN
				DBMS_OUTPUT.PUT_LINE(' livraison compl�t�e');
			ELSE
				DBMS_OUTPUT.PUT (' quantit� en attente :');
				DBMS_OUTPUT.PUT_LINE(laQuantit�EnAttente);
			END IF ;
		END IF ;
	END LOOP;
	-- Le CLOSE ferme le CURSOR	CLOSE lignesCommande;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Num�ro de commande inexistant');
	WHEN	OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001,'Exception lev�e par la proc�dure');
END pStatutCommande;
/
SET SERVEROUTPUT ON
/
EXECUTE pStatutCommande(2)
/
CREATE OR REPLACE PROCEDURE pStatutCommande 
(leNoCommande	Commande.noCommande%TYPE ) IS

	-- D�claration de variables
leNoClient			Client.noClient%TYPE;
	laDateCommande		Commande.dateCommande%TYPE ;
laQuantit�Livr�e		INTEGER;
laQuantit�EnAttente	INTEGER;

	-- D�claration d'un curseur (CURSOR) PL/SQL pour it�rer sur les lignes
	-- de la commande
	CURSOR lignesCommande(unNoCommande Commande.noCommande%TYPE)IS
    		SELECT 	noArticle, quantit�
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
		DBMS_OUTPUT.PUT(' quantit� command�e:');
		DBMS_OUTPUT.PUT(uneLigne.quantit�);

		-- Chercher la quantit� d�j� livr�e
		SELECT		SUM(quantit�Livr�e)
		INTO		laQuantit�Livr�e
		FROM		D�tailLivraison
		WHERE 		noArticle = uneLigne.noArticle AND
				noCommande = leNoCommande ;

		IF (laQuantit�Livr�e IS NULL) THEN
			DBMS_OUTPUT.PUT_LINE(' livraison en attente');
		ELSE
			laQuantit�EnAttente:= uneLigne.quantit� -laQuantit�Livr�e;
			IF (laQuantit�EnAttente = 0) THEN
				DBMS_OUTPUT.PUT_LINE(' livraison compl�t�e');
			ELSE
				DBMS_OUTPUT.PUT (' quantit� en attente :');
				DBMS_OUTPUT.PUT_LINE(laQuantit�EnAttente);
			END IF ;
		END IF ;
	END LOOP;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Num�ro de commande inexistant');
	WHEN	OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001,'Exception lev�e par la proc�dure');
END pStatutCommande;
/
CREATE OR REPLACE FUNCTION fQuantit�EnStock
(unNoArticle 	Article.noArticle%TYPE)
RETURN Article.quantit�EnStock%TYPE IS

 	uneQuantit�EnStock 	Article.quantit�EnStock%TYPE;
BEGIN
	SELECT 	quantit�EnStock
	INTO 		uneQuantit�EnStock
	FROM 		Article
	WHERE 		noArticle = unNoArticle; 
	RETURN uneQuantit�EnStock;
END fQuantit�EnStock;
/
select fQuantit�EnStock(10) from dual
/
CREATE OR REPLACE PROCEDURE pModifierQuantit�EnStock
(unNoArticle 			Article.noArticle%TYPE, 
 nouvelleQuantit�EnStock 		Article.quantit�EnStock%TYPE) IS
BEGIN
 	UPDATE		Article
 	SET		quantit�EnStock = nouvelleQuantit�EnStock
 	WHERE		noArticle = unNoArticle;
END pModifierQuantit�EnStock;
/
EXECUTE pModifierQuantit�EnStock(10,20)
/
SELECT * FROM Article WHERE noArticle = 10
/
SELECT text
FROM   USER_SOURCE
WHERE  name = 'FQUANTIT�ENSTOCK' AND type = 'FUNCTION'
ORDER BY  line
/

