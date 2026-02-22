/* ============================================================
   1. IMPORT DES DONNÉES
   ============================================================ */

proc import datafile="~/ELEC_EU24/gender-balance-country.csv"
    out=gender dbms=csv replace;
    delimiter=';';
    getnames=yes;
run;

proc import datafile="~/ELEC_EU24/groups.csv"
    out=groups dbms=csv replace;
    delimiter=';';
    getnames=yes;
run;

proc import datafile="~/ELEC_EU24/parties.csv"
    out=parties dbms=csv replace;
    delimiter=';';
    getnames=yes;
run;

proc import datafile="~/ELEC_EU24/eu.csv"
    out=eu dbms=csv replace;
    delimiter=';';
    getnames=yes;
run;


proc contents data=work.groups; run;
proc contents data=work.eu; run;
proc contents data=work.gender; run;


/* Conversion des variables numériques si nécessaire */
data gender;
    set work.gender;
    men   = input(men, best.);
    women = input(women, best.);
run;

data eu;
    set work.eu;
    seats_total = input(seats_total, best.);
    seats_percent_eu = input(seats_percent_eu, best.);
run;


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

/* Calcul de la médiane du % de femmes */
proc sql noprint;
    select median(women)
    into :med_women
    from work.gender;
quit;

data anno;
    length function $8 text $40;
    retain x1space "datavalue" y1space "datavalue";

    /* Ligne horizontale de la médiane */
    function="line"; 
    x1=1; 
    y1=&med_women;
    x2=27; /* nombre de pays = 27 */
    y2=&med_women;
    linecolor="red";
    linethickness=2;
    output;

    /* Étiquette de la médiane */
    function="text";
    x1=27; 
    y1=&med_women;
    text=cats("Médiane = ", put(&med_women, 5.1));
    textcolor="red";
    size=10;
    output;
run;


title "Répartition des sièges par groupe politique (UE 2024)";
proc print data=eu_full noobs;
    var group_id acronym_fr seats_total seats_percent_eu label_fr;
run;

title "Équilibre hommes / femmes par pays (%)";
proc print data=gender noobs;
    var country_id men women;
run;

title "Aperçu des partis politiques (20 premières lignes)";
proc print data=work.parties (obs=20) noobs;
run;


title "Nombre de sièges par groupe politique (UE 2024)";
proc sgplot data=eu_full;
    hbar acronym_fr / response=seats_total datalabel;
run;


title "Part des groupes politiques dans l'hémicycle européen (2024)";
proc gchart data=eu_full;
    pie acronym_fr / sumvar=seats_total
                     type=sum
                     value=inside
                     percent=outside;
run;
quit;

/* ============================================================
   4. GRAPHIQUES — GENRE PAR PAYS
   ============================================================ */

title "Répartition hommes / femmes par pays";
proc sgplot data=gender;
    vbar COUNTRY_ID / response=MEN   datalabel fillattrs=(color=blue)   name="men";
    vbar COUNTRY_ID / response=WOMEN datalabel fillattrs=(color=orange) name="women";
    keylegend "men" "women";
run;

title "Part des femmes par pays (avec médiane)";

proc sgplot data=work.gender sganno=anno;
    scatter x=COUNTRY_ID y=WOMEN / markerattrs=(color=orange size=10);
run;

/* ============================================================
   5. INDICATEURS GLOBAUX
   ============================================================

title "Groupe dominant";
proc sql;
    select *
    from eu_full
    order by seats_total desc
    limit 1;
quit;

title "Pays le plus féminisé";
proc sql;
    select *
    from gender
    order by women desc
    limit 1;
quit;

title "Pays le plus masculin";
proc sql;
    select *
    from gender
    order by men desc
    limit 1;
quit;*/
