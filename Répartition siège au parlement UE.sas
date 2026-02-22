title "Répartition des sièges par groupe politique au Parlement européen (2024)";

/* Camembert avec PROC GCHART (compatible partout) */
proc gchart data=work.eu;
    pie GROUP_ID / 
        sumvar=SEATS_TOTAL
        type=sum
        value=inside
        percent=outside
        slice=outside
        coutline=black;
run;
quit;

title "Répartition des sièges par groupe politique (acronymes FR)";

proc gchart data=eu_full;
    pie ACRONYM_FR /
        sumvar=SEATS_TOTAL
        type=sum
        value=inside
        percent=outside
        slice=outside
        coutline=black;
run;
quit;

