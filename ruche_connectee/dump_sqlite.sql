DROP TABLE IF EXISTS "capteurs";
DROP TABLE IF EXISTS "ruche";
DROP TABLE IF EXISTS "donnees";
DROP TABLE IF EXISTS "images";
DROP TABLE IF EXISTS "compte";

CREATE TABLE "capteurs" (
  "id_capteur" INTEGER NOT NULL ,
  "type" varchar(50) DEFAULT NULL,
  "localisation" varchar(50) DEFAULT NULL,
  "description" text DEFAULT NULL,
  PRIMARY KEY ("id_capteur")
);
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO "capteurs" VALUES (1,'Température','Intérieur','Capteur de température utilisé pour mesurer la température de l''air dans la ruche.');
INSERT INTO "capteurs" VALUES (2,'Humidité','Intérieur','Capteur d''humidité utilisé pour mesurer l''humidité dans la ruche.');
INSERT INTO "capteurs" VALUES (3,'Pression','Extérieur','Capteur de pression atmosphérique utilisé pour surveiller la pression de l''air à lextérieur de la ruche.');
INSERT INTO "capteurs" VALUES (4,'Masse','Intérieur','Capteur de masse utilisé pour mesurer le poids du nid ou de la ruche, afin de suivre son évolution.');
INSERT INTO "capteurs" VALUES (5,'Caméra','Extérieur','Caméra pour capturer des images des abeilles et observer leur activité à l''extérieur de la ruche.');
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

CREATE TABLE "ruche"(
  "id_ruche" INTEGER PRIMARY KEY NOT NULL,
  "name" varchar(50) DEFAULT NULL,
  "adress"varchar(200) DEFAULT NULL
);
INSERT INTO "ruche" VALUES (0,'ruche test','eu1.cloud.thethings.network');

CREATE TABLE "donnees" (
  "id_donnee" INTEGER PRIMARY KEY NOT NULL ,
  "id_capteur" INTEGER NOT NULL,
  "id_ruche" INTEGER NOT NULL,
  "valeur" float DEFAULT NULL,
  "date_mesure" TEXT DEFAULT NULL,
  FOREIGN KEY ("id_capteur") REFERENCES "capteurs" ("id_capteur"),
  FOREIGN KEY ("id_ruche") REFERENCES "ruche"("id_ruche")
);
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO "donnees" VALUES (1,0,1,22.5,'2025-02-18 10:00:00');
INSERT INTO "donnees" VALUES (2,0,2,55.3,'2025-02-18 10:05:00');
INSERT INTO "donnees" VALUES (3,0,3,1013.8,'2025-02-18 10:10:00');
INSERT INTO "donnees" VALUES (4,0,4,5.2,'2025-02-18 10:15:00');
INSERT INTO "donnees" VALUES (5,0,5,NULL,'2025-02-18 10:20:00');
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE "images" (
  "id_image" INTEGER NOT NULL ,
  "chemin_fichier" text DEFAULT NULL,
  "date_capture" TEXT DEFAULT NULL,
  PRIMARY KEY ("id_image")
);
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

/*!40101 SET character_set_client = @saved_cs_client */;
CREATE TABLE "compte"(
  "id_compte" INTEGER PRIMARY KEY NOT NULL ,
  "identifiant" varchar(50) NOT NULL ,
  "password"varchar(200)NOT NULL,
  "grade" int DEFAULT 1 NOT NULL
);

