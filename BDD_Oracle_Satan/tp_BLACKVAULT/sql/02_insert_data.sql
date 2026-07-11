-- ============================================================
-- BLACKVAULT - Script 02 : Insertion des donnees fictives
-- Executer apres 01_create_schema.sql
-- Toutes les donnees sont entierement fictives
-- ============================================================

CONNECT blackvault/"BlackVault#2025"@FREEPDB1

-- ============================================================
-- PROGRAMMES DE PROTECTION (5 programmes)
-- ============================================================
INSERT INTO programmes_protection VALUES (seq_programmes.NEXTVAL,'BOUCLIER ALPIN','France','Protection de témoins liés au crime organisé français',DATE '2018-03-15','ACTIF');
INSERT INTO programmes_protection VALUES (seq_programmes.NEXTVAL,'OPERATION NEBULA','Belgique','Programme européen antiterrorisme',DATE '2019-07-01','ACTIF');
INSERT INTO programmes_protection VALUES (seq_programmes.NEXTVAL,'SHADOW COAST','Espagne','Protection témoins trafic maritime',DATE '2017-01-10','ACTIF');
INSERT INTO programmes_protection VALUES (seq_programmes.NEXTVAL,'GRANITE SHIELD','Suisse','Témoins corruption financière internationale',DATE '2020-11-20','ACTIF');
INSERT INTO programmes_protection VALUES (seq_programmes.NEXTVAL,'PROGRAMME ARCTIQUE','Pays-Bas','Protection transfrontalière nord-européenne',DATE '2016-06-05','SUSPENDU');

-- ============================================================
-- AGENTS DE PROTECTION (15 agents)
-- ============================================================
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-001','Moreau','Sylvain','Commandant','TOP_SECRET','ACTIF','bv_directeur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-002','Laurent','Isabelle','Capitaine','SECRET','ACTIF','bv_coordinateur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-003','Dubois','Thomas','Lieutenant','SECRET','ACTIF','bv_coordinateur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-004','Petit','Nathalie','Sergent','CONFIDENTIEL','ACTIF','bv_analyste');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-005','Garnier','Paul','Sergent','CONFIDENTIEL','ACTIF','bv_analyste');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-006','Simon','Claire','Capitaine','SECRET','ACTIF','bv_coordinateur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-007','Bernard','Hugo','Lieutenant','SECRET','ACTIF','bv_coordinateur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-008','Fontaine','Alain','Commandant','TOP_SECRET','ACTIF','bv_directeur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-009','Renard','Margot','Sergent','CONFIDENTIEL','INACTIF','bv_analyste');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-010','Chevalier','Luc','Capitaine','SECRET','ACTIF','bv_coordinateur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-011','Leroy','Anne','Lieutenant','CONFIDENTIEL','ACTIF','bv_analyste');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-012','Martin','Pierre','Sergent','CONFIDENTIEL','ACTIF','bv_analyste');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-013','Blanc','Elodie','Capitaine','SECRET','ACTIF','bv_coordinateur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-014','Rousseau','Marc','Commandant','TOP_SECRET','ACTIF','bv_directeur');
INSERT INTO agents_protection VALUES (seq_agents.NEXTVAL,'AGT-015','Dupont','Julie','Sergent','CONFIDENTIEL','SUSPENDU','bv_analyste');

-- ============================================================
-- TEMOINS (30 témoins + 1 honeytoken)
-- ============================================================
-- Programme 1 (BOUCLIER ALPIN)
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2019-001',DATE '2019-02-14','ELEVE','ACTIF',1,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2019-002',DATE '2019-05-20','MODERE','ACTIF',1,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2020-003',DATE '2020-01-08','CRITIQUE','RELOCALISE',1,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2020-004',DATE '2020-06-12','FAIBLE','ACTIF',1,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2021-005',DATE '2021-03-30','MODERE','SORTI',1,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2021-006',DATE '2021-09-15','ELEVE','ACTIF',1,0);

-- Programme 2 (OPERATION NEBULA)
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2019-007',DATE '2019-11-01','CRITIQUE','ACTIF',2,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2020-008',DATE '2020-03-17','ELEVE','ACTIF',2,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2020-009',DATE '2020-08-25','MODERE','RELOCALISE',2,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2021-010',DATE '2021-01-07','FAIBLE','ACTIF',2,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2021-011',DATE '2021-06-22','ELEVE','DECEDE',2,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2022-012',DATE '2022-02-11','CRITIQUE','ACTIF',2,0);

-- Programme 3 (SHADOW COAST)
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'SHC-2018-013',DATE '2018-07-04','MODERE','ACTIF',3,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'SHC-2018-014',DATE '2018-11-19','FAIBLE','SORTI',3,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'SHC-2019-015',DATE '2019-04-08','ELEVE','ACTIF',3,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'SHC-2020-016',DATE '2020-09-30','CRITIQUE','RELOCALISE',3,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'SHC-2021-017',DATE '2021-12-05','MODERE','ACTIF',3,0);

-- Programme 4 (GRANITE SHIELD)
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'GRS-2020-018',DATE '2020-02-28','ELEVE','ACTIF',4,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'GRS-2020-019',DATE '2020-07-14','CRITIQUE','ACTIF',4,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'GRS-2021-020',DATE '2021-04-01','MODERE','RELOCALISE',4,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'GRS-2021-021',DATE '2021-10-18','FAIBLE','ACTIF',4,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'GRS-2022-022',DATE '2022-06-09','ELEVE','ACTIF',4,0);

-- Programme 5 (ARCTIQUE - SUSPENDU)
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'ARC-2017-023',DATE '2017-05-21','MODERE','SORTI',5,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'ARC-2017-024',DATE '2017-09-03','FAIBLE','SORTI',5,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'ARC-2018-025',DATE '2018-01-15','ELEVE','DECEDE',5,0);

-- Temoins supplementaires (programmes 1-4)
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2022-026',DATE '2022-03-07','MODERE','ACTIF',1,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'NBL-2022-027',DATE '2022-08-14','ELEVE','ACTIF',2,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'SHC-2022-028',DATE '2022-11-22','CRITIQUE','ACTIF',3,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'GRS-2022-029',DATE '2022-12-01','FAIBLE','ACTIF',4,0);
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'BVT-2023-030',DATE '2023-02-20','ELEVE','ACTIF',1,0);

-- HONEYTOKEN : dossier AEGIS-OMEGA
INSERT INTO temoins VALUES (seq_temoins.NEXTVAL,'AEGIS-OMEGA',DATE '2024-01-01','CRITIQUE','ACTIF',1,1);

-- ============================================================
-- IDENTITES REELLES (31 entrées, 1:1 avec temoins)
-- ============================================================
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,1,'Marchetti','Alessandro',DATE '1972-08-14','Italienne','FR-7208141234',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH1')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,2,'Kovacs','Eva',DATE '1985-03-22','Hongroise','FR-8503221567',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH2')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,3,'Vasquez','Carlos',DATE '1968-11-07','Espagnole','ES-6811075432',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH3')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,4,'Bellini','Greta',DATE '1990-06-18','Italienne','IT-9006182345',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH4')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,5,'Novak','Petr',DATE '1979-02-28','Tchèque','CZ-7902284567',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH5')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,6,'Girard','Valentina',DATE '1983-09-11','Française','FR-8309112890',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH6')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,7,'Zanetti','Marco',DATE '1965-12-03','Italienne','IT-6512034567',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH7')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,8,'Hoffman','Klaus',DATE '1977-04-16','Allemande','DE-7704163456',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH8')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,9,'Santos','Maria',DATE '1988-07-29','Portugaise','PT-8807295678',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH9')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,10,'Petrov','Igor',DATE '1981-01-05','Bulgare','BG-8101055432',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH10')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,11,'Okonkwo','Emeka',DATE '1974-05-23','Nigériane','NG-7405236789',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH11')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,12,'Nakamura','Yuki',DATE '1991-10-08','Japonaise','JP-9110084321',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH12')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,13,'Fernandez','Diego',DATE '1969-03-14','Espagnole','ES-6903147654',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH13')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,14,'Blanc','Sophie',DATE '1993-08-27','Française','FR-9308275678',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH14')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,15,'Muller','Hans',DATE '1976-06-01','Suisse','CH-7606019876',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH15')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,16,'Reyes','Carmen',DATE '1971-12-18','Mexicaine','MX-7112185432',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH16')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,17,'Patel','Raj',DATE '1986-09-04','Indienne','IN-8609043456',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH17')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,18,'Weber','Dieter',DATE '1967-04-22','Allemande','DE-6704228765',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH18')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,19,'Greco','Lucia',DATE '1982-01-30','Italienne','IT-8201305432',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH19')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,20,'Dubois','Pierre',DATE '1975-07-17','Française','FR-7507174321',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH20')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,21,'Johansson','Erik',DATE '1989-11-09','Suédoise','SE-8911096789',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH21')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,22,'Kowalski','Anna',DATE '1973-02-14','Polonaise','PL-7302145678',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH22')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,23,'Moreau','Xavier',DATE '1980-08-06','Française','FR-8008063456',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH23')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,24,'Costa','Roberto',DATE '1994-05-19','Italienne','IT-9405198765',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH24')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,25,'Andersen','Lars',DATE '1966-10-25','Danoise','DK-6610253456',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH25')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,26,'Lefevre','Camille',DATE '1987-03-08','Française','FR-8703085678',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH26')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,27,'Ricci','Francesca',DATE '1992-06-13','Italienne','IT-9206136789',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH27')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,28,'Al-Rashid','Omar',DATE '1978-09-20','Jordanienne','JO-7809205432',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH28')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,29,'Svensson','Mia',DATE '1984-12-31','Suédoise','SE-8412317654',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH29')));
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,30,'Baudouin','Alicia',DATE '1970-04-07','Belge','BE-7004072345',RAWTOHEX(UTL_RAW.CAST_TO_RAW('H'||'ASH30')));
-- Honeytoken
INSERT INTO identites_reelles VALUES (seq_identites_r.NEXTVAL,31,'OMEGA','PRIME',DATE '1960-01-01','Inconnue','XX-0000000001','DEADBEEF1234567890ABCDEF');

-- ============================================================
-- NOUVELLES IDENTITES de couverture (45 entrées)
-- ============================================================
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,1,'Lambert','Pierre',DATE '1970-05-12','Comptable',DATE '2019-03-01',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,2,'Martin','Nicole',DATE '1983-07-18','Libraire',DATE '2019-06-15',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,3,'Renard','Jacques',DATE '1966-02-28','Mécanicien',DATE '2020-02-10',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,3,'Faure','Paul',DATE '1966-03-01','Agriculteur',DATE '2022-01-05',0);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,4,'Giraud','Elisa',DATE '1988-09-14','Institutrice',DATE '2020-07-20',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,6,'Chenal','Mathieu',DATE '1981-11-03','Electricien',DATE '2021-10-01',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,7,'Roux','Antoine',DATE '1963-04-07','Restaurateur',DATE '2020-01-15',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,8,'Bonnet','Sarah',DATE '1975-08-22','Infirmière',DATE '2020-04-10',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,9,'Perrin','Daniel',DATE '1986-01-17','Professeur',DATE '2021-09-01',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,10,'Simon','Claire',DATE '1979-06-30','Fleuriste',DATE '2021-02-20',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,12,'Durand','Thomas',DATE '1989-12-05','Boulanger',DATE '2022-03-01',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,13,'Lefebvre','Isabelle',DATE '1967-03-28','Pharmacienne',DATE '2018-08-15',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,15,'Fournier','Jean',DATE '1974-07-14','Horloger',DATE '2019-05-10',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,16,'Garcia','Rosa',DATE '1969-10-09','Cuisinière',DATE '2020-10-25',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,17,'Singh','Amir',DATE '1984-02-18','Ingénieur',DATE '2021-12-10',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,18,'Meyer','Friedrich',DATE '1965-08-03','Jardinier',DATE '2021-01-08',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,19,'Ferrari','Marco',DATE '1980-05-26','Avocat',DATE '2020-08-12',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,20,'Lemaire','Vincent',DATE '1973-11-11','Comptable',DATE '2021-05-30',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,22,'Wojcik','Katarzyna',DATE '1971-09-07','Médecin',DATE '2022-07-15',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,26,'Barbier','Julie',DATE '1985-04-21','Architecte',DATE '2022-04-01',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,27,'Conti','Stefano',DATE '1990-07-16','Menuisier',DATE '2022-09-05',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,28,'Hamdan','Khalil',DATE '1976-12-02','Traducteur',DATE '2022-12-20',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,29,'Eriksson','Anna',DATE '1982-03-25','Libraire',DATE '2023-01-15',1);
INSERT INTO nouvelles_identites VALUES (seq_nouvelles_id.NEXTVAL,30,'Dupont','Cécile',DATE '1968-06-09','Kinésithérapeute',DATE '2022-02-28',1);

-- ============================================================
-- LOCALISATIONS (40 entrées)
-- ============================================================
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,1,'SAFE_HOUSE','Lyon','France','12 impasse des Acacias',DATE '2019-02-14',DATE '2021-05-20',0);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,1,'APPARTEMENT','Grenoble','France','47 rue des Alpes',DATE '2021-05-21',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,2,'APPARTEMENT','Bordeaux','France','23 avenue de la Paix',DATE '2019-05-20',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,3,'SAFE_HOUSE','Marseille','France','5 rue du Port',DATE '2020-01-08',DATE '2022-06-01',0);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,3,'ETRANGER','Barcelone','Espagne','Carrer de les Flors 18',DATE '2022-06-02',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,4,'APPARTEMENT','Nantes','France','8 rue de la Loire',DATE '2020-06-12',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,6,'SAFE_HOUSE','Strasbourg','France','33 rue de l''Eglise',DATE '2021-09-15',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,7,'SAFE_HOUSE','Bruxelles','Belgique','Rue des Capucines 77',DATE '2019-11-01',DATE '2023-01-01',0);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,7,'ETRANGER','Lucerne','Suisse','Seestrasse 12',DATE '2023-01-02',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,8,'APPARTEMENT','Liège','Belgique','Boulevard de la Constitution 45',DATE '2020-03-17',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,9,'HOTEL','Bruges','Belgique','Markt Hotel, chambre 214',DATE '2020-08-25',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,10,'APPARTEMENT','Gand','Belgique','Korenlei 9',DATE '2021-01-07',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,12,'SAFE_HOUSE','Namur','Belgique','Rue de Fer 22',DATE '2022-02-11',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,13,'APPARTEMENT','Alicante','Espagne','Calle Mayor 55',DATE '2018-07-04',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,15,'SAFE_HOUSE','Bilbao','Espagne','Gran Via 30',DATE '2019-04-08',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,16,'ETRANGER','Casablanca','Maroc','Avenue Hassan II 12',DATE '2020-09-30',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,17,'APPARTEMENT','Madrid','Espagne','Calle de Alcalá 200',DATE '2021-12-05',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,18,'SAFE_HOUSE','Genève','Suisse','Route de Florissant 84',DATE '2020-02-28',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,19,'APPARTEMENT','Zurich','Suisse','Bahnhofstrasse 42',DATE '2020-07-14',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,20,'ETRANGER','Vienne','Autriche','Ringstrasse 8',DATE '2021-04-01',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,21,'APPARTEMENT','Berne','Suisse','Kramgasse 15',DATE '2021-10-18',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,22,'SAFE_HOUSE','Lausanne','Suisse','Avenue de la Gare 77',DATE '2022-06-09',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,26,'APPARTEMENT','Toulouse','France','Place du Capitole 3',DATE '2022-03-07',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,27,'SAFE_HOUSE','Anvers','Belgique','Meir 50',DATE '2022-08-14',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,28,'ETRANGER','Séville','Espagne','Calle Sierpes 10',DATE '2022-11-22',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,29,'APPARTEMENT','Bâle','Suisse','Freie Strasse 7',DATE '2022-12-01',NULL,1);
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,30,'SAFE_HOUSE','Paris','France','Rue de Rivoli 189',DATE '2023-02-20',NULL,1);
-- Honeytoken
INSERT INTO localisations VALUES (seq_localisations.NEXTVAL,31,'SAFE_HOUSE','CLASSIFIE','CLASSIFIE','ULTRA-SECRET BUNKER ALPHA-7',DATE '2024-01-01',NULL,1);

-- ============================================================
-- AFFAIRES (20 affaires)
-- ============================================================
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2018-001','Réseau Falcon','CRIME_ORGANISE','TGI Lyon',DATE '2018-04-12','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2018-002','Opération Mirage','TERRORISME','PNAT Paris',DATE '2018-09-03','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2019-003','Trafic Neptune','TRAFIC','TGI Marseille',DATE '2019-01-22','CLOS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2019-004','Corruption Delta','CORRUPTION','TGI Paris',DATE '2019-07-15','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2019-005','Réseau Cobra','CRIME_ORGANISE','Tribunal Madrid',DATE '2019-11-08','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2020-006','Financement occulte','CORRUPTION','Tribunal Genève',DATE '2020-02-17','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2020-007','Cellule Epsilon','TERRORISME','PNAT Paris',DATE '2020-06-04','JUGEMENT');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2020-008','Route Bleue','TRAFIC','TGI Bordeaux',DATE '2020-10-19','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2021-009','Réseau Hydra','CRIME_ORGANISE','TGI Nice',DATE '2021-03-28','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2021-010','Projet Fantôme','TERRORISME','Tribunal Bruxelles',DATE '2021-07-11','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2021-011','Caisse noire','CORRUPTION','Tribunal Zurich',DATE '2021-09-30','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2021-012','Trafic Soleil','TRAFIC','TGI Montpellier',DATE '2021-12-14','CLOS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2022-013','Cartel Ibérique','CRIME_ORGANISE','Tribunal Barcelone',DATE '2022-02-08','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2022-014','Vague de choc','TERRORISME','PNAT Paris',DATE '2022-05-20','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2022-015','Blanchiment Aurora','CORRUPTION','TGI Strasbourg',DATE '2022-08-01','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2022-016','Route du Nord','TRAFIC','Tribunal Anvers',DATE '2022-10-13','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2023-017','Réseau Titan','CRIME_ORGANISE','TGI Toulouse',DATE '2023-01-17','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2023-018','Cellule Zéro','TERRORISME','PNAT Paris',DATE '2023-03-05','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2023-019','Opération Prisme','AUTRE','DGSI Paris',DATE '2023-06-22','EN_COURS');
INSERT INTO affaires VALUES (seq_affaires.NEXTVAL,'AFF-2024-020','Dossier OMEGA','AUTRE','DGSI Paris',DATE '2024-01-15','CLASSIFIE');

-- ============================================================
-- TEMOINS_AFFAIRES (50 liaisons)
-- ============================================================
INSERT INTO temoins_affaires VALUES (1,1,'PRINCIPAL',DATE '2019-03-01');
INSERT INTO temoins_affaires VALUES (2,1,'SECONDAIRE',DATE '2019-04-10');
INSERT INTO temoins_affaires VALUES (3,2,'PRINCIPAL',DATE '2020-02-15');
INSERT INTO temoins_affaires VALUES (7,2,'PRINCIPAL',DATE '2019-12-01');
INSERT INTO temoins_affaires VALUES (8,2,'SECONDAIRE',DATE '2020-04-22');
INSERT INTO temoins_affaires VALUES (4,3,'SECONDAIRE',DATE '2020-07-05');
INSERT INTO temoins_affaires VALUES (13,3,'PRINCIPAL',DATE '2018-08-10');
INSERT INTO temoins_affaires VALUES (14,3,'SECONDAIRE',DATE '2019-01-15');
INSERT INTO temoins_affaires VALUES (18,4,'PRINCIPAL',DATE '2020-03-12');
INSERT INTO temoins_affaires VALUES (19,4,'SECONDAIRE',DATE '2020-09-01');
INSERT INTO temoins_affaires VALUES (20,4,'SECONDAIRE',DATE '2021-05-20');
INSERT INTO temoins_affaires VALUES (15,5,'PRINCIPAL',DATE '2019-11-20');
INSERT INTO temoins_affaires VALUES (16,5,'SECONDAIRE',DATE '2021-02-08');
INSERT INTO temoins_affaires VALUES (13,5,'TEMOIGN',DATE '2020-01-15');
INSERT INTO temoins_affaires VALUES (18,6,'PRINCIPAL',DATE '2020-04-01');
INSERT INTO temoins_affaires VALUES (19,6,'PRINCIPAL',DATE '2020-08-10');
INSERT INTO temoins_affaires VALUES (22,6,'SECONDAIRE',DATE '2022-08-01');
INSERT INTO temoins_affaires VALUES (7,7,'PRINCIPAL',DATE '2020-07-01');
INSERT INTO temoins_affaires VALUES (3,7,'SECONDAIRE',DATE '2021-01-15');
INSERT INTO temoins_affaires VALUES (6,8,'PRINCIPAL',DATE '2021-10-01');
INSERT INTO temoins_affaires VALUES (1,8,'SECONDAIRE',DATE '2022-01-10');
INSERT INTO temoins_affaires VALUES (2,8,'SECONDAIRE',DATE '2022-03-05');
INSERT INTO temoins_affaires VALUES (12,9,'PRINCIPAL',DATE '2022-03-15');
INSERT INTO temoins_affaires VALUES (7,9,'SECONDAIRE',DATE '2022-05-01');
INSERT INTO temoins_affaires VALUES (9,9,'SECONDAIRE',DATE '2022-07-20');
INSERT INTO temoins_affaires VALUES (3,10,'SECONDAIRE',DATE '2021-08-01');
INSERT INTO temoins_affaires VALUES (8,10,'PRINCIPAL',DATE '2021-08-15');
INSERT INTO temoins_affaires VALUES (11,10,'SECONDAIRE',DATE '2021-09-10');
INSERT INTO temoins_affaires VALUES (18,11,'PRINCIPAL',DATE '2021-11-01');
INSERT INTO temoins_affaires VALUES (19,11,'SECONDAIRE',DATE '2022-01-20');
INSERT INTO temoins_affaires VALUES (20,12,'PRINCIPAL',DATE '2022-01-15');
INSERT INTO temoins_affaires VALUES (4,12,'SECONDAIRE',DATE '2022-03-01');
INSERT INTO temoins_affaires VALUES (16,13,'PRINCIPAL',DATE '2022-03-01');
INSERT INTO temoins_affaires VALUES (28,13,'SECONDAIRE',DATE '2023-01-10');
INSERT INTO temoins_affaires VALUES (30,14,'PRINCIPAL',DATE '2023-03-15');
INSERT INTO temoins_affaires VALUES (27,14,'SECONDAIRE',DATE '2023-04-01');
INSERT INTO temoins_affaires VALUES (26,15,'PRINCIPAL',DATE '2022-09-01');
INSERT INTO temoins_affaires VALUES (22,15,'SECONDAIRE',DATE '2022-10-15');
INSERT INTO temoins_affaires VALUES (29,16,'PRINCIPAL',DATE '2023-01-05');
INSERT INTO temoins_affaires VALUES (24,16,'SECONDAIRE',DATE '2023-02-01');
INSERT INTO temoins_affaires VALUES (30,17,'SECONDAIRE',DATE '2023-02-28');
INSERT INTO temoins_affaires VALUES (6,17,'SECONDAIRE',DATE '2023-04-10');
INSERT INTO temoins_affaires VALUES (12,18,'PRINCIPAL',DATE '2023-04-01');
INSERT INTO temoins_affaires VALUES (7,18,'SECONDAIRE',DATE '2023-05-15');
INSERT INTO temoins_affaires VALUES (3,19,'SECONDAIRE',DATE '2023-07-10');
INSERT INTO temoins_affaires VALUES (19,19,'SECONDAIRE',DATE '2023-08-01');
INSERT INTO temoins_affaires VALUES (31,20,'PRINCIPAL',DATE '2024-01-15');  -- Honeytoken
INSERT INTO temoins_affaires VALUES (12,20,'SECONDAIRE',DATE '2024-02-01');
INSERT INTO temoins_affaires VALUES (7,20,'SECONDAIRE',DATE '2024-02-15');
INSERT INTO temoins_affaires VALUES (19,20,'SECONDAIRE',DATE '2024-03-01');

-- ============================================================
-- MENACES (25 menaces)
-- ============================================================
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,1,'Clan Marchetti','ASSASSINAT',5,DATE '2019-06-15','ACTIF','Contrat présumé de 50 000 EUR identifié par la DGSI');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,2,'Inconnu','INTIMIDATION',2,DATE '2019-08-10','RESOLU','Appels anonymes, probable membre du réseau Falcon');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,3,'Organisation ETA résiduelle','ASSASSINAT',5,DATE '2020-03-05','ACTIF','Filature confirmée par surveillance vidéo Barcelone');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,6,'Groupe radical X','ENLEVEMENT',4,DATE '2021-10-20','ACTIF','Tentative d''enlèvement déjouée 2021-10-18');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,7,'Cartel Zanetti','ASSASSINAT',5,DATE '2020-01-12','ACTIF','Trois tentatives avortées depuis 2020');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,7,'Inconnu','CYBERATTAQUE',3,DATE '2021-03-22','RESOLU','Intrusion système de messagerie sécurisée');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,8,'Groupe Hoffman','INTIMIDATION',3,DATE '2020-06-14','ACTIF','Menaces sur famille restée en Allemagne');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,9,'Réseau Santos','ENLEVEMENT',4,DATE '2020-09-30','ACTIF','Surveillance du logement confirmée');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,12,'Cartel asiatique Z','ASSASSINAT',5,DATE '2022-04-18','ACTIF','Informateur tué dans même réseau 2022-04-01');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,12,'Inconnu','CYBERATTAQUE',4,DATE '2022-07-07','ACTIF','Tentative de localisation par métadonnées photo');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,15,'Faction ETA','ASSASSINAT',5,DATE '2019-05-12','ACTIF','Présence suspecte à Bilbao relevée');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,16,'Cartel Reyes','ENLEVEMENT',4,DATE '2020-11-08','ACTIF','Surveillance par drone identifiée');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,18,'Réseau Greco','ASSASSINAT',5,DATE '2020-04-15','ACTIF','Contrat actif confirmé source Alpha-2');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,19,'Clan Greco','INTIMIDATION',3,DATE '2020-09-01','RESOLU','Menaces via intermédiaire neutralisé');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,22,'Réseau polonais X','ENLEVEMENT',3,DATE '2022-08-20','ACTIF','Filature signalée à Lausanne');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,26,'Faction Falcon','INTIMIDATION',2,DATE '2022-04-10','ACTIF','Messages codés interceptés');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,27,'Cellule Nebula','ASSASSINAT',4,DATE '2022-09-05','ACTIF','Alerte source confidentielle B-7');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,28,'Réseau Ibérique','CYBERATTAQUE',3,DATE '2022-12-01','ACTIF','Tentative phishing sécurisé');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,30,'Faction inconnue','ASSASSINAT',4,DATE '2023-03-10','ACTIF','Contact suspecte à Paris 15e');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,30,'Groupe cyber C','CYBERATTAQUE',5,DATE '2023-04-15','ACTIF','Attaque sophistiquée infrastructure BNPT');
-- Honeytoken
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,31,'OMEGA NETWORK','ASSASSINAT',5,DATE '2024-01-05','ACTIF','ULTRA-CLASSIFIE : contrat international de 2M EUR');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,31,'Unknown State Actor','CYBERATTAQUE',5,DATE '2024-01-10','ACTIF','APT-niveau national identifié');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,3,'Inconnu','INTIMIDATION',2,DATE '2022-09-01','RESOLU','Surveillance ponctuelle');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,1,'Clan rival','INTIMIDATION',3,DATE '2022-11-15','ACTIF','Alerte réseau Falcon réactivé');
INSERT INTO menaces VALUES (seq_menaces.NEXTVAL,8,'Groupe radical Y','ENLEVEMENT',3,DATE '2023-01-20','ACTIF','Détection par renseignement belge');

-- ============================================================
-- ASSIGNATIONS (35 assignations)
-- ============================================================
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,1,2,DATE '2019-02-14',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,1,4,DATE '2019-02-14',NULL,'SURVEILLANCE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,2,3,DATE '2019-05-20',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,3,1,DATE '2020-01-08',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,3,5,DATE '2020-01-08',NULL,'SECONDAIRE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,4,4,DATE '2020-06-12',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,6,6,DATE '2021-09-15',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,7,8,DATE '2019-11-01',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,7,2,DATE '2019-11-01',NULL,'SECONDAIRE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,8,3,DATE '2020-03-17',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,9,6,DATE '2020-08-25',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,10,11,DATE '2021-01-07',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,12,14,DATE '2022-02-11',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,12,7,DATE '2022-02-11',NULL,'SECONDAIRE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,13,10,DATE '2018-07-04',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,15,13,DATE '2019-04-08',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,16,8,DATE '2020-09-30',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,16,2,DATE '2020-09-30',NULL,'SECONDAIRE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,17,10,DATE '2021-12-05',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,18,1,DATE '2020-02-28',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,19,8,DATE '2020-07-14',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,19,14,DATE '2020-07-14',NULL,'SECONDAIRE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,20,3,DATE '2021-04-01',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,21,6,DATE '2021-10-18',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,22,13,DATE '2022-06-09',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,26,3,DATE '2022-03-07',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,27,7,DATE '2022-08-14',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,28,10,DATE '2022-11-22',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,29,13,DATE '2022-12-01',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,30,1,DATE '2023-02-20',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,30,8,DATE '2023-02-20',NULL,'SURVEILLANCE');
-- Honeytoken
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,31,1,DATE '2024-01-01',NULL,'PRINCIPAL');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,31,8,DATE '2024-01-01',NULL,'SECONDAIRE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,31,14,DATE '2024-01-01',NULL,'SURVEILLANCE');
INSERT INTO assignations VALUES (seq_assignations.NEXTVAL,5,12,DATE '2021-03-30',DATE '2021-06-01','PRINCIPAL');

-- ============================================================
-- CONTACTS AUTORISES (30 contacts)
-- ============================================================
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,1,'Cecilia Marchetti','Epouse','Telephone securise','Hebdomadaire',2);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,1,'Avocat Rossi','Défenseur','Videoconference','Mensuel',2);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,2,'Joana Kovacs','Mère','Courrier','Mensuel',3);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,3,'Carlos Jr Vasquez','Fils','Telephone securise','Bimensuel',1);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,4,'Dr Bellini','Médecin','En personne','A la demande',4);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,6,'Marc Girard','Frère','Videoconference','Hebdomadaire',6);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,7,'Maria Zanetti','Mère','Telephone securise','Mensuel',8);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,8,'Psychiatre Dr Weiss','Soignant','En personne','Bimensuel',3);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,9,'Joao Santos','Père','Courrier','Mensuel',6);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,10,'Olga Petrov','Soeur','Videoconference','Hebdomadaire',11);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,12,'Mme Nakamura','Mère','Telephone securise','Bimensuel',14);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,13,'Diego Jr Fernandez','Fils','En personne','Mensuel',10);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,15,'Ursula Muller','Epouse','Videoconference','Hebdomadaire',13);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,16,'Roberto Reyes','Père','Courrier','Mensuel',8);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,17,'Priya Patel','Soeur','Telephone securise','Hebdomadaire',10);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,18,'Avocat Meyer','Défenseur','Videoconference','Mensuel',1);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,19,'Paolo Greco','Frère','Telephone securise','Bimensuel',8);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,20,'Helene Dubois','Epouse','En personne','Mensuel',3);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,22,'Piotr Kowalski','Père','Courrier','Mensuel',13);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,26,'François Lefevre','Père','Videoconference','Hebdomadaire',3);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,27,'Giacomo Ricci','Oncle','Telephone securise','Mensuel',7);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,28,'Fatima Al-Rashid','Epouse','Courrier','Mensuel',10);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,29,'Lars Svensson','Père','Videoconference','Bimensuel',13);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,30,'Jean-Claude Baudouin','Père','Telephone securise','Hebdomadaire',1);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,1,'Psychiatre Dr Arnaud','Soignant','En personne','Mensuel',2);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,7,'Avocat Zanetti','Défenseur','Videoconference','Mensuel',8);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,12,'Avocat Nakamura','Défenseur','Videoconference','Bimensuel',14);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,19,'Psychiatre Dr Bassi','Soignant','En personne','Bimensuel',8);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,3,'Maria Vasquez','Epouse','Telephone securise','Bimensuel',1);
INSERT INTO contacts_autorises VALUES (seq_contacts.NEXTVAL,8,'Klaus Jr Hoffman','Fils','Telephone securise','Mensuel',3);

-- ============================================================
-- DOCUMENTS IDENTITE (40 documents)
-- ============================================================
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,1,'CNI','CNI-FR-78451230','2019-03-01','2029-03-01','Préfecture du Rhône');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,1,'PASSEPORT','PP-FR-AB123456','2019-03-01','2029-03-01','Ministère Intérieur');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,2,'CNI','CNI-FR-65782341','2019-06-15','2029-06-15','Préfecture Gironde');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,3,'CNI','CNI-FR-92341567','2020-02-10','2030-02-10','Préfecture B-R');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,3,'PASSEPORT','PP-FR-CD234567','2020-02-10','2030-02-10','Ministère Intérieur');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,4,'CNI','CNI-FR-43218765','2020-07-20','2030-07-20','Préfecture Loire-Atl');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,5,'CNI','CNI-FR-55671234','2022-01-05','2032-01-05','Préfecture Rhône');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,6,'CNI','CNI-FR-78912340','2021-10-01','2031-10-01','Préfecture Bas-Rhin');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,7,'CNI','BE-CNI-12347654','2020-01-15','2030-01-15','Commune Bruxelles');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,7,'PASSEPORT','BE-PP-EF345678','2020-01-15','2030-01-15','SPF Belge');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,8,'CNI','BE-CNI-98761234','2020-04-10','2030-04-10','Commune Liège');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,9,'CNI','BE-CNI-45671890','2021-09-01','2031-09-01','Commune Bruges');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,10,'CNI','BE-CNI-32108765','2021-02-20','2031-02-20','Commune Gand');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,11,'CNI','BE-CNI-67890124','2022-03-01','2032-03-01','Commune Namur');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,11,'PASSEPORT','BE-PP-GH456789','2022-03-01','2032-03-01','SPF Belge');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,12,'CNI','ES-DNI-12X345678','2018-08-15','2028-08-15','Oficina Civil Alicante');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,13,'CNI','ES-DNI-56Y789012','2019-05-10','2029-05-10','Oficina Civil Bilbao');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,14,'CNI','MA-CIN-789012345','2020-10-25','2030-10-25','Municipalité Casablanca');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,15,'CNI','ES-DNI-34Z678901','2021-12-10','2031-12-10','Oficina Civil Madrid');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,16,'CNI','CH-ID-1234567891','2021-01-08','2031-01-08','Chancellerie fédérale CH');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,17,'CNI','CH-ID-9876543219','2020-08-12','2030-08-12','Chancellerie fédérale CH');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,17,'PASSEPORT','CH-PP-IJ567890','2020-08-12','2030-08-12','Chancellerie fédérale CH');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,18,'CNI','CH-ID-5678901237','2021-05-30','2031-05-30','Chancellerie fédérale CH');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,19,'CNI','CH-ID-3456789015','2022-07-15','2032-07-15','Chancellerie fédérale CH');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,20,'CNI','CH-ID-7890123453','2021-01-08','2031-01-08','Chancellerie fédérale CH');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,21,'CNI','FR-CNI-56789123','2022-04-01','2032-04-01','Préfecture Haute-Garonne');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,22,'CNI','BE-CNI-34509876','2022-09-05','2032-09-05','Commune Anvers');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,23,'CNI','ES-DNI-78X012345','2022-12-20','2032-12-20','Oficina Civil Séville');
INSERT INTO documents_identite VALUES (seq_documents.NEXTVAL,24,'CNI','CH-ID-2345678904','2023-01-15','2033-01-15','Chancellerie fédérale CH');

-- ============================================================
-- TRANSFERTS (25 transferts)
-- ============================================================
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,1,1,2,DATE '2021-05-20','Changement de zone pour sécurité',2,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,3,4,5,DATE '2022-06-01','Risque identifié zone Marseille',1,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,7,8,9,DATE '2023-01-02','Réorganisation programme Nebula',8,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,9,11,11,DATE '2021-06-15','Déplacement temporaire',6,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,20,20,20,DATE '2022-03-01','Relocalisation procédure corruption',3,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,16,16,16,DATE '2021-06-20','Fuite possible localisation',8,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,12,13,13,DATE '2022-04-20','Menace niveau 5 détectée',14,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,19,19,19,DATE '2021-05-01','Changement identité associé',8,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,26,23,23,DATE '2022-09-01','Integration programme Alpin',3,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,27,24,24,DATE '2022-10-01','Réintégration programme Nebula',7,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,28,25,25,DATE '2023-01-10','Repositionnement Espagne',10,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,29,26,26,DATE '2023-02-01','Repositionnement Suisse',13,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,30,27,27,DATE '2023-03-01','Sécurité renforcée Paris',1,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,22,22,22,DATE '2023-01-15','Menace niveau 3',13,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,6,7,7,DATE '2022-02-01','Renfort sécurité',6,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,8,10,10,DATE '2021-01-20','Repos médical prolongé',3,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,13,14,14,DATE '2019-10-01','Repositionnement Espagne',10,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,15,15,15,DATE '2020-07-15','Déplacement tactique',13,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,18,18,18,DATE '2021-07-01','Réorganisation Granite Shield',1,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,4,6,6,DATE '2021-05-01','Mise en sécurité préventive',4,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,2,3,3,DATE '2020-03-01','Précaution COVID + sécurité',3,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,10,12,12,DATE '2021-08-15','Repositionnement Nebula',6,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,17,17,17,DATE '2022-06-01','Changement zone Madrid',10,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,21,21,21,DATE '2022-06-10','Nouvelles mesures sécurité',6,'EFFECTUE');
INSERT INTO transferts VALUES (seq_transferts.NEXTVAL,31,28,28,DATE '2024-01-15','[CLASSIFIE OMEGA]',1,'EFFECTUE');

-- ============================================================
-- EVALUATIONS DE RISQUE (35 évaluations)
-- ============================================================
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,1,DATE '2019-06-01',72,2,'Exposition médiatique partielle - réseau toujours actif',DATE '2019-12-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,1,DATE '2020-01-15',68,2,'Stabilisation, menace Marchetti confirmée',DATE '2020-07-15');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,2,DATE '2019-08-01',45,4,'Faible risque actuel, cooperation bonne',DATE '2020-02-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,3,DATE '2020-03-01',91,1,'Niveau critique - trois menaces actives',DATE '2020-09-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,3,DATE '2021-01-15',85,1,'Amélioration légère post-relocalisation',DATE '2021-07-15');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,4,DATE '2020-09-01',25,4,'Bonne intégration, risque faible',DATE '2021-03-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,6,DATE '2021-11-01',78,6,'Tentative enlèvement récente, score élevé',DATE '2022-05-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,7,DATE '2020-02-01',88,8,'Cartel actif - protection maximum',DATE '2020-08-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,7,DATE '2021-05-01',82,8,'Toujours niveau critique malgré relocalisation',DATE '2021-11-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,8,DATE '2020-06-01',65,3,'Menace famille en Allemagne',DATE '2020-12-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,9,DATE '2020-11-01',70,6,'Surveillance confirmée',DATE '2021-05-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,10,DATE '2021-04-01',30,11,'Risque stable, témoin coopératif',DATE '2021-10-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,12,DATE '2022-05-01',94,14,'Cartel asiatique - menace extrême',DATE '2022-11-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,13,DATE '2018-10-01',48,10,'Stabilité espagnole correcte',DATE '2019-04-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,15,DATE '2019-07-01',82,13,'Faction ETA - danger réel',DATE '2020-01-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,16,DATE '2021-01-01',87,8,'Cartel actif Ibérique',DATE '2021-07-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,17,DATE '2022-03-01',55,10,'Risque modéré, intégration stable',DATE '2022-09-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,18,DATE '2020-06-01',89,1,'Réseau Greco très actif',DATE '2020-12-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,19,DATE '2020-10-01',91,8,'Cartel et trafic financier',DATE '2021-04-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,20,DATE '2021-07-01',60,3,'Après relocalisation, stable',DATE '2022-01-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,22,DATE '2022-09-01',55,13,'Menace modérée',DATE '2023-03-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,26,DATE '2022-06-01',42,3,'Intégration réussie programme Alpin',DATE '2022-12-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,27,DATE '2022-11-01',73,7,'Cellule Nebula active',DATE '2023-05-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,28,DATE '2023-02-01',58,10,'Stabilité relative',DATE '2023-08-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,29,DATE '2023-03-01',35,13,'Risque faible',DATE '2023-09-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,30,DATE '2023-05-01',85,1,'Cyberattaque BNPT liée',DATE '2023-11-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,1,DATE '2022-04-01',70,2,'Mise à jour annuelle',DATE '2022-10-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,7,DATE '2022-08-01',79,8,'Maintien niveau protection',DATE '2023-02-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,12,DATE '2023-01-01',96,14,'ALERTE MAXIMUM - cyberattaque en cours',DATE '2023-07-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,8,DATE '2021-06-01',62,3,'Stabilisation',DATE '2021-12-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,9,DATE '2022-01-01',68,6,'Légère dégradation',DATE '2022-07-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,15,DATE '2020-07-01',75,13,'Risque maintenu',DATE '2021-01-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,18,DATE '2021-03-01',83,1,'Réseau reconstitué',DATE '2021-09-01');
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,19,DATE '2021-10-01',88,8,'Situation critique maintenue',DATE '2022-04-01');
-- Honeytoken
INSERT INTO evaluations_risque VALUES (seq_evaluations.NEXTVAL,31,DATE '2024-01-01',100,1,'[ULTRA-CLASSIFIE] Risque absolu - identite de niveau etat',DATE '2024-07-01');

-- ============================================================
-- COMMUNICATIONS (40 communications)
-- ============================================================
INSERT INTO communications VALUES (seq_communications.NEXTVAL,1,1,DATE '2019-04-15','Telephone',15,2,'Contact hebdomadaire nominal');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,1,1,DATE '2019-05-22','Telephone',12,2,'RAS');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,2,3,DATE '2019-07-10','Courrier',NULL,3,'Lettre famille - contrôlée');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,3,4,DATE '2020-04-05','Telephone',20,1,'Discussion condition dossier');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,4,5,DATE '2020-10-10','En personne',60,4,'Consultation médicale couverte');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,6,6,DATE '2021-10-25','Videoconference',30,6,'Soutien familial post-tentative enlèvement');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,7,7,DATE '2020-02-01','Telephone',18,8,'Contact nomimal - surveillance active');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,8,8,DATE '2020-09-01','En personne',90,3,'Séance psy bimensuelle');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,9,9,DATE '2020-12-15','Courrier',NULL,6,'Vœux familiaux - validé');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,10,10,DATE '2021-03-10','Videoconference',45,11,'Contact hebdomadaire soeur');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,12,11,DATE '2022-04-20','Telephone',22,14,'Contact bimensuel mère');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,13,12,DATE '2018-11-05','En personne',60,10,'Rendez-vous légal mensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,15,13,DATE '2019-08-15','Videoconference',40,13,'Contact hebdomadaire épouse');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,16,14,DATE '2021-02-01','Courrier',NULL,8,'Lettre père - contrôlée');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,17,15,DATE '2022-01-20','Telephone',25,10,'Contact soeur hebdomadaire');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,18,16,DATE '2020-05-10','Videoconference',50,1,'Stratégie juridique mensuelle');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,19,17,DATE '2020-10-15','Telephone',18,8,'Contact frère bimensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,20,18,DATE '2021-06-20','En personne',75,3,'Visite médicale trimestrielle');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,22,19,DATE '2022-09-15','Courrier',NULL,13,'Lettre père polonais');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,26,20,DATE '2022-05-01','Videoconference',35,3,'Contact père hebdomadaire');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,27,21,DATE '2022-10-01','Telephone',20,7,'Contact oncle mensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,28,22,DATE '2023-01-15','Courrier',NULL,10,'Lettre épouse - validée');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,29,23,DATE '2023-02-10','Videoconference',40,13,'Contact père bimensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,30,24,DATE '2023-03-05','Telephone',25,1,'Contact père hebdomadaire');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,1,25,DATE '2022-06-10','En personne',60,2,'Séance psychiatrique mensuelle');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,7,26,DATE '2022-09-01','Videoconference',35,8,'Stratégie juridique mensuelle');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,12,27,DATE '2023-02-15','Videoconference',45,14,'Droit de la défense mensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,19,28,DATE '2021-12-10','En personne',90,8,'Séance psy bimensuelle');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,3,29,DATE '2022-10-20','Telephone',22,1,'Contact épouse bimensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,8,30,DATE '2023-03-15','Telephone',18,3,'Contact fils mensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,2,3,DATE '2020-02-20','Courrier',NULL,3,'Lettre famille');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,6,6,DATE '2022-01-10','Videoconference',28,6,'Bilan annuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,15,13,DATE '2021-02-10','Videoconference',42,13,'Contact régulier');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,18,16,DATE '2021-11-05','Videoconference',55,1,'Consultation juridique');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,7,7,DATE '2021-08-20','Telephone',14,8,'Alerte émotionnelle - soutien');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,3,4,DATE '2021-06-12','Telephone',19,1,'Mise à jour sécurité');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,9,9,DATE '2021-09-25','Courrier',NULL,6,'Courrier autorisé');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,12,11,DATE '2023-04-10','Telephone',30,14,'Contact bimensuel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,30,24,DATE '2023-06-15','Videoconference',50,1,'Bilan sécurité semestriel');
INSERT INTO communications VALUES (seq_communications.NEXTVAL,22,19,DATE '2023-05-01','Videoconference',38,13,'Contact régulier');

-- ============================================================
-- UTILISATEURS APPLICATIFS (10 utilisateurs)
-- ============================================================
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'admin_sys','ADMIN','CONFIDENTIEL',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'admin_sec','ADMIN','SECRET',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'analyste_01','ANALYSTE','CONFIDENTIEL',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'analyste_02','ANALYSTE','CONFIDENTIEL',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'analyste_03','ANALYSTE','SECRET',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'coord_paris','COORDINATEUR','SECRET',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'coord_lyon','COORDINATEUR','SECRET',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'coord_bruxelles','COORDINATEUR','TOP_SECRET',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'dir_general','DIRECTEUR','TOP_SECRET',1);
INSERT INTO utilisateurs VALUES (seq_utilisateurs.NEXTVAL,'dir_adjoint','DIRECTEUR','TOP_SECRET',1);

-- ============================================================
-- LOGS initiaux (simulation traces)
-- ============================================================
INSERT INTO log_connexions VALUES (seq_log_connexions.NEXTVAL,'bv_analyste',SYSTIMESTAMP - INTERVAL '5' DAY,'192.168.1.45',1);
INSERT INTO log_connexions VALUES (seq_log_connexions.NEXTVAL,'bv_coordinateur',SYSTIMESTAMP - INTERVAL '3' DAY,'10.0.0.22',1);
INSERT INTO log_connexions VALUES (seq_log_connexions.NEXTVAL,'bv_directeur',SYSTIMESTAMP - INTERVAL '2' DAY,'10.0.0.5',1);
INSERT INTO log_connexions VALUES (seq_log_connexions.NEXTVAL,'bv_admin',SYSTIMESTAMP - INTERVAL '1' DAY,'127.0.0.1',1);
INSERT INTO log_connexions VALUES (seq_log_connexions.NEXTVAL,'bv_suspect',SYSTIMESTAMP - INTERVAL '12' HOUR,'185.220.101.5',1);
INSERT INTO log_connexions VALUES (seq_log_connexions.NEXTVAL,'bv_suspect',SYSTIMESTAMP - INTERVAL '10' HOUR,'185.220.101.5',1);

INSERT INTO log_acces_sensibles VALUES (seq_log_acces.NEXTVAL,'bv_analyste','EVALUATIONS_RISQUE','SELECT',SYSTIMESTAMP - INTERVAL '5' DAY,'Consultation scores de risque');
INSERT INTO log_acces_sensibles VALUES (seq_log_acces.NEXTVAL,'bv_coordinateur','TEMOINS','UPDATE',SYSTIMESTAMP - INTERVAL '3' DAY,'Mise à jour statut temoin BVT-2020-003');
INSERT INTO log_acces_sensibles VALUES (seq_log_acces.NEXTVAL,'bv_directeur','IDENTITES_REELLES','SELECT',SYSTIMESTAMP - INTERVAL '2' DAY,'Consultation identité réelle dossier 7');

-- ============================================================
-- DONNEES POLYINSTANCIATION (4 versions par temoin critique)
-- ============================================================
-- Temoin 7 (NBL-2019-007, CRITIQUE) - 4 versions de localisation
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,7,'TOP_SECRET','SAFE_HOUSE','CLASSIFIE','Suisse','Route des Acacias 14, Satigny, Genève - Bunker B',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,7,'SECRET','APPARTEMENT','Région Léman','Suisse','Appartement sécurisé - zone ouest',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,7,'CONFIDENTIEL','APPARTEMENT','Europe occidentale','Europe','Localisation non divulguée',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,7,'LEURRE','HOTEL','Paris','France','Hotel de Crillon, 10 Place de la Concorde',1);

-- Temoin 3 (BVT-2020-003, relocalise en Espagne) - 4 versions
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,3,'TOP_SECRET','ETRANGER','Barcelone','Espagne','Carrer de les Flors 18, Apto 4B, 08001 Barcelona',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,3,'SECRET','ETRANGER','Zone Méditerranée','Espagne','Localisation sécurisée zone Med-Est',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,3,'CONFIDENTIEL','ETRANGER','Espagne','Espagne','Statut : en transit',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,3,'LEURRE','SAFE_HOUSE','Madrid','Espagne','Calle Gran Via 50, Centro, Madrid',1);

-- Temoin 19 (GRS-2020-019, CRITIQUE) - 4 versions
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,19,'TOP_SECRET','APPARTEMENT','Zurich','Suisse','Bahnhofstrasse 42, 2ème étage, 8001 Zurich',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,19,'SECRET','APPARTEMENT','Zone Zurich','Suisse','Centre urbain, identité couverte',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,19,'CONFIDENTIEL','APPARTEMENT','Suisse centrale','Suisse','Données confidentielles',0);
INSERT INTO localisations_poly VALUES (seq_poly.NEXTVAL,19,'LEURRE','HOTEL','Genève','Suisse','Hôtel Beau-Rivage, Quai du Mont-Blanc 13',1);

-- ============================================================
-- DONNEES LEURRE (piéges pour attaquants)
-- ============================================================
INSERT INTO leurre_admin_credentials VALUES (1,'BLACKVAULT_SA','$2b$12$Kh.Fake.Hash.Admin.9xVy','SUPER_ADMIN',DATE '2024-06-28','Master account - DO NOT SHARE');
INSERT INTO leurre_admin_credentials VALUES (2,'sys_backup','$2b$12$Fake.Backup.Hash.7mZq','ADMIN',DATE '2024-06-20','Backup restoration account');
INSERT INTO leurre_admin_credentials VALUES (3,'dba_emergency','$2b$12$Emergency.Fake.Hash.3kWx','DBA',DATE '2024-06-15','Emergency access - classified');
INSERT INTO leurre_admin_credentials VALUES (4,'audit_readonly','$2b$12$Audit.Fake.Hash.5pTr','READONLY',DATE '2024-06-25','Audit trail access');

INSERT INTO leurre_witness_master_list VALUES (1,'GHOST-01','[DECOY] Jean Fictif','12 rue Fausse, Paris','CRITIQUE','AFF-DECOY-001');
INSERT INTO leurre_witness_master_list VALUES (2,'SHADOW-02','[DECOY] Marie Inventée','Adresse leurre 2','ELEVE','AFF-DECOY-002');
INSERT INTO leurre_witness_master_list VALUES (3,'AEGIS-OMEGA','[LEURRE] OMEGA PRIME','ULTRA-SECRET BUNKER ALPHA-7','CRITIQUE','AFF-2024-020');
INSERT INTO leurre_witness_master_list VALUES (4,'NEBULA-04','[DECOY] Klaus Fictif','Localisation cachée','MODERE','AFF-DECOY-004');

INSERT INTO leurre_backup_encryption_keys VALUES (1,'MASTER_KEY_2024','[LEURRE]AAAA1234BBBB5678CCCC9012DDDD3456EEEE7890FFFF1234','AES-256',DATE '2024-01-01',DATE '2025-01-01');
INSERT INTO leurre_backup_encryption_keys VALUES (2,'ARCHIVE_KEY_2023','[LEURRE]DEAD1234BEEF5678CAFE9012BABE3456FACE7890DADA1234','AES-256',DATE '2023-01-01',DATE '2024-01-01');
INSERT INTO leurre_backup_encryption_keys VALUES (3,'EMERGENCY_KEY','[LEURRE]F00D1234C0DE5678B00B9012D00D3456F00F7890A1B2C3D4','RSA-4096',DATE '2020-01-01',DATE '2030-01-01');

COMMIT;

PROMPT ========================================
PROMPT Donnees fictives inserees avec succes.
PROMPT Total approximatif : 400+ lignes
PROMPT Ordre suivant : 03_plsql.sql
PROMPT ========================================
