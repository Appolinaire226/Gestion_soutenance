--
-- PostgreSQL database dump
--

\restrict sZzgnp62ijFz8dxrNZVcfRMd1R6bqs2peUsAbfUKDYG5Gf25KA7kO8BJEHIlYPH

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: jury; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA jury;


ALTER SCHEMA jury OWNER TO postgres;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: disponibilite; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.disponibilite (
    id_disponibilite integer NOT NULL,
    id_enseignant integer NOT NULL,
    id_session integer NOT NULL,
    date_debut timestamp without time zone NOT NULL,
    date_fin timestamp without time zone NOT NULL,
    CONSTRAINT chk_dispo_dates CHECK ((date_fin > date_debut))
);


ALTER TABLE jury.disponibilite OWNER TO postgres;

--
-- Name: disponibilite_id_disponibilite_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.disponibilite_id_disponibilite_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.disponibilite_id_disponibilite_seq OWNER TO postgres;

--
-- Name: disponibilite_id_disponibilite_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.disponibilite_id_disponibilite_seq OWNED BY jury.disponibilite.id_disponibilite;


--
-- Name: enseignant; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.enseignant (
    id_enseignant integer NOT NULL,
    matricule character varying(20) NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    grade character varying(50),
    specialite character varying(100),
    email character varying(150),
    telephone character varying(20),
    statut character varying(30) DEFAULT 'actif'::character varying NOT NULL,
    CONSTRAINT enseignant_statut_check CHECK (((statut)::text = ANY ((ARRAY['actif'::character varying, 'inactif'::character varying, 'congé'::character varying])::text[])))
);


ALTER TABLE jury.enseignant OWNER TO postgres;

--
-- Name: enseignant_id_enseignant_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.enseignant_id_enseignant_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.enseignant_id_enseignant_seq OWNER TO postgres;

--
-- Name: enseignant_id_enseignant_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.enseignant_id_enseignant_seq OWNED BY jury.enseignant.id_enseignant;


--
-- Name: etudiant; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.etudiant (
    id_etudiant integer NOT NULL,
    matricule character varying(20) NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    date_naissance date,
    email character varying(150),
    telephone character varying(20),
    id_filiere integer NOT NULL
);


ALTER TABLE jury.etudiant OWNER TO postgres;

--
-- Name: etudiant_id_etudiant_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.etudiant_id_etudiant_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.etudiant_id_etudiant_seq OWNER TO postgres;

--
-- Name: etudiant_id_etudiant_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.etudiant_id_etudiant_seq OWNED BY jury.etudiant.id_etudiant;


--
-- Name: filiere; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.filiere (
    id_filiere integer NOT NULL,
    code_filiere character varying(10) NOT NULL,
    libelle character varying(100) NOT NULL,
    description text
);


ALTER TABLE jury.filiere OWNER TO postgres;

--
-- Name: filiere_id_filiere_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.filiere_id_filiere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.filiere_id_filiere_seq OWNER TO postgres;

--
-- Name: filiere_id_filiere_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.filiere_id_filiere_seq OWNED BY jury.filiere.id_filiere;


--
-- Name: jury; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.jury (
    id_jury integer NOT NULL,
    id_programme integer NOT NULL,
    id_enseignant integer NOT NULL,
    role_jury character varying(30) NOT NULL,
    present boolean DEFAULT false NOT NULL,
    CONSTRAINT jury_role_jury_check CHECK (((role_jury)::text = ANY ((ARRAY['président'::character varying, 'rapporteur'::character varying, 'examinateur'::character varying, 'directeur'::character varying])::text[])))
);


ALTER TABLE jury.jury OWNER TO postgres;

--
-- Name: jury_id_jury_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.jury_id_jury_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.jury_id_jury_seq OWNER TO postgres;

--
-- Name: jury_id_jury_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.jury_id_jury_seq OWNED BY jury.jury.id_jury;


--
-- Name: participation_jury; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.participation_jury (
    id_participation integer NOT NULL,
    id_jury integer NOT NULL,
    a_participe boolean DEFAULT false NOT NULL,
    motif_absence text,
    date_confirmation timestamp without time zone DEFAULT now()
);


ALTER TABLE jury.participation_jury OWNER TO postgres;

--
-- Name: participation_jury_id_participation_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.participation_jury_id_participation_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.participation_jury_id_participation_seq OWNER TO postgres;

--
-- Name: participation_jury_id_participation_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.participation_jury_id_participation_seq OWNED BY jury.participation_jury.id_participation;


--
-- Name: programme; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.programme (
    id_programme integer NOT NULL,
    id_session integer NOT NULL,
    id_rapport integer NOT NULL,
    id_salle integer NOT NULL,
    date_heure timestamp without time zone NOT NULL,
    duree_minutes integer DEFAULT 45 NOT NULL,
    statut character varying(30) DEFAULT 'proposé'::character varying NOT NULL,
    CONSTRAINT programme_duree_minutes_check CHECK ((duree_minutes > 0)),
    CONSTRAINT programme_statut_check CHECK (((statut)::text = ANY ((ARRAY['proposé'::character varying, 'validé'::character varying, 'annulé'::character varying, 'réalisé'::character varying])::text[])))
);


ALTER TABLE jury.programme OWNER TO postgres;

--
-- Name: programme_id_programme_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.programme_id_programme_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.programme_id_programme_seq OWNER TO postgres;

--
-- Name: programme_id_programme_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.programme_id_programme_seq OWNED BY jury.programme.id_programme;


--
-- Name: rapport; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.rapport (
    id_rapport integer NOT NULL,
    titre character varying(255) NOT NULL,
    resume text,
    fichier_url character varying(300),
    date_depot timestamp without time zone DEFAULT now() NOT NULL,
    id_etudiant integer NOT NULL,
    id_session integer NOT NULL,
    statut character varying(30) DEFAULT 'déposé'::character varying NOT NULL,
    CONSTRAINT rapport_statut_check CHECK (((statut)::text = ANY ((ARRAY['déposé'::character varying, 'validé'::character varying, 'soutenu'::character varying])::text[])))
);


ALTER TABLE jury.rapport OWNER TO postgres;

--
-- Name: rapport_id_rapport_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.rapport_id_rapport_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.rapport_id_rapport_seq OWNER TO postgres;

--
-- Name: rapport_id_rapport_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.rapport_id_rapport_seq OWNED BY jury.rapport.id_rapport;


--
-- Name: resultat; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.resultat (
    id_resultat integer NOT NULL,
    id_programme integer NOT NULL,
    mention character varying(30),
    note numeric(4,2),
    observation text,
    date_deliberation timestamp without time zone DEFAULT now() NOT NULL,
    enregistre_par integer,
    CONSTRAINT resultat_mention_check CHECK (((mention)::text = ANY ((ARRAY['très_bien'::character varying, 'bien'::character varying, 'assez_bien'::character varying, 'passable'::character varying, 'ajourné'::character varying])::text[]))),
    CONSTRAINT resultat_note_check CHECK (((note >= (0)::numeric) AND (note <= (20)::numeric)))
);


ALTER TABLE jury.resultat OWNER TO postgres;

--
-- Name: resultat_id_resultat_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.resultat_id_resultat_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.resultat_id_resultat_seq OWNER TO postgres;

--
-- Name: resultat_id_resultat_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.resultat_id_resultat_seq OWNED BY jury.resultat.id_resultat;


--
-- Name: salle; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.salle (
    id_salle integer NOT NULL,
    nom_salle character varying(50) NOT NULL,
    capacite integer NOT NULL,
    batiment character varying(50),
    equipements text,
    CONSTRAINT salle_capacite_check CHECK ((capacite > 0))
);


ALTER TABLE jury.salle OWNER TO postgres;

--
-- Name: salle_id_salle_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.salle_id_salle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.salle_id_salle_seq OWNER TO postgres;

--
-- Name: salle_id_salle_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.salle_id_salle_seq OWNED BY jury.salle.id_salle;


--
-- Name: session; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.session (
    id_session integer NOT NULL,
    libelle character varying(150) NOT NULL,
    annee_academique character varying(10) NOT NULL,
    date_debut date NOT NULL,
    date_fin date NOT NULL,
    statut character varying(20) DEFAULT 'planifiée'::character varying NOT NULL,
    CONSTRAINT chk_dates CHECK ((date_fin >= date_debut)),
    CONSTRAINT session_statut_check CHECK (((statut)::text = ANY ((ARRAY['planifiée'::character varying, 'en_cours'::character varying, 'cloturée'::character varying])::text[])))
);


ALTER TABLE jury.session OWNER TO postgres;

--
-- Name: session_id_session_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.session_id_session_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.session_id_session_seq OWNER TO postgres;

--
-- Name: session_id_session_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.session_id_session_seq OWNED BY jury.session.id_session;


--
-- Name: validation_programme; Type: TABLE; Schema: jury; Owner: postgres
--

CREATE TABLE jury.validation_programme (
    id_validation integer NOT NULL,
    id_programme integer NOT NULL,
    id_enseignant integer NOT NULL,
    date_validation timestamp without time zone DEFAULT now() NOT NULL,
    statut character varying(20) DEFAULT 'en_attente'::character varying NOT NULL,
    commentaire text,
    CONSTRAINT validation_programme_statut_check CHECK (((statut)::text = ANY ((ARRAY['en_attente'::character varying, 'approuvé'::character varying, 'réfusé'::character varying])::text[])))
);


ALTER TABLE jury.validation_programme OWNER TO postgres;

--
-- Name: validation_programme_id_validation_seq; Type: SEQUENCE; Schema: jury; Owner: postgres
--

CREATE SEQUENCE jury.validation_programme_id_validation_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE jury.validation_programme_id_validation_seq OWNER TO postgres;

--
-- Name: validation_programme_id_validation_seq; Type: SEQUENCE OWNED BY; Schema: jury; Owner: postgres
--

ALTER SEQUENCE jury.validation_programme_id_validation_seq OWNED BY jury.validation_programme.id_validation;


--
-- Name: vue_composition_jury; Type: VIEW; Schema: jury; Owner: postgres
--

CREATE VIEW jury.vue_composition_jury AS
 SELECT ps.id_programme,
    ps.date_heure,
    (((e_etud.nom)::text || ''::text) || (e_etud.prenom)::text) AS etudiant,
    r.titre,
    (((ens.nom)::text || ''::text) || (ens.prenom)::text) AS membre_jury,
    ens.grade,
    j.role_jury,
    j.present
   FROM ((((jury.jury j
     JOIN jury.programme ps ON ((j.id_programme = ps.id_programme)))
     JOIN jury.rapport r ON ((ps.id_rapport = r.id_rapport)))
     JOIN jury.etudiant e_etud ON ((r.id_etudiant = e_etud.id_etudiant)))
     JOIN jury.enseignant ens ON ((j.id_enseignant = ens.id_enseignant)))
  ORDER BY ps.date_heure, j.role_jury;


ALTER VIEW jury.vue_composition_jury OWNER TO postgres;

--
-- Name: vue_programme_complet; Type: VIEW; Schema: jury; Owner: postgres
--

CREATE VIEW jury.vue_programme_complet AS
 SELECT ps.id_programme,
    ss.libelle AS session,
    ss.annee_academique,
    ps.date_heure,
    ps.duree_minutes,
    s.nom_salle,
    s.batiment,
    e.matricule AS matricule_etudiant,
    (((e.nom)::text || ''::text) || (e.prenom)::text) AS etudiant,
    r.titre AS titre_rapport,
    ps.statut AS statut_soutenance
   FROM ((((jury.programme ps
     JOIN jury.session ss ON ((ps.id_session = ss.id_session)))
     JOIN jury.rapport r ON ((ps.id_rapport = r.id_rapport)))
     JOIN jury.etudiant e ON ((r.id_etudiant = e.id_etudiant)))
     JOIN jury.salle s ON ((ps.id_salle = s.id_salle)))
  ORDER BY ps.date_heure;


ALTER VIEW jury.vue_programme_complet OWNER TO postgres;

--
-- Name: vue_resultats; Type: VIEW; Schema: jury; Owner: postgres
--

CREATE VIEW jury.vue_resultats AS
 SELECT ss.libelle AS session,
    ss.annee_academique,
    e.matricule,
    (((e.nom)::text || ''::text) || (e.prenom)::text) AS etudiant,
    r.titre,
    rs.note,
    rs.mention,
    rs.observation,
    rs.date_deliberation
   FROM ((((jury.resultat rs
     JOIN jury.programme ps ON ((rs.id_programme = ps.id_programme)))
     JOIN jury.session ss ON ((ps.id_session = ss.id_session)))
     JOIN jury.rapport r ON ((ps.id_rapport = r.id_rapport)))
     JOIN jury.etudiant e ON ((r.id_etudiant = e.id_etudiant)))
  ORDER BY ss.date_debut, e.nom;


ALTER VIEW jury.vue_resultats OWNER TO postgres;

--
-- Name: disponibilite id_disponibilite; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.disponibilite ALTER COLUMN id_disponibilite SET DEFAULT nextval('jury.disponibilite_id_disponibilite_seq'::regclass);


--
-- Name: enseignant id_enseignant; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.enseignant ALTER COLUMN id_enseignant SET DEFAULT nextval('jury.enseignant_id_enseignant_seq'::regclass);


--
-- Name: etudiant id_etudiant; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.etudiant ALTER COLUMN id_etudiant SET DEFAULT nextval('jury.etudiant_id_etudiant_seq'::regclass);


--
-- Name: filiere id_filiere; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.filiere ALTER COLUMN id_filiere SET DEFAULT nextval('jury.filiere_id_filiere_seq'::regclass);


--
-- Name: jury id_jury; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.jury ALTER COLUMN id_jury SET DEFAULT nextval('jury.jury_id_jury_seq'::regclass);


--
-- Name: participation_jury id_participation; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.participation_jury ALTER COLUMN id_participation SET DEFAULT nextval('jury.participation_jury_id_participation_seq'::regclass);


--
-- Name: programme id_programme; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.programme ALTER COLUMN id_programme SET DEFAULT nextval('jury.programme_id_programme_seq'::regclass);


--
-- Name: rapport id_rapport; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.rapport ALTER COLUMN id_rapport SET DEFAULT nextval('jury.rapport_id_rapport_seq'::regclass);


--
-- Name: resultat id_resultat; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.resultat ALTER COLUMN id_resultat SET DEFAULT nextval('jury.resultat_id_resultat_seq'::regclass);


--
-- Name: salle id_salle; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.salle ALTER COLUMN id_salle SET DEFAULT nextval('jury.salle_id_salle_seq'::regclass);


--
-- Name: session id_session; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.session ALTER COLUMN id_session SET DEFAULT nextval('jury.session_id_session_seq'::regclass);


--
-- Name: validation_programme id_validation; Type: DEFAULT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.validation_programme ALTER COLUMN id_validation SET DEFAULT nextval('jury.validation_programme_id_validation_seq'::regclass);


--
-- Data for Name: disponibilite; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.disponibilite (id_disponibilite, id_enseignant, id_session, date_debut, date_fin) FROM stdin;
\.


--
-- Data for Name: enseignant; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.enseignant (id_enseignant, matricule, nom, prenom, grade, specialite, email, telephone, statut) FROM stdin;
\.


--
-- Data for Name: etudiant; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.etudiant (id_etudiant, matricule, nom, prenom, date_naissance, email, telephone, id_filiere) FROM stdin;
\.


--
-- Data for Name: filiere; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.filiere (id_filiere, code_filiere, libelle, description) FROM stdin;
\.


--
-- Data for Name: jury; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.jury (id_jury, id_programme, id_enseignant, role_jury, present) FROM stdin;
\.


--
-- Data for Name: participation_jury; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.participation_jury (id_participation, id_jury, a_participe, motif_absence, date_confirmation) FROM stdin;
\.


--
-- Data for Name: programme; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.programme (id_programme, id_session, id_rapport, id_salle, date_heure, duree_minutes, statut) FROM stdin;
\.


--
-- Data for Name: rapport; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.rapport (id_rapport, titre, resume, fichier_url, date_depot, id_etudiant, id_session, statut) FROM stdin;
\.


--
-- Data for Name: resultat; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.resultat (id_resultat, id_programme, mention, note, observation, date_deliberation, enregistre_par) FROM stdin;
\.


--
-- Data for Name: salle; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.salle (id_salle, nom_salle, capacite, batiment, equipements) FROM stdin;
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.session (id_session, libelle, annee_academique, date_debut, date_fin, statut) FROM stdin;
\.


--
-- Data for Name: validation_programme; Type: TABLE DATA; Schema: jury; Owner: postgres
--

COPY jury.validation_programme (id_validation, id_programme, id_enseignant, date_validation, statut, commentaire) FROM stdin;
\.


--
-- Name: disponibilite_id_disponibilite_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.disponibilite_id_disponibilite_seq', 1, false);


--
-- Name: enseignant_id_enseignant_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.enseignant_id_enseignant_seq', 1, false);


--
-- Name: etudiant_id_etudiant_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.etudiant_id_etudiant_seq', 1, false);


--
-- Name: filiere_id_filiere_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.filiere_id_filiere_seq', 1, false);


--
-- Name: jury_id_jury_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.jury_id_jury_seq', 1, false);


--
-- Name: participation_jury_id_participation_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.participation_jury_id_participation_seq', 1, false);


--
-- Name: programme_id_programme_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.programme_id_programme_seq', 1, false);


--
-- Name: rapport_id_rapport_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.rapport_id_rapport_seq', 1, false);


--
-- Name: resultat_id_resultat_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.resultat_id_resultat_seq', 1, false);


--
-- Name: salle_id_salle_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.salle_id_salle_seq', 1, false);


--
-- Name: session_id_session_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.session_id_session_seq', 1, false);


--
-- Name: validation_programme_id_validation_seq; Type: SEQUENCE SET; Schema: jury; Owner: postgres
--

SELECT pg_catalog.setval('jury.validation_programme_id_validation_seq', 1, false);


--
-- Name: disponibilite disponibilite_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.disponibilite
    ADD CONSTRAINT disponibilite_pkey PRIMARY KEY (id_disponibilite);


--
-- Name: enseignant enseignant_email_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.enseignant
    ADD CONSTRAINT enseignant_email_key UNIQUE (email);


--
-- Name: enseignant enseignant_matricule_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.enseignant
    ADD CONSTRAINT enseignant_matricule_key UNIQUE (matricule);


--
-- Name: enseignant enseignant_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.enseignant
    ADD CONSTRAINT enseignant_pkey PRIMARY KEY (id_enseignant);


--
-- Name: etudiant etudiant_email_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.etudiant
    ADD CONSTRAINT etudiant_email_key UNIQUE (email);


--
-- Name: etudiant etudiant_matricule_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.etudiant
    ADD CONSTRAINT etudiant_matricule_key UNIQUE (matricule);


--
-- Name: etudiant etudiant_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.etudiant
    ADD CONSTRAINT etudiant_pkey PRIMARY KEY (id_etudiant);


--
-- Name: filiere filiere_code_filiere_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.filiere
    ADD CONSTRAINT filiere_code_filiere_key UNIQUE (code_filiere);


--
-- Name: filiere filiere_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.filiere
    ADD CONSTRAINT filiere_pkey PRIMARY KEY (id_filiere);


--
-- Name: jury jury_id_programme_id_enseignant_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.jury
    ADD CONSTRAINT jury_id_programme_id_enseignant_key UNIQUE (id_programme, id_enseignant);


--
-- Name: jury jury_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.jury
    ADD CONSTRAINT jury_pkey PRIMARY KEY (id_jury);


--
-- Name: participation_jury participation_jury_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.participation_jury
    ADD CONSTRAINT participation_jury_pkey PRIMARY KEY (id_participation);


--
-- Name: programme programme_id_salle_date_heure_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.programme
    ADD CONSTRAINT programme_id_salle_date_heure_key UNIQUE (id_salle, date_heure);


--
-- Name: programme programme_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.programme
    ADD CONSTRAINT programme_pkey PRIMARY KEY (id_programme);


--
-- Name: rapport rapport_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.rapport
    ADD CONSTRAINT rapport_pkey PRIMARY KEY (id_rapport);


--
-- Name: resultat resultat_id_programme_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.resultat
    ADD CONSTRAINT resultat_id_programme_key UNIQUE (id_programme);


--
-- Name: resultat resultat_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.resultat
    ADD CONSTRAINT resultat_pkey PRIMARY KEY (id_resultat);


--
-- Name: salle salle_nom_salle_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.salle
    ADD CONSTRAINT salle_nom_salle_key UNIQUE (nom_salle);


--
-- Name: salle salle_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.salle
    ADD CONSTRAINT salle_pkey PRIMARY KEY (id_salle);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id_session);


--
-- Name: validation_programme validation_programme_id_programme_id_enseignant_key; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.validation_programme
    ADD CONSTRAINT validation_programme_id_programme_id_enseignant_key UNIQUE (id_programme, id_enseignant);


--
-- Name: validation_programme validation_programme_pkey; Type: CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.validation_programme
    ADD CONSTRAINT validation_programme_pkey PRIMARY KEY (id_validation);


--
-- Name: idx_dispo_enseignant; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_dispo_enseignant ON jury.disponibilite USING btree (id_enseignant);


--
-- Name: idx_jury_enseignant; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_jury_enseignant ON jury.jury USING btree (id_enseignant);


--
-- Name: idx_jury_programme; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_jury_programme ON jury.jury USING btree (id_programme);


--
-- Name: idx_programme_date; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_programme_date ON jury.programme USING btree (date_heure);


--
-- Name: idx_programme_session; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_programme_session ON jury.programme USING btree (id_session);


--
-- Name: idx_rapport_etudiant; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_rapport_etudiant ON jury.rapport USING btree (id_etudiant);


--
-- Name: idx_rapport_session; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_rapport_session ON jury.rapport USING btree (id_session);


--
-- Name: idx_validation_prog; Type: INDEX; Schema: jury; Owner: postgres
--

CREATE INDEX idx_validation_prog ON jury.validation_programme USING btree (id_programme);


--
-- Name: disponibilite disponibilite_id_enseignant_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.disponibilite
    ADD CONSTRAINT disponibilite_id_enseignant_fkey FOREIGN KEY (id_enseignant) REFERENCES jury.enseignant(id_enseignant);


--
-- Name: disponibilite disponibilite_id_session_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.disponibilite
    ADD CONSTRAINT disponibilite_id_session_fkey FOREIGN KEY (id_session) REFERENCES jury.session(id_session);


--
-- Name: etudiant etudiant_id_filiere_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.etudiant
    ADD CONSTRAINT etudiant_id_filiere_fkey FOREIGN KEY (id_filiere) REFERENCES jury.filiere(id_filiere);


--
-- Name: jury jury_id_enseignant_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.jury
    ADD CONSTRAINT jury_id_enseignant_fkey FOREIGN KEY (id_enseignant) REFERENCES jury.enseignant(id_enseignant);


--
-- Name: jury jury_id_programme_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.jury
    ADD CONSTRAINT jury_id_programme_fkey FOREIGN KEY (id_programme) REFERENCES jury.programme(id_programme);


--
-- Name: participation_jury participation_jury_id_jury_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.participation_jury
    ADD CONSTRAINT participation_jury_id_jury_fkey FOREIGN KEY (id_jury) REFERENCES jury.jury(id_jury);


--
-- Name: programme programme_id_rapport_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.programme
    ADD CONSTRAINT programme_id_rapport_fkey FOREIGN KEY (id_rapport) REFERENCES jury.rapport(id_rapport);


--
-- Name: programme programme_id_salle_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.programme
    ADD CONSTRAINT programme_id_salle_fkey FOREIGN KEY (id_salle) REFERENCES jury.salle(id_salle);


--
-- Name: programme programme_id_session_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.programme
    ADD CONSTRAINT programme_id_session_fkey FOREIGN KEY (id_session) REFERENCES jury.session(id_session);


--
-- Name: rapport rapport_id_etudiant_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.rapport
    ADD CONSTRAINT rapport_id_etudiant_fkey FOREIGN KEY (id_etudiant) REFERENCES jury.etudiant(id_etudiant);


--
-- Name: rapport rapport_id_session_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.rapport
    ADD CONSTRAINT rapport_id_session_fkey FOREIGN KEY (id_session) REFERENCES jury.session(id_session);


--
-- Name: resultat resultat_enregistre_par_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.resultat
    ADD CONSTRAINT resultat_enregistre_par_fkey FOREIGN KEY (enregistre_par) REFERENCES jury.enseignant(id_enseignant);


--
-- Name: resultat resultat_id_programme_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.resultat
    ADD CONSTRAINT resultat_id_programme_fkey FOREIGN KEY (id_programme) REFERENCES jury.programme(id_programme);


--
-- Name: validation_programme validation_programme_id_enseignant_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.validation_programme
    ADD CONSTRAINT validation_programme_id_enseignant_fkey FOREIGN KEY (id_enseignant) REFERENCES jury.enseignant(id_enseignant);


--
-- Name: validation_programme validation_programme_id_programme_fkey; Type: FK CONSTRAINT; Schema: jury; Owner: postgres
--

ALTER TABLE ONLY jury.validation_programme
    ADD CONSTRAINT validation_programme_id_programme_fkey FOREIGN KEY (id_programme) REFERENCES jury.programme(id_programme);


--
-- Name: SCHEMA jury; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA jury TO jury_app;
GRANT USAGE ON SCHEMA jury TO jury_readonly;


--
-- Name: TABLE disponibilite; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.disponibilite TO jury_app;
GRANT SELECT ON TABLE jury.disponibilite TO jury_readonly;


--
-- Name: SEQUENCE disponibilite_id_disponibilite_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.disponibilite_id_disponibilite_seq TO jury_app;


--
-- Name: TABLE enseignant; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.enseignant TO jury_app;
GRANT SELECT ON TABLE jury.enseignant TO jury_readonly;


--
-- Name: SEQUENCE enseignant_id_enseignant_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.enseignant_id_enseignant_seq TO jury_app;


--
-- Name: TABLE etudiant; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.etudiant TO jury_app;
GRANT SELECT ON TABLE jury.etudiant TO jury_readonly;


--
-- Name: SEQUENCE etudiant_id_etudiant_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.etudiant_id_etudiant_seq TO jury_app;


--
-- Name: TABLE filiere; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.filiere TO jury_app;
GRANT SELECT ON TABLE jury.filiere TO jury_readonly;


--
-- Name: SEQUENCE filiere_id_filiere_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.filiere_id_filiere_seq TO jury_app;


--
-- Name: TABLE jury; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.jury TO jury_app;
GRANT SELECT ON TABLE jury.jury TO jury_readonly;


--
-- Name: SEQUENCE jury_id_jury_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.jury_id_jury_seq TO jury_app;


--
-- Name: TABLE participation_jury; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.participation_jury TO jury_app;
GRANT SELECT ON TABLE jury.participation_jury TO jury_readonly;


--
-- Name: SEQUENCE participation_jury_id_participation_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.participation_jury_id_participation_seq TO jury_app;


--
-- Name: TABLE programme; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.programme TO jury_app;
GRANT SELECT ON TABLE jury.programme TO jury_readonly;


--
-- Name: SEQUENCE programme_id_programme_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.programme_id_programme_seq TO jury_app;


--
-- Name: TABLE rapport; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.rapport TO jury_app;
GRANT SELECT ON TABLE jury.rapport TO jury_readonly;


--
-- Name: SEQUENCE rapport_id_rapport_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.rapport_id_rapport_seq TO jury_app;


--
-- Name: TABLE resultat; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.resultat TO jury_app;
GRANT SELECT ON TABLE jury.resultat TO jury_readonly;


--
-- Name: SEQUENCE resultat_id_resultat_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.resultat_id_resultat_seq TO jury_app;


--
-- Name: TABLE salle; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.salle TO jury_app;
GRANT SELECT ON TABLE jury.salle TO jury_readonly;


--
-- Name: SEQUENCE salle_id_salle_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.salle_id_salle_seq TO jury_app;


--
-- Name: TABLE session; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.session TO jury_app;
GRANT SELECT ON TABLE jury.session TO jury_readonly;


--
-- Name: SEQUENCE session_id_session_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.session_id_session_seq TO jury_app;


--
-- Name: TABLE validation_programme; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.validation_programme TO jury_app;
GRANT SELECT ON TABLE jury.validation_programme TO jury_readonly;


--
-- Name: SEQUENCE validation_programme_id_validation_seq; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE jury.validation_programme_id_validation_seq TO jury_app;


--
-- Name: TABLE vue_composition_jury; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.vue_composition_jury TO jury_app;
GRANT SELECT ON TABLE jury.vue_composition_jury TO jury_readonly;


--
-- Name: TABLE vue_programme_complet; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.vue_programme_complet TO jury_app;
GRANT SELECT ON TABLE jury.vue_programme_complet TO jury_readonly;


--
-- Name: TABLE vue_resultats; Type: ACL; Schema: jury; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE jury.vue_resultats TO jury_app;
GRANT SELECT ON TABLE jury.vue_resultats TO jury_readonly;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: jury; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jury GRANT SELECT,USAGE ON SEQUENCES TO jury_app;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: jury; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jury GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO jury_app;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jury GRANT SELECT ON TABLES TO jury_readonly;


--
-- PostgreSQL database dump complete
--

\unrestrict sZzgnp62ijFz8dxrNZVcfRMd1R6bqs2peUsAbfUKDYG5Gf25KA7kO8BJEHIlYPH

