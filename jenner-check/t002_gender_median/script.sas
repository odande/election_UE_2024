/* ============================================================
   Équilibre hommes / femmes par pays (UE 2024)
   Adapté de Prog_Etudes_Elec_UE2024.sas — la PROC IMPORT du
   fichier ~/ELEC_EU24/gender-balance-country.csv est remplacée
   par une étape DATA reprenant les mêmes valeurs, afin que le
   script s'exécute isolément. Le calcul de médiane du % de
   femmes (PROC SQL median() into :med_women) et la PROC PRINT
   sont ceux de l'auteur.
   ============================================================ */

/* --- données gender (issues de gender-balance-country.csv) --- */
data gender;
    length COUNTRY_ID $2 MEN 8 WOMEN 8;
    infile datalines dsd dlm=';' truncover;
    input COUNTRY_ID $ MEN WOMEN;
datalines;
BE;59.09;40.91
BG;76.47;23.53
CZ;61.9;38.1
DK;66.67;33.33
DE;62.5;36.46
EE;71.43;28.57
IE;57.14;42.86
EL;71.43;28.57
ES;50.0;50.0
FR;49.38;50.62
IT;67.11;32.89
CY;100.0;0.0
LV;77.78;22.22
LT;81.82;18.18
LU;66.67;33.33
HU;52.38;47.62
MT;83.33;16.67
NL;51.61;48.39
AT;60.0;40.0
PL;71.7;28.3
PT;61.9;38.1
RO;81.82;18.18
SI;66.67;33.33
SK;53.33;46.67
FI;40.0;60.0
SE;38.1;61.9
HR;58.33;41.67
;
run;

/* --- Médiane du % de femmes (PROC SQL, inchangé) --- */
proc sql noprint;
    select median(women)
    into :med_women
    from work.gender;
quit;

title "Équilibre hommes / femmes par pays (%)";
proc print data=gender noobs;
    var country_id men women;
run;

title "Médiane du pourcentage de femmes (UE 2024)";
data _null_;
    put "Médiane du % de femmes = &med_women";
run;

title "Statistiques descriptives — parts hommes / femmes";
proc means data=gender n mean median min max;
    var men women;
run;
