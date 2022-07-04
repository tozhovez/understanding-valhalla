DROP TABLE IF EXISTS "actors";
DROP SEQUENCE IF EXISTS "actors_actorId_seq";
DROP TABLE IF EXISTS "characters";
DROP SEQUENCE IF EXISTS "characters_characterId_seq";
DROP TABLE IF EXISTS "images";
DROP SEQUENCE IF EXISTS "images_imageId_seq";
DROP TABLE IF EXISTS "raw_data";
DROP SEQUENCE IF EXISTS "raw_data_rawId_seq";
DROP TABLE IF EXISTS "src_data";
DROP SEQUENCE IF EXISTS "src_data_src_dataId_seq";


CREATE SEQUENCE "src_data_src_dataId_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;
CREATE SEQUENCE "raw_data_rawId_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;
CREATE SEQUENCE "images_imageId_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;
CREATE SEQUENCE "characters_characterId_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;
CREATE SEQUENCE "actors_actorId_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;

CREATE TABLE "public"."actors" (
    "actorId" integer DEFAULT nextval('"actors_actorId_seq"') NOT NULL,
    "actor_name" character varying(50) NOT NULL,
    "actor_description" text,
    CONSTRAINT "actors_pkey" PRIMARY KEY ("actorId")
) WITH (oids = false);



CREATE TABLE "public"."characters" (
    "characterId" integer DEFAULT nextval('"characters_characterId_seq"') NOT NULL,
    "character_name" character varying NOT NULL,
    "character_description" text,
    CONSTRAINT "characters_pkey" PRIMARY KEY ("characterId")
) WITH (oids = false);




CREATE TABLE "public"."images" (
    "imageId" integer DEFAULT nextval('"images_imageId_seq"') NOT NULL,
    "image_name" character varying(250) NOT NULL,
    "image_description" text,
    CONSTRAINT "images_pkey" PRIMARY KEY ("imageId")
) WITH (oids = false);




CREATE TABLE "public"."raw_data" (
    "rawId" integer DEFAULT nextval('"raw_data_rawId_seq"') NOT NULL,
    "url" text NOT NULL,
    "path" text NOT NULL,
    "html" text NOT NULL,
    CONSTRAINT "raw_data_pkey" PRIMARY KEY ("rawId")
) WITH (oids = false);



CREATE TABLE "public"."src_data" (
    "src_dataId" integer DEFAULT nextval('"src_data_src_dataId_seq"') NOT NULL,
    "src_name" character varying NOT NULL,
    "src_description" text,
    CONSTRAINT "src_data_pkey" PRIMARY KEY ("src_dataId")
) WITH (oids = false);



