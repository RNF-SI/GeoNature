CREATE SCHEMA gn_synchronomade;

CREATE TABLE gn_synchronomade.erreurs_occtax
(
  id serial NOT NULL,
  json text,
  date_import date,
  CONSTRAINT erreurs_occtax_pkey PRIMARY KEY (id)
)


CREATE OR REPLACE VIEW gn_synchronomade.v_color_taxon_area
AS SELECT b.id_nom,
    c.id_area,
    c.nb_obs,
    c.last_date,
        CASE
            WHEN date_part('day'::text, now() - c.last_date::timestamp with time zone) < 365::double precision THEN 'grey'::text
            ELSE 'red'::text
        END AS color
   FROM gn_synthese.cor_area_taxon c
   join taxonomie.bib_noms b on b.cd_nom = c.cd_nom;

-- Recréation des vues qui sont devenues des tables (pour assurer l'évolution - si on ajoute des taxons ou des observateur)

CREATE OR REPLACE VIEW gn_synchronomade.v_nomade_taxons_faune
AS 
SELECT DISTINCT n.id_nom,
    taxonomie.find_cdref(n.cd_nom) AS cd_ref,
    n.cd_nom,
    tx.lb_nom AS nom_latin,
    n.nom_francais,
    cnl.id_liste as id_classe,
        CASE
            WHEN tx.cd_nom = ANY (ARRAY[61098, 61119, 61000]) THEN 6
            ELSE 5
        END AS denombrement,
    f2.bool AS patrimonial,
    m.texte_message_cf AS message,
        CASE
            WHEN tx.cd_nom = ANY (ARRAY[60577, 60612]) THEN false
            ELSE true
        END AS contactfaune,
    true AS mortalite
   FROM taxonomie.bib_noms n
     LEFT JOIN v1_compat.cor_message_taxon cmt ON cmt.id_nom = n.id_nom
     LEFT JOIN v1_compat.bib_messages_cf m ON m.id_message_cf = cmt.id_message_cf
     LEFT JOIN taxonomie.cor_taxon_attribut cta ON cta.cd_ref = n.cd_ref
     JOIN taxonomie.cor_nom_liste cnl ON cnl.id_nom = n.id_nom and cnl.id_liste in (1, 11, 12, 13, 14)
     join taxonomie.cor_nom_liste cnl_500 on cnl_500.id_nom = n.id_nom and cnl_500.id_liste = 500
    -- join taxonomie.bib_listes bib on bib.id_liste = cnl.id_liste 
     --JOIN v1_compat.v_nomade_classes g ON g.id_classe = cnl.id_liste
     JOIN taxonomie.taxref tx ON tx.cd_nom = n.cd_nom and tx.phylum = 'Chordata'
     JOIN v1_compat.cor_boolean f2 ON f2.expression::text = cta.valeur_attribut AND cta.id_attribut = 1
  ORDER BY n.id_nom, taxonomie.find_cdref(n.cd_nom), tx.lb_nom, n.nom_francais, cnl.id_liste, f2.bool, m.texte_message_cf;

CREATE OR REPLACE VIEW gn_synchronomade.v_nomade_taxons_flore
AS 
SELECT DISTINCT n.id_nom,
    taxonomie.find_cdref(n.cd_nom) AS cd_ref,
    n.cd_nom,
    tx.lb_nom AS nom_latin,
    n.nom_francais,
    cnl.id_liste as id_classe,
        CASE
            WHEN tx.cd_nom = ANY (ARRAY[61098, 61119, 61000]) THEN 6
            ELSE 5
        END AS denombrement,
    f2.bool AS patrimonial,
    m.texte_message_cf AS message,
        CASE
            WHEN tx.cd_nom = ANY (ARRAY[60577, 60612]) THEN false
            ELSE true
        END AS contactfaune,
    true AS mortalite
   FROM taxonomie.bib_noms n
     LEFT JOIN v1_compat.cor_message_taxon cmt ON cmt.id_nom = n.id_nom
     LEFT JOIN v1_compat.bib_messages_cf m ON m.id_message_cf = cmt.id_message_cf
     LEFT JOIN taxonomie.cor_taxon_attribut cta ON cta.cd_ref = n.cd_ref
     JOIN taxonomie.cor_nom_liste cnl ON cnl.id_nom = n.id_nom and cnl.id_liste > 300 AND cnl.id_liste < 400
     join taxonomie.cor_nom_liste cnl_500 on cnl_500.id_nom = n.id_nom and cnl_500.id_liste = 500
    -- join taxonomie.bib_listes bib on bib.id_liste = cnl.id_liste 
     --JOIN v1_compat.v_nomade_classes g ON g.id_classe = cnl.id_liste
     JOIN taxonomie.taxref tx ON tx.cd_nom = n.cd_nom and tx.regne = 'Plantae'
     JOIN v1_compat.cor_boolean f2 ON f2.expression::text = cta.valeur_attribut AND cta.id_attribut = 1
  ORDER BY n.id_nom, taxonomie.find_cdref(n.cd_nom), tx.lb_nom, n.nom_francais, cnl.id_liste, f2.bool, m.texte_message_cf;

CREATE OR REPLACE VIEW gn_synchronomade.v_nomade_taxons_inv
AS 
SELECT DISTINCT n.id_nom,
    taxonomie.find_cdref(n.cd_nom) AS cd_ref,
    n.cd_nom,
    tx.lb_nom AS nom_latin,
    n.nom_francais,
    cnl.id_liste as id_classe,
        CASE
            WHEN tx.cd_nom = ANY (ARRAY[61098, 61119, 61000]) THEN 6
            ELSE 5
        END AS denombrement,
    f2.bool AS patrimonial,
    m.texte_message_cf AS message,
        CASE
            WHEN tx.cd_nom = ANY (ARRAY[60577, 60612]) THEN false
            ELSE true
        END AS contactfaune,
    true AS mortalite
   FROM taxonomie.bib_noms n
     LEFT JOIN v1_compat.cor_message_taxon cmt ON cmt.id_nom = n.id_nom
     LEFT JOIN v1_compat.bib_messages_cf m ON m.id_message_cf = cmt.id_message_cf
     LEFT JOIN taxonomie.cor_taxon_attribut cta ON cta.cd_ref = n.cd_ref
     JOIN taxonomie.cor_nom_liste cnl ON cnl.id_nom = n.id_nom and cnl.id_liste IN (2, 5, 8, 9, 10, 15, 16)
     join taxonomie.cor_nom_liste cnl_500 on cnl_500.id_nom = n.id_nom and cnl_500.id_liste = 500
    -- join taxonomie.bib_listes bib on bib.id_liste = cnl.id_liste 
     --JOIN v1_compat.v_nomade_classes g ON g.id_classe = cnl.id_liste
     JOIN taxonomie.taxref tx ON tx.cd_nom = n.cd_nom and tx.phylum = 'Chordata'
     JOIN v1_compat.cor_boolean f2 ON f2.expression::text = cta.valeur_attribut AND cta.id_attribut = 1
  ORDER BY n.id_nom, taxonomie.find_cdref(n.cd_nom), tx.lb_nom, n.nom_francais, cnl.id_liste, f2.bool, m.texte_message_cf;



CREATE OR REPLACE VIEW gn_synchronomade.v_nomade_observateurs_inv
AS SELECT DISTINCT r.id_role,
    r.nom_role,
    r.prenom_role
   FROM utilisateurs.t_roles r
  WHERE (r.id_role IN ( SELECT DISTINCT cr.id_role_utilisateur
           FROM utilisateurs.cor_roles cr
          WHERE (cr.id_role_groupe IN ( SELECT crm.id_role
                   FROM utilisateurs.cor_role_menu crm
                  WHERE crm.id_menu = 11))
          ORDER BY cr.id_role_utilisateur)) OR (r.id_role IN ( SELECT crm.id_role
           FROM utilisateurs.cor_role_menu crm
             JOIN utilisateurs.t_roles r_1 ON r_1.id_role = crm.id_role AND crm.id_menu = 11 AND r_1.groupe = false AND r_1.active = true))
  ORDER BY r.nom_role, r.prenom_role, r.id_role;


CREATE OR REPLACE VIEW gn_synchronomade.v_nomade_observateurs_faune
AS SELECT DISTINCT r.id_role,
    r.nom_role,
    r.prenom_role
   FROM utilisateurs.t_roles r
  WHERE (r.id_role IN ( SELECT DISTINCT cr.id_role_utilisateur
           FROM utilisateurs.cor_roles cr
          WHERE (cr.id_role_groupe IN ( SELECT crm.id_role
                   FROM utilisateurs.cor_role_menu crm
                  WHERE crm.id_menu = 11))
          ORDER BY cr.id_role_utilisateur)) OR (r.id_role IN ( SELECT crm.id_role
           FROM utilisateurs.cor_role_menu crm
             JOIN utilisateurs.t_roles r_1 ON r_1.id_role = crm.id_role AND crm.id_menu = 11 AND r_1.groupe = false AND r_1.active = true))
  ORDER BY r.nom_role, r.prenom_role, r.id_role;



-- recréation des vue "critere". Pdt la migrations, les vues ont été transformés en table, celles pose des problèmes de droits car elles s'appuyent sur des tables qui n'existe plus.

DROP foreign table v1_compat.v_nomade_criteres_cf;
DROP foreign table v1_compat.v_nomade_criteres_inv;

CREATE OR REPLACE VIEW v1_compat.v_nomade_criteres_cf
AS SELECT c.id_critere_cf,
    c.nom_critere_cf,
    c.tri_cf,
    ccl.id_liste AS id_classe
   FROM v1_compat.bib_criteres_cf c
     JOIN v1_compat.cor_critere_liste ccl ON ccl.id_critere_cf = c.id_critere_cf
  ORDER BY ccl.id_liste, c.tri_cf;


CREATE OR REPLACE VIEW v1_compat.v_nomade_criteres_inv
AS SELECT c.id_critere_inv,
    c.nom_critere_inv,
    c.tri_inv
   FROM v1_compat.bib_criteres_inv c
  ORDER BY c.tri_inv;


-- création de nouveau JDD pour les données des appli mobiles v1 qui écrivent en v2

INSERT INTO gn_meta.t_datasets (
    id_acquisition_framework,
    dataset_name,
    dataset_shortname,
    dataset_desc,
    id_nomenclature_data_type,
    keywords,
    marine_domain,
    terrestrial_domain,
    id_nomenclature_dataset_objectif,
    bbox_west,
    bbox_east,
    bbox_south,
    bbox_north,
    id_nomenclature_collecting_method,
    id_nomenclature_data_origin,
    id_nomenclature_source_status,
    id_nomenclature_resource_type,
    validable
    )
    VALUES
    (
    1,
    'Contact faune - mobile v1 vers base de données v2 - 2019',
    'Contact faune v1 vers v2',
    'Observations aléatoires de la faune vertebrée saisis en mobile (phase transitoire GeoNature v1 vers v2',
    ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'),
    'Aléatoire, hors protocole, faune',
    false,
    true,
    ref_nomenclatures.get_id_nomenclature('JDD_OBJECTIFS', '1.1'),
    4.85695,
    6.85654,
    44.5020,
    45.25,
    ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'),
    ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'),
    ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'),
    ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
    true
    ),
    (
    1,
    'Contact invertébré - mobile v1 vers base de données v2 - 2019',
    'Contact invertébré v1 vers v2',
    'Observations aléatoires de la faune invertebrée saisie en mobile (phase transitoire GeoNature v1 vers v2',
    ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'),
    'Aléatoire, ATBI, biodiversité, faune, invertebré',
    false,
    true,
    ref_nomenclatures.get_id_nomenclature('JDD_OBJECTIFS', '1.1'),
    4.85695,
    6.85654,
    44.5020,
    45.25,
    ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'),
    ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'),
    ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'),
    ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
    true
    ),
    (
    1,
    'Mortalité faune - mobile v1 vers base de données v2 - 2019',
    'Mortalité v1 vers v2',
    'Fiche mortalité saisie en mobile (phase transitoire GeoNature v1 vers v2) - 2019',
    ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'),
    'Aléatoire, mortalité, faune, vertebré',
    false,
    true,
    ref_nomenclatures.get_id_nomenclature('JDD_OBJECTIFS', '1.1'),
    4.85695,
    6.85654,
    44.5020,
    45.25,
    ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'),
    ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'),
    ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'),
    ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
    true
    )
;