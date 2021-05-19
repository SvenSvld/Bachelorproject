* Encoding: UTF-8.
* Bachelorproject Sven Strating.
**** Ophalen werkdata.
GET
  FILE='C:\Users\svens\OneDrive\Documenten\3_Bachelor_Sociology and Social Research\BLOK '+
    '7+8\Data-analyse\ESS2014.sav'
    /KEEP dweight pspwght pweight anctry1 anctry2 uemp3m uemp12m uemp5yr mbtru hincsrca hinctnta isco08 
    tporgwk nacer2 icwhct emplrel mainact mnactic eduyrs crpdwk domicil marsts maritalb marstie yrbrn agea gndr 
    rlgueim noimbro dfegcf dfegcon dfeghbg imtcjob imbleco imwbcrm facntr fbrncntb mocntr mbrncntb blgetmg cntbrthc 
    ctzcntr rlgdgr rlgatnd pray imwbcnt imueclt imsmetn imdfetn eimpcnt impcntr imbgeco contplt wrkprty prtvtbat prtvtcbe 
    prtvtech prtvtdcz prtvede1 prtvede2 prtvtcdk prtvteee prtvtces prtvtcfi prtvtcfr prtvtbgb prtvtehu prtvtaie prtvtcil prtvalt1 
    prtvalt2 prtvalt3 prtvtfnl prtvtbno prtvtcpl prtvtbpt prtvtbse prtvtesi vote cntry idno rshpsts.
DATASET NAME ESS2014 WINDOW=FRONT.
* Ik selecteer alleen de landen die betrekking hebben op dit onderzoek.
SELECT IF NOT (cntry NE 'NL' and cntry NE 'GB' and cntry NE 'DE'
    and cntry NE 'GB' and cntry NE 'IE' and cntry NE 'FR' and cntry NE 'DK'
    and cntry NE 'SE' and cntry NE 'NO' and cntry NE 'BE').
FREQUENCIES cntry.
* Maak een staandaardgewicht aan welke in elke analyse moet worden meegenomen.
COMPUTE anweight=pspwght*pweight.
WEIGHT by anweight.


**** Factoranalyse en betrouwbaarheidsanalyse over alle items rondom waargenomen bedreiging.
* (1) Inspecteer variabelen Rlgueim Imtcjob Imbleco Imwbcrm.
VARIABLE LEVEL Rlgueim Imtcjob Imbleco Imwbcrm (ORDINAL).
fre Rlgueim Imtcjob Imbleco Imwbcrm.
* (2) Hercodeer deze variabelen.
RECODE Rlgueim Imtcjob Imbleco Imwbcrm 
    (10=0) (9=1) (8=2) (7=3) (6=4) (5=5) (4=6) (3=7) (2=8) (1=9) (0=10) (ELSE=SYSMIS)
    into R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm.
EXECUTE.
VARIABLE LEVEL R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm (ORDINAL).
* (3) Split file by cntry.
SORT CASES  BY cntry.
SPLIT FILE SEPARATE BY cntry.
* (4) Run factoranalyse per land.
FACTOR
  /VARIABLES R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm
  /MISSING LISTWISE 
  /ANALYSIS R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm
  /PRINT INITIAL CORRELATION SIG KMO EXTRACTION ROTATION
  /FORMAT SORT BLANK(.25)
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /METHOD=CORRELATION.
* (5) Run een betrouwbaarheidsanalyse per land.
RELIABILITY
  /VARIABLES=R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL.
* (6) Split file by cntry uitzetten.
SPLIT FILE OFF.
* (7) Run een factoranalyse voor alle landen.
FACTOR
  /VARIABLES R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm
  /MISSING LISTWISE 
  /ANALYSIS R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm
  /PRINT INITIAL CORRELATION SIG KMO EXTRACTION ROTATION
  /FORMAT SORT BLANK(.25)
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /METHOD=CORRELATION.
* (8) Run een betrouwbaarheidsanalyse voor alle landen.
RELIABILITY
  /VARIABLES=R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL.
* (9) Maak de variabele 'waargenomen bedreiging ten aanzien van migranten' aan.
COMPUTE Threat = MEAN.4(R_Rlgueim,R_Imtcjob,R_Imbleco,R_Imwbcrm).
EXECUTE.


**** Variabelen ophalen.
* (1) Dummy steun rechts_populistische partij aanmaken per land.
COMPUTE dummy_rightwing = 0.
EXECUTE.
*Belgie.
IF (prtvtcbe EQ 7 or 
    prtvtcbe EQ 11 or
    prtvtcbe EQ 15 ) dummy_rightwing = 1.
*Nederland.
IF (prtvtfnl EQ 3 ) dummy_rightwing = 1.
*Duitsland (meest recente nationale verkiezingen).
IF (prtvede2 EQ 6 or
    prtvede2 EQ 8 ) dummy_rightwing = 1.
*Verenigd Koninkrijk.
IF (prtvtbgb EQ 7 ) dummy_rightwing = 1.
*Ierland (geen rechts-populistische partij).
*Frankrijk.
IF (prtvtcfr EQ 2 ) dummy_rightwing = 1.
*Denemarken.
IF (prtvtcdk EQ 5 ) dummy_rightwing = 1.
*Noorwegen.
IF (prtvtbno EQ 8 ) dummy_rightwing = 1.
*Zweden.
IF (prtvtbse EQ 10 ) dummy_rightwing = 1.
CROSSTABS
  /TABLES=prtvtcbe BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvtfnl BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvede2 BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvtbgb BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvtcfr BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvtcdk BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvtbno BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=prtvtbse BY dummy_rightwing
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
VALUE LABELS dummy_rightwing
    0 Niet-rechtspopulistisch
    1 Rechtspopulistisch.
* (2) Controlevariabelen coderen
*Leeftijd hoeft niet (agea).
fre agea.
*Gender.
RECODE gndr (1=1) (2=0) (ELSE=SYSMIS) into
    R_gndr.
VALUE LABELS R_gndr
    1 Man
    0 Vrouw.
VARIABLE LEVEL R_gndr (NOMINAL).
*Migratieachtergrond (zonder of met).
RECODE blgetmg (1=1) (2=0) (ELSE=SYSMIS) into
    R_blgetmg.
VALUE LABELS R_blgetmg
    1 Met migratieachtergrond
    0 Zonder migratieachtergrond.
VARIABLE LEVEL R_blgetmg (NOMINAL).
*Opleiding in jaren hoeft niet (eduyrs).
fre eduyrs.
*Woonsituatie (grootstedelijk, stedelijk, landelijk [ref.]).
COMPUTE dummy_grootstedelijk = 0.
EXECUTE.
IF (domicil EQ 1 or domicil EQ 2 ) dummy_grootstedelijk = 1.
COMPUTE dummy_stedelijk = 0.
EXECUTE.
IF (domicil EQ 3 ) dummy_stedelijk = 1.
COMPUTE dummy_landelijk = 0.
EXECUTE.
IF (domicil EQ 4 or domicil EQ 5 ) dummy_landelijk = 1.
CROSSTABS
  /TABLES=domicil BY dummy_grootstedelijk
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=domicil BY dummy_stedelijk
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=domicil BY dummy_landelijk
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*Huishoudinkomen (in 10 decielen (1e deciel [ref.])).
COMPUTE dummy_deciel2 = 0.
EXECUTE.
IF (hinctnta EQ 2 ) dummy_deciel2 = 1.
COMPUTE dummy_deciel3 = 0.
EXECUTE.
IF (hinctnta EQ 3 ) dummy_deciel3 = 1.
COMPUTE dummy_deciel4 = 0.
EXECUTE.
IF (hinctnta EQ 4 ) dummy_deciel4 = 1.
COMPUTE dummy_deciel5 = 0.
EXECUTE.
IF (hinctnta EQ 5 ) dummy_deciel5 = 1.
COMPUTE dummy_deciel6 = 0.
EXECUTE.
IF (hinctnta EQ 6 ) dummy_deciel6 = 1.
COMPUTE dummy_deciel7 = 0.
EXECUTE.
IF (hinctnta EQ 7 ) dummy_deciel7 = 1.
COMPUTE dummy_deciel8 = 0.
EXECUTE.
IF (hinctnta EQ 8 ) dummy_deciel8 = 1.
COMPUTE dummy_deciel9 = 0.
EXECUTE.
IF (hinctnta EQ 9 ) dummy_deciel9 = 1.
COMPUTE dummy_deciel10 = 0.
EXECUTE.
IF (hinctnta EQ 10 ) dummy_deciel10 = 1.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel2
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel3
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel4
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel5
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel6
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel7
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel8
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel9
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=hinctnta BY dummy_deciel10
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*Zelfgerapporteerde mate van religositeit hoeft niet (rlgdgr).
fre rlgdgr.
*Type burgerlijke staat (getrouwd, geregistreerd partnerschap, samenwonend, gescheiden, geen partner [ref.]).
COMPUTE dummy_getrouwd = 0.
EXECUTE.
IF (rshpsts EQ 1 ) dummy_getrouwd = 1.
COMPUTE dummy_partnerschap = 0.
EXECUTE.
IF (rshpsts EQ 2 ) dummy_partnerschap = 1.
COMPUTE dummy_samenwonend = 0.
EXECUTE.
IF (rshpsts EQ 3 or rshpsts EQ 4 ) dummy_samenwonend = 1.
COMPUTE dummy_gescheiden = 0.
EXECUTE.
IF (rshpsts EQ 5 or rshpsts EQ 6 ) dummy_gescheiden = 1.
RECODE rshpsts (66=1) (1=0) 
    (2=0) (3=0) (4=0) (5=0) (6=0) (ELSE=SYSMIS) 
    into dummy_geenpartner.
CROSSTABS
  /TABLES=rshpsts BY dummy_getrouwd
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=rshpsts BY dummy_partnerschap
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=rshpsts BY dummy_samenwonend
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=rshpsts BY dummy_gescheiden
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=rshpsts BY dummy_geenpartner
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*Werkloos of niet?.
RECODE mnactic (3=1) (4=1) (1=0) (2=0) (5 thru 9 = 0)
    (ELSE=SYSMIS) into dummy_werkloos.
VARIABLE LEVEL dummy_werkloos (NOMINAL).
CROSSTABS
  /TABLES=mnactic BY dummy_werkloos
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*Soort dienstverband (ZZP'er/zelfstandige, loondienst, eigenaar [ref.]).
RECODE emplrel (1=0) (2=1) (3=0) (ELSE=SYSMIS)
    into dummy_zelfstandige.
VARIABLE LEVEL dummy_zelfstandige (NOMINAL).
RECODE emplrel (1=1) (2=0) (3=0) (ELSE=SYSMIS)
    into dummy_loondienst.
VARIABLE LEVEL dummy_loondienst (NOMINAL).
RECODE emplrel (1=0) (2=0) (3=1) (ELSE=SYSMIS)
    into dummy_eigenaar.
VARIABLE LEVEL dummy_eigenaar (NOMINAL).
CROSSTABS
  /TABLES=emplrel BY dummy_zelfstandige
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=emplrel BY dummy_loondienst
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
CROSSTABS
  /TABLES=emplrel BY dummy_eigenaar
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
* (3) Dummy Welvaartsstaatregime aanmaken (Ierland kent geen rechts-populistische partijen met als gevolg dat UK het enige liberale regime is
    Ik kies er daarom voor om liberale en conservatieve regimes samen te voegen).
COMPUTE dummy_sociaaldemocratisch=0.
IF (Cntry EQ 'NL' OR
    Cntry EQ 'FR' OR
    Cntry EQ 'DE' OR
    Cntry EQ 'BE' OR
    Cntry EQ 'GB' ) dummy_sociaaldemocratisch=0.
IF (Cntry EQ 'SE' OR
    Cntry EQ 'DK' OR 
    Cntry EQ 'NO' ) dummy_sociaaldemocratisch=1.
VARIABLE LEVEL dummy_sociaaldemocratisch (NOMINAL).
CROSSTABS
  /TABLES=cntry BY dummy_sociaaldemocratisch
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT 
  /COUNT ROUND CELL.
* (4) MIPEX-data aanmaken (zonder Ierland).
COMPUTE MIPEX = 0.
IF (cntry EQ 'BE') MIPEX = 69.
IF (cntry EQ 'NL') MIPEX = 55.
IF (cntry EQ 'DE') MIPEX = 58.
IF (cntry EQ 'GB') MIPEX = 56.
IF (cntry EQ 'FR') MIPEX = 56.
IF (cntry EQ 'DK') MIPEX = 54.
IF (cntry EQ 'NO') MIPEX = 71.
IF (cntry EQ 'SE') MIPEX = 86.
VARIABLE LEVEL MIPEX (SCALE).
fre MIPEX.
CROSSTABS
  /TABLES=cntry BY MIPEX
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
* (5) Threat (waargenomen bedreiging) hoeft niet / is al gedaan.
fre Threat.
* (6) Aandeel mensen met een migratieachtergrond (zonder Ierland).
COMPUTE perc_migranten = 0.
IF (cntry EQ 'BE') perc_migranten = 27.5.
IF (cntry EQ 'NL') perc_migranten = 21.4.
IF (cntry EQ 'DE') perc_migranten = 21.4.
IF (cntry EQ 'GB') perc_migranten = 26.
IF (cntry EQ 'FR') perc_migranten = 26.8.
IF (cntry EQ 'DK') perc_migranten = 11.5.
IF (cntry EQ 'NO') perc_migranten = 19.5.
IF (cntry EQ 'SE') perc_migranten = 30.8.
VARIABLE LEVEL perc_migranten (SCALE).
fre perc_migranten.
CROSSTABS
  /TABLES=cntry BY perc_migranten
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


**** Beschrijvende statistieken.
* (1) Tabel samenstellen met alle variabelen via custom tables (N, Bereik, M, SD) per land.
CTABLES
  /VLABELS VARIABLES=dummy_rightwing Threat dummy_sociaaldemocratisch perc_migranten MIPEX agea 
    R_gndr R_Rlgueim eduyrs hinctnta rlgdgr dummy_werkloos dummy_zelfstandige dummy_loondienst 
    dummy_eigenaar dummy_partnerschap dummy_geenpartner dummy_gescheiden dummy_samenwonend 
    dummy_grootstedelijk dummy_stedelijk dummy_landelijk cntry 
    DISPLAY=LABEL
  /TABLE dummy_rightwing [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] 
    + Threat [TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + 
    dummy_sociaaldemocratisch [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] 
    + perc_migranten [TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + MIPEX 
    [TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + agea [TOTALN F40.0, 
    MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + R_gndr [S][TOTALN F40.0, MINIMUM F40.2, 
    MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + R_Rlgueim [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM 
    F40.2, MEAN F40.2, STDDEV F40.2] + eduyrs [TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, 
    STDDEV F40.2] + hinctnta [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] 
    + rlgdgr [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_werkloos 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_zelfstandige 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_loondienst 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_eigenaar 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_partnerschap 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_geenpartner 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_gescheiden 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_samenwonend 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_grootstedelijk 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_stedelijk 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] + dummy_landelijk 
    [S][TOTALN F40.0, MINIMUM F40.2, MAXIMUM F40.2, MEAN F40.2, STDDEV F40.2] BY cntry
  /CATEGORIES VARIABLES=cntry ['BE', 'DE', 'DK', 'FR', 'GB', 'IE', 'NL', 'NO', 'SE'] EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.


**** Outliers checken in niet-categorische data.
GRAPH
  /HISTOGRAM=agea.
FREQUENCIES agea.
GRAPH
  /HISTOGRAM=eduyrs.
FREQUENCIES eduyrs.


**** Hypothese 1a: Inwoners die meer waargenomen bedreiging rapporteren ten aanzien van migranten 
    hebben meer kans op steun voor een rechts-populistische partij (inclusief 'grandmodel' voor mediatie').
* (1) Voorwaarden logistische regressie checken.
**Variable type 
    X = schaal
    Y = nominaal (0 1)
**Onafhankelijke observaties.
**Geen multicollineariteit ~ VIF 1 ~ dit kan gewoon via een lineaire regressie.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT dummy_rightwing
  /METHOD=ENTER Threat MIPEX dummy_sociaaldemocratisch
  /SCATTERPLOT=(*ZPRED ,*ZRESID).
**Lineaire relatie X met Y(logit) ~ Box-Tidwell Transformation zonder Ierland en alleen mensen die gestemd hebben.
COMPUTE Logit_threat = Threat.
IF (Threat GT 0) Logit_threat = LN(Threat)*Threat.
USE ALL.
COMPUTE Logit_threatinteractie = Logit_threat*Threat.
EXECUTE.
COMPUTE filter_$=(Logit_threat > 0 and cntry ~= 'IE' and vote=1).
VARIABLE LABELS filter_$ "Logit_threat > 0 and cntry ~= 'IE' and vote=1 (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER Threat Logit_threatinteractie 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
FILTER OFF.
USE ALL.
EXECUTE.
* (2) Alleen mensen die gestemd hebben meenemen in de analyse via filter en zonder Ierland.
USE ALL.
COMPUTE filter_$=(vote=1 and cntry ~= 'IE').
VARIABLE LABELS filter_$ "vote=1 and cntry ~= 'IE' (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
* (3) Logistische regressie.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER Threat 
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend 
  /METHOD=ENTER dummy_sociaaldemocratisch MIPEX 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
**** Hypothese 1b: De relatie tussen waargenomen bedreiging ten aanzien van migranten 
    en kans op steun voor een rechts-populistische partij wordt versterkt door het aantal migranten in een land.
* (1) Laat het filter aanstaan.
* (2) Multicollineariteit checken ~ Value Inflation Factor (VIF) 1 ~ dit kan gewoon via een lineaire regressie.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT dummy_rightwing
  /METHOD=ENTER Threat perc_migranten
  /SCATTERPLOT=(*ZPRED ,*ZRESID).
* (3) Box-Tidwell Transformation is al nagegaan. Er is sprake van een lineaire relatie tussen X en Y(logit).
* (4) Bereken de interactievariabele.
COMPUTE Cross_ThreatPercmigranten = Threat*perc_migranten.
EXECUTE.
* (5) Logistische regressie.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER Threat perc_migranten Cross_ThreatPercmigranten agea R_gndr R_blgetmg eduyrs 
    dummy_deciel2 dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 
    dummy_deciel9 dummy_deciel10 rlgdgr dummy_werkloos dummy_zelfstandige dummy_loondienst 
    dummy_grootstedelijk dummy_stedelijk dummy_getrouwd dummy_partnerschap dummy_samenwonend 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).


**** Hypothese 2a: Inwoners uit sociaaldemocratische welvaartsstaatregimes hebben minder kans op steun voor een rechts-populistisch partij
    dan inwoners uit een liberaal of conservatief welvaartsstaatregime.
* (1) Laat het filter aanstaan.
* (2) Multicollineairiteit hoef ik niet te checken.
* (3) Box-Tidwell Transformation hoef ik niet te checken.
* (4) Logistische regressie.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER dummy_sociaaldemocratisch 
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).


**** Hypothese 3a: Inwoners uit landen met een beter integratiebeleid hebben minder kans op steun voor een rechts-populistisch partij
    dan inwoners uit een land met een slecht integratiebeleid.
* (1) Voorwaarden logistische regressie checken.
**Variable type 
    X = schaal
    Y = nominaal (0 1)
* (2) Multicollineairiteit hoef ik niet te checken.
* (3) Lineaire relatie X met Y(logit) ~ Box-Tidwell Transformation zonder Ierland en alleen mensen die gestemd hebben.
FILTER OFF.
USE ALL.
EXECUTE.
COMPUTE Logit_MIPEX = MIPEX.
IF (MIPEX GT 0) Logit_MIPEX = LN(MIPEX)*MIPEX.
COMPUTE Logit_MIPEXinteractie = Logit_MIPEX*MIPEX.
EXECUTE.
USE ALL. 
COMPUTE filter_$=(Logit_MIPEX > 0 and cntry ~= 'IE' and vote=1).
VARIABLE LABELS filter_$ "Logit_MIPEX > 0 and cntry ~= 'IE' and vote=1 (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER MIPEX Logit_MIPEXinteractie 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
FILTER OFF.
USE ALL.
EXECUTE.
**Polynominal regression uitvoeren. Er is blijkbaar een 'optimaal' optimaal punt in de MIPEX
    Ik centreer hierbij geen controlevariabelen.
DESCRIPTIVES MIPEX.
COMPUTE MIPEX.gecentreerd = MIPEX-58.9573.
EXECUTE.
FREQUENCIES MIPEX.gecentreerd.
*Gecentreerde MIPEX = 0 = 59.
COMPUTE MIPEX.gecentreerd.squared = MIPEX.gecentreerd**2.
EXECUTE.
FREQUENCIES MIPEX.gecentreerd.squared.
* (4) Alleen mensen die gestemd hebben meenemen in de analyse via filter en zonder Ierland.
USE ALL.
COMPUTE filter_$=(vote=1 and cntry ~= 'IE').
VARIABLE LABELS filter_$ "vote=1 and cntry ~= 'IE' (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
* (5) Regressie uitvoeren.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER MIPEX.gecentreerd MIPEX.gecentreerd.squared 
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

**** Hypothese 2b en Hypothese 3b: Hypotheses 2a en 3a kunnen verklaard worden via 'waargenomen bedreiging ten aanzien van migranten'.
* (1) Filter aan laten staan.
* (2) Run twee aparte lineaire modellen op Y (waargenomen bedreiging ten aanzien van migranten).
* (3) Test assumpties van lineariteit.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER dummy_sociaaldemocratisch
  /SCATTERPLOT=(*ZPRED ,*ZRESID)
  /SAVE COOK.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER MIPEX
  /SCATTERPLOT=(*ZPRED ,*ZRESID)
  /SAVE COOK.
* (4) Lineaire regressie.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER dummy_sociaaldemocratisch
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER MIPEX
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend.


**** Padanalyse ophalen.
* (1) Standardized beta weights berekenen voor X1,M,X2 op Y.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER dummy_sociaaldemocratisch MIPEX Threat 
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend
  /SAVE=PRED
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
DESCRIPTIVES VARIABLES=dummy_sociaaldemocratisch Threat MIPEX PRE_1
  /STATISTICS=MEAN STDDEV.
* (2) Standardized beta weights berekenen voor X1,X2 op M.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER MIPEX dummy_sociaaldemocratisch
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend.


**** Losse mediatie-effecten ophalen.
* (1) Soc.democratisch en Threat op steun rechts-populistisch.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER dummy_sociaaldemocratisch Threat 
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend
   /SAVE=PRED
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
DESCRIPTIVES VARIABLES=dummy_sociaaldemocratisch Threat PRE_2
  /STATISTICS=MEAN STDDEV.

* (2) MIPEX op dummy_rightwing.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER MIPEX
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend
   /SAVE=PRED
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
DESCRIPTIVES VARIABLES=MIPEX PRE_3
  /STATISTICS=MEAN STDDEV.

* (3) MIPEX,threat op dummy_rightwing.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER MIPEX Threat
  /METHOD=ENTER agea R_gndr R_blgetmg eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_zelfstandige dummy_loondienst dummy_grootstedelijk dummy_stedelijk 
    dummy_getrouwd dummy_partnerschap dummy_samenwonend
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
DESCRIPTIVES VARIABLES=MIPEX threat
  /STATISTICS=MEAN STDDEV.
