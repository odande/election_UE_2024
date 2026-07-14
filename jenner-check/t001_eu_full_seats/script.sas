/* ============================================================
   Répartition des sièges par groupe politique (UE 2024)
   Adapté de Prog_Etudes_Elec_UE2024.sas — les PROC IMPORT des
   fichiers ~/ELEC_EU24/*.csv sont remplacés par des étapes DATA
   avec les mêmes données, afin que le script s'exécute isolément.
   La logique PROC SQL (jointures groups_fr / groups_en, eu_full),
   la conversion input() et le calcul de médiane sont inchangés.
   ============================================================ */

/* --- données eu (issues de eu.csv, séparateur ';') --- */
data eu;
    length GROUP_ID $10 SEATS_TOTAL 8 SEATS_PERCENT_EU 8
           UPDATE_STATUS $20 UPDATE_TIME $16;
    infile datalines dsd dlm=';' truncover;
    input GROUP_ID $ SEATS_TOTAL SEATS_PERCENT_EU UPDATE_STATUS $ UPDATE_TIME $;
datalines;
EPP;188;26.11;CONSTITUTIVE;2024-07-23 11:07
SD;136;18.89;CONSTITUTIVE;2024-07-23 11:07
ECR;78;10.83;CONSTITUTIVE;2024-07-23 11:07
Renew;77;10.69;CONSTITUTIVE;2024-07-23 11:07
Theleft;46;6.39;CONSTITUTIVE;2024-07-23 11:07
GREENSEFA;53;7.36;CONSTITUTIVE;2024-07-23 11:07
PfE;84;11.67;CONSTITUTIVE;2024-07-23 11:07
ESN;25;3.47;CONSTITUTIVE;2024-07-23 11:07
NI;33;4.58;CONSTITUTIVE;2024-07-23 11:07
;
run;

/* --- données groups (issues de groups.csv, LANGUAGE_ID FR + EN) --- */
data groups;
    length ID $10 LANGUAGE_ID $2 ACRONYM $16 LABEL $120;
    infile datalines dsd dlm=';' truncover;
    input ID $ LANGUAGE_ID $ ACRONYM $ LABEL $;
datalines;
EPP;FR;PPE;Groupe du Parti populaire européen (Démocrates-Chrétiens)
SD;FR;S&D;Groupe de l'Alliance Progressiste des Socialistes et Démocrates au Parlement européen
ECR;FR;ECR;Groupe des Conservateurs et Réformistes européens
Renew;FR;Renew Europe;Groupe Renew Europe
Theleft;FR;The Left;Le groupe de la gauche au Parlement européen - GUE/NGL
GREENSEFA;FR;Verts/ALE;Groupe des Verts/Alliance libre européenne
PfE;FR;PfE;Patriots for Europe
ESN;FR;ESN;Europe of Sovereign Nations
NI;FR;NI;Non-inscrits
EPP;EN;EPP;Group of the European People's Party (Christian Democrats)
SD;EN;S&D;Group of the Progressive Alliance of Socialists and Democrats in the European Parliament
ECR;EN;ECR;European Conservatives and Reformists Group
Renew;EN;Renew Europe;Renew Europe Group
Theleft;EN;The Left;The Left group in the European Parliament - GUE/NGL
GREENSEFA;EN;Greens/EFA;Group of the Greens/European Free Alliance
PfE;EN;PfE;Patriots for Europe
ESN;EN;ESN;Europe of Sovereign Nations
NI;EN;NI;Non-attached Members
;
run;

/* --- Séparation des libellés FR / EN (PROC SQL, inchangé) --- */
proc sql;
    create table groups_fr as
    select ID as group_id,
           ACRONYM as acronym_fr,
           LABEL as label_fr
    from work.groups
    where LANGUAGE_ID = "FR";

    create table groups_en as
    select ID as group_id,
           ACRONYM as acronym_en,
           LABEL as label_en
    from work.groups
    where LANGUAGE_ID = "EN";
quit;

/* --- Jointure eu_full (PROC SQL, inchangé) --- */
proc sql;
    create table eu_full as
    select a.*,
           b.acronym_fr,
           b.label_fr,
           c.acronym_en,
           c.label_en
    from eu as a
    left join groups_fr as b
        on a.GROUP_ID = b.group_id
    left join groups_en as c
        on a.GROUP_ID = c.group_id;
quit;

title "Répartition des sièges par groupe politique (UE 2024)";
proc print data=eu_full noobs;
    var group_id acronym_fr seats_total seats_percent_eu label_fr;
run;
