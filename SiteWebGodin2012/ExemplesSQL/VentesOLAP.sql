DROP TABLE Ville CASCADE CONSTRAINTS
/
DROP TABLE Vente CASCADE CONSTRAINTS
/
DROP TABLE Client CASCADE CONSTRAINTS
/
DROP TABLE Article CASCADE CONSTRAINTS
/
CREATE TABLE Ville
(nomVille		VARCHAR(15)	NOT NULL,
 nomPays		VARCHAR(15) NOT NULL,
 PRIMARY KEY (nomVille)
)
/
INSERT INTO Ville
 	VALUES('Montréal','Canada')
/
INSERT INTO Ville
 	VALUES('Ottawa','Canada')
/
INSERT INTO Ville
 	VALUES('Paris','France')
/
CREATE TABLE Client
(noClient 		INTEGER 		NOT NULL,
 nomClient 		VARCHAR(20) 	NOT NULL,
 nomVille 		VARCHAR(15) 	NOT NULL,
 PRIMARY KEY 	(noClient)
)
/
INSERT INTO Client
 	VALUES(1,'Luc Sansom','Montréal')
/
INSERT INTO Client
 	VALUES(2,'Dollard Tremblay','Ottawa')
/
INSERT INTO Client
 	VALUES(3,'Lin Bô','Montréal')
/
INSERT INTO Client
 	VALUES(4,'Jean Leconte','Paris')
/
INSERT INTO Client
 	VALUES(5,'Hafed Alaoui','Ottawa')
/
INSERT INTO Client
 	VALUES(6,'Marie Leconte','Paris')
/
CREATE TABLE Article
(noArticle 		INTEGER		NOT NULL,
 description 	VARCHAR(20),
 prixUnitaire 	DECIMAL(10,2)	NOT NULL,
 quantitéEnStock	INTEGER		DEFAULT 0 NOT NULL,
 catégorie		VARCHAR(10)		NOT NULL,
 PRIMARY KEY (noArticle))
/
INSERT INTO Article
 	VALUES(10,'Cèdre en boule',10.99,10,'Conifère')
/
INSERT INTO Article
 	VALUES(20,'Sapin',12.99,10,'Conifère')
/
INSERT INTO Article
 	VALUES(40,'Épinette bleue',25.99,10,'Conifère')
/
INSERT INTO Article
 	VALUES(50,'Chêne',22.99,10,'Feuillu')
/
INSERT INTO Article
 	VALUES(60,'Érable argenté',15.99,10,'Feuillu')
/
INSERT INTO Article
 	VALUES(70,'Herbe à puce',10.99,10,'Feuillu')
/
INSERT INTO Article
 	VALUES(80,'Poirier',26.99,10,'Feuillu')
/
CREATE TABLE Vente
(noClient 		INTEGER		NOT NULL,
 noArticle 		INTEGER		NOT NULL,
 dateCommande 	DATE			NOT NULL,
 montant 		DECIMAL(10,2)	NOT NULL,
 PRIMARY KEY (noClient,noArticle, dateCommande),
 FOREIGN KEY (noClient) REFERENCES Client,
 FOREIGN KEY (noArticle) REFERENCES Article
)
/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY'
/
INSERT INTO Vente VALUES(1,10,'10/01/2000',100)
/
INSERT INTO Vente VALUES(2,20,'10/01/2000',200)
/
INSERT INTO Vente VALUES(3,10,'10/01/2000',500)
/
INSERT INTO Vente VALUES(1,10,'15/01/2000',300)
/
INSERT INTO Vente VALUES(3,40,'15/01/2000',100)
/
INSERT INTO Vente VALUES(2,60,'16/01/2000',200)
/
INSERT INTO Vente VALUES(4,60,'20/02/2000',400)
/
INSERT INTO Vente VALUES(2,10,'20/02/2000',200)
/
INSERT INTO Vente VALUES(1,40,'25/02/2000',100)
/
INSERT INTO Vente VALUES(4,10,'04/03/2000',300)
/
INSERT INTO Vente VALUES(1,20,'04/03/2000',200)
/
INSERT INTO Vente VALUES(4,60,'15/03/2000',100)
/
INSERT INTO Vente VALUES(2,10,'15/03/2000',500)
/
INSERT INTO Vente VALUES(3,50,'05/04/2000',200)
/
INSERT INTO Vente VALUES(3,20,'06/04/2000',400)
/
INSERT INTO Vente VALUES(1,60,'10/04/2000',200)
/
INSERT INTO Vente VALUES(1,10,'15/04/2000',100)
/
INSERT INTO Vente VALUES(2,60,'20/05/2000',200)
/
INSERT INTO Vente VALUES(3,10,'25/05/2000',500)
/
INSERT INTO Vente VALUES(1,50,'05/06/2000',200)
/
INSERT INTO Vente VALUES(2,20,'05/06/2000',100)
/
SELECT noClient,noArticle,SUM(montant)
FROM Vente
GROUP BY noClient,noArticle,dateCommande
/
SELECT noClient,noArticle,SUM(montant)
FROM Vente
GROUP BY noClient,noArticle
/
SELECT noClient,noArticle,dateCommande,SUM(montant)
FROM Vente
GROUP BY CUBE(noClient,noArticle,dateCommande)
/
SELECT noClient,noArticle,dateCommande,SUM(montant)
FROM Vente
GROUP BY ROLLUP(noClient,noArticle,dateCommande)
/
SELECT noClient,noArticle,dateCommande,SUM(montant)
FROM Vente
GROUP BY CUBE(noClient,noArticle)
/
SELECT noClient,noArticle,dateCommande,SUM(montant)
FROM Vente
GROUP BY ROLLUP(noClient,noArticle)
/
SELECT nomVille,noArticle, SUM(montant)
FROM	Vente, Client
WHERE Vente.noClient = Client.noClient
GROUP BY CUBE (nomVille,noArticle)
/

