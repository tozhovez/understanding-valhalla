
DROP TABLE IF EXISTS "actors";
DROP SEQUENCE IF EXISTS "actors_actorId_seq";
DROP TABLE IF EXISTS "characters";
DROP SEQUENCE IF EXISTS "characters_characterId_seq";
DROP TABLE IF EXISTS "images";
DROP TABLE IF EXISTS "in_images";
DROP SEQUENCE IF EXISTS "images_imageId_seq";
DROP TABLE IF EXISTS "raw_data";
DROP TABLE IF EXISTS "raw_src_data";
DROP SEQUENCE IF EXISTS "raw_data_rawId_seq";
DROP TABLE IF EXISTS "src_data";
DROP SEQUENCE IF EXISTS "src_data_src_dataId_seq";
DROP TABLE IF EXISTS "src_data_actors_characters";
DROP SEQUENCE IF EXISTS "src_data_actors_characters_seqid_seq";


CREATE SEQUENCE "src_data_src_dataId_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1;
CREATE SEQUENCE "raw_data_rawId_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1;
CREATE SEQUENCE "images_imageId_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1;
CREATE SEQUENCE "characters_characterId_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1;
CREATE SEQUENCE "actors_actorId_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1;
CREATE SEQUENCE "src_data_actors_characters_seqid_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1;



CREATE TABLE "public"."actors" (
    "actorId" integer DEFAULT nextval('"actors_actorId_seq"') NOT NULL,
    "actor_name" character varying(50) NOT NULL,
    "actor_description" text,
    CONSTRAINT "actors_actor_name" UNIQUE ("actor_name"),
    CONSTRAINT "actors_pkey" PRIMARY KEY ("actorId")
) WITH (oids = false);



CREATE TABLE "public"."characters" (
    "characterId" integer DEFAULT nextval('"characters_characterId_seq"') NOT NULL,
    "character_name" character varying NOT NULL,
    "character_description" text,
    CONSTRAINT "characters_character_name" UNIQUE ("character_name"),
    CONSTRAINT "characters_pkey" PRIMARY KEY ("characterId")
) WITH (oids = false);




CREATE TABLE "public"."images" (
    "imageId" integer DEFAULT nextval('"images_imageId_seq"') NOT NULL,
    "image_name" character varying(250) NOT NULL,
    "image_description" text,
    "image_path" text,
    CONSTRAINT "images_image_name" UNIQUE ("image_name"),
    CONSTRAINT "images_pkey" PRIMARY KEY ("imageId")
) WITH (oids = false);



CREATE TABLE "public"."in_images" (
    "seqid" integer NOT NULL,
    "imageId" integer NOT NULL,
    CONSTRAINT "in_images_seqid_imageId" UNIQUE ("seqid", "imageId")
) WITH (oids = false);




CREATE TABLE "public"."raw_data" (
    "rawId" integer DEFAULT nextval('"raw_data_rawId_seq"') NOT NULL,
    "url" text NOT NULL,
    "path" text,
    "html" text,
    CONSTRAINT "raw_data_pkey" PRIMARY KEY ("rawId"),
    CONSTRAINT "raw_data_url" UNIQUE ("url")
) WITH (oids = false);




CREATE TABLE "public"."raw_src_data" (
    "src_dataId" integer NOT NULL,
    "rawId" integer NOT NULL,
    "date_updated" timestamp NOT NULL,
    "state" boolean NOT NULL,
    CONSTRAINT "raw_src_data_src_dataId_rawId" PRIMARY KEY ("src_dataId", "rawId")
) WITH (oids = false);




CREATE TABLE "public"."src_data" (
    "src_dataId" integer DEFAULT nextval('"src_data_src_dataId_seq"') NOT NULL,
    "src_name" character varying NOT NULL,
    "src_description" text,
    "src_url" text,
    CONSTRAINT "src_data_pkey" PRIMARY KEY ("src_dataId"),
    CONSTRAINT "src_data_src_url" UNIQUE ("src_url")
) WITH (oids = false);



CREATE TABLE "public"."src_data_actors_characters" (
    "src_dataId" integer NOT NULL,
    "actorId" integer NOT NULL,
    "characterId" integer NOT NULL,
    "seqid" integer DEFAULT nextval('src_data_actors_characters_seqid_seq') NOT NULL,
    CONSTRAINT "src_data_actors_characters_pkey" PRIMARY KEY ("seqid"),
    CONSTRAINT "src_data_actors_characters_src_dataId_actorId_characterId" UNIQUE ("src_dataId", "actorId", "characterId")
) WITH (oids = false);



CREATE INDEX "actors_actorId_actor_name" ON "public"."actors" USING btree ("actorId", "actor_name");
CREATE INDEX "images_imageId_image_name" ON "public"."images" USING btree ("imageId", "image_name");
CREATE INDEX "raw_data_rawId_url" ON "public"."raw_data" USING btree ("rawId", "url");
CREATE INDEX "src_data_src_dataId_src_url" ON "public"."src_data" USING btree ("src_dataId", "src_url");
CREATE INDEX "characters_characterId_character_name" ON "public"."characters" USING btree ("characterId", "character_name");

ALTER TABLE ONLY "public"."in_images" ADD CONSTRAINT "in_images_imageId_fkey" FOREIGN KEY ("imageId") REFERENCES images("imageId") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;
ALTER TABLE ONLY "public"."in_images" ADD CONSTRAINT "in_images_seqid_fkey" FOREIGN KEY (seqid) REFERENCES src_data_actors_characters(seqid) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."raw_src_data" ADD CONSTRAINT "raw_src_data_rawId_fkey" FOREIGN KEY ("rawId") REFERENCES raw_data("rawId") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;
ALTER TABLE ONLY "public"."raw_src_data" ADD CONSTRAINT "raw_src_data_src_dataId_fkey1" FOREIGN KEY ("src_dataId") REFERENCES src_data("src_dataId") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."src_data_actors_characters" ADD CONSTRAINT "src_data_actors_characters_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES actors("actorId") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;
ALTER TABLE ONLY "public"."src_data_actors_characters" ADD CONSTRAINT "src_data_actors_characters_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES characters("characterId") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;
ALTER TABLE ONLY "public"."src_data_actors_characters" ADD CONSTRAINT "src_data_actors_characters_src_dataId_fkey1" FOREIGN KEY ("src_dataId") REFERENCES src_data("src_dataId") ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;


INSERT INTO "src_data" ("src_dataId", "src_name", "src_description", "src_url") VALUES
(2,	'Norsemen TV series',	'Norsemen is a Norwegian comedy television series about a group of Vikings living in the village of Norheim around the year 790. It originally premiered in Norway under the name Vikingane (The Vikings) on NRK1 in October 2016. It is produced for NRK by Viafilm. The series is written and directed by Jon Iver Helgaker and Jonas Torgersen. The series is filmed in the village of Avaldsnes in Karmøy municipality, Rogaland, Norway, and it was recorded simultaneously in both Norwegian and English-language versions by filming each scene twice. The first season of the English version was made available on Netflix in August 2017 under the name Norsemen, and season two was made available in October 2018. The second season was filmed in early 2017. The third season is named ''Season 0'', as it tells the story that led up to Season 1. In September 2020, it was announced that the show had been canceled and would not return for a fourth season.',	'https://en.wikipedia.org/wiki/Norsemen_(TV_series)'),
(1,	'Vikings TV series',	'Bjorn Ironside has ambitions for the Kingdom of Kattegat, he dreams of peace and prosperity, but the fates have a different plan for the new King. A threat is looming, an enemy is resurgent–so much more ruthless than the rest. Lagertha too has dreams, to bury her sword and return to a simple life. But as enemy forces gather, Bjorn and Lagertha will rise to the challenge, because they are Viking heroes and can never surrender.',	'https://www.history.com/shows/vikings/cast'),
(3,	'Vikings NFL team',	'The Official Site of the Minnesota Vikings',	'https://www.vikings.com/team/players-roster'),
(5,	'Norsemen TV series',	'Norsemen is a Norwegian comedy television series about a group of Vikings living in the village of Norheim around the year 790. It originally premiered in Norway under the name Vikingane (The Vikings) on NRK1 in October 2016. It is produced for NRK by Viafilm. The series is written and directed by Jon Iver Helgaker and Jonas Torgersen. The series is filmed in the village of Avaldsnes in Karmøy municipality, Rogaland, Norway, and it was recorded simultaneously in both Norwegian and English-language versions by filming each scene twice. The first season of the English version was made available on Netflix in August 2017 under the name Norsemen, and season two was made available in October 2018. The second season was filmed in early 2017. The third season is named ''Season 0'', as it tells the story that led up to Season 1. In September 2020, it was announced that the show had been canceled and would not return for a fourth season.',	'https://www.imdb.com/title/tt5905354/');



insert into actors (actor_name) values ('Travis Fimmel');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_ragnar_16_9.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/ragnar');
insert into characters (character_name) values ('Ragnar');
insert into actors (actor_name) values ('Katheryn Winnick');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_lagertha.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/lagertha');
insert into characters (character_name) values ('Lagertha');
insert into actors (actor_name) values ('Moe Dunford');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_aethelwulf.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/aethelwulf');
insert into characters (character_name) values ('Aethelwulf');
insert into actors (actor_name) values ('Josefin Asplund');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/11/vikings_4b_cast_astrid.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/astrid');
insert into characters (character_name) values ('Astrid');
insert into actors (actor_name) values ('Alexander Ludwig');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_bjorn.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/bjorn');
insert into characters (character_name) values ('Bjorn');
insert into actors (actor_name) values ('Lothaire Bluteau');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_charles.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/emperor-charles');
insert into characters (character_name) values ('Emperor Charles');
insert into actors (actor_name) values ('Gustaf Skarsgard');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_floki.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/floki');
insert into characters (character_name) values ('Floki');
insert into actors (actor_name) values ('Jasper Paakkonen');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_halfdan.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/halfdan-the-black');
 insert into characters (character_name) values ('Halfdan the Black'); 
insert into actors (actor_name) values ('Marco Ilso');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/11/vikings_4b_cast_hvitserk.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/hvitserk');
insert into characters (character_name) values ('Hvitserk');
insert into actors (actor_name) values ('Alex Hogh Andersen');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/11/vikings_4b_cast_ivar.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/ivar-the-boneless');
insert into characters (character_name) values ('Ivar the Boneless');
insert into actors (actor_name) values ('Jennie Jacques');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_judith.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/judith');
insert into characters (character_name) values ('Judith');
insert into actors (actor_name) values ('Linus Roache');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_s3_ecbert.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/king-ecbert');
 insert into characters (character_name) values ('King Ecbert'); 
insert into actors (actor_name) values ('Peter Franzen');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_harald.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/king-harald-finehair');
insert into characters (character_name) values ('King Harald Finehair');
insert into actors (actor_name) values ('Morgane Polanski');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_gisla_.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/princess-gisla');
 insert into characters (character_name) values ('Princess Gisla'); 
insert into actors (actor_name) values ('Alyssa Sutherland');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_aslaug_16_9.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/queen-aslaug');
insert into characters (character_name) values ('Queen Aslaug');
insert into actors (actor_name) values ('Clive Standen');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_rollo.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/rollo');
insert into characters (character_name) values ('Rollo'); 
insert into actors (actor_name) values ('David Lindstroom');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/11/vikings_4b_cast_sigurd.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/sigurd-snake-in-the-eye');
insert into characters (character_name) values ('Sigurd Snake in the Eye');
insert into actors (actor_name) values ('Jordan Patrick Smith');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/11/vikings_4b_cast_ubbe.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/ubbe');
 insert into characters (character_name) values ('Ubbe'); 
insert into actors (actor_name) values ('John Kavanagh');
insert into images (image_name) values ('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites/2/2016/10/vikings_season4_cast_seer.jpg?w=840');
insert into raw_data (url) values ('https://www.history.com/shows/vikings/cast/the-seer');
insert into characters (character_name) values ('The Seer');

