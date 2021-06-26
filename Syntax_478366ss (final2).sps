* Encoding: UTF-8.
* Bachelorproject Sven Strating.
**** Ophalen werkdata.
GET
  FILE='C:\Users\svens\OneDrive\Documenten\3_Bachelor_Sociology and Social Research\BLOK '+
    '7+8\Data-analyse\ESS2014.sav'
    /KEEP dweight pspwght pweight hinctnta mainact mnactic eduyrs domicil agea gndr 
    rlgueim imtcjob imbleco imwbcrm blgetmg rlgdgr imwbcnt imueclt imbgeco prtvtbat 
    prtvtcbe prtvtech prtvtdcz prtvede1 prtvede2 prtvtcdk prtvteee prtvtces prtvtcfi 
    prtvtcfr prtvtbgb prtvtehu prtvtaie prtvtcil prtvalt1 prtvalt2 prtvalt3 prtvtfnl 
    prtvtbno prtvtcpl prtvtbpt prtvtbse prtvtesi vote cntry idno icpart1.
DATASET NAME ESS2014 WINDOW=FRONT.
* Ik selecteer alleen de landen die betrekking hebben op dit onderzoek.
SELECT IF NOT (cntry NE 'NL' and cntry NE 'DE' and cntry NE 'GB' 
    and cntry NE 'IE' and cntry NE 'FR' and cntry NE 'DK' 
    and cntry NE 'SE' and cntry NE 'NO' and cntry NE 'BE').
FREQUENCIES cntry.
* Maak een staandaardgewicht aan welke in elke analyse moet worden meegenomen.
COMPUTE anweight=pspwght*pweight.
WEIGHT by anweight.
* Maak een filter aan welke Ierland, mensen (met migratieachtergrond) die niet gestemd hebben uit de analyse haalt.
USE ALL.
COMPUTE filter_$=(vote=1 AND cntry ~='IE' AND blgetmg=2).
VARIABLE LABELS filter_$ "vote=1 AND cntry ~='IE' AND blgetmg=2 (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
CROSSTABS
  /TABLES=cntry BY vote
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
FREQUENCIES blgetmg.


**** Factoranalyse en betrouwbaarheidsanalyse over alle items rondom waargenomen bedreiging.
* (1) Inspecteer variabelen Rlgueim Imtcjob Imbleco Imwbcrm Imwbcnt Imueclt Imbgeco.
VARIABLE LEVEL Rlgueim Imtcjob Imbleco Imwbcrm Imwbcnt Imueclt Imbgeco (ORDINAL).
FREQUENCIES Rlgueim Imtcjob Imbleco Imwbcrm Imwbcnt Imueclt Imbgeco.
* (2) Hercodeer deze variabelen.
RECODE Rlgueim Imtcjob Imbleco Imwbcrm Imwbcnt Imueclt Imbgeco 
    (10=0) (9=1) (8=2) (7=3) (6=4) (5=5) (4=6) (3=7) (2=8) (1=9) (0=10) (ELSE=SYSMIS)
    into R_Rlgueim R_Imtcjob R_Imbleco 
    R_Imwbcrm R_Imwbcnt R_Imueclt R_Imbgeco.
EXECUTE.
VARIABLE LEVEL R_Rlgueim R_Imtcjob R_Imbleco 
    R_Imwbcrm R_Imwbcnt R_Imueclt R_Imbgeco (ORDINAL).
* (3) Split file by cntry.
SORT CASES  BY cntry.
SPLIT FILE SEPARATE BY cntry.
* (4) Run factoranalyse per land.
FACTOR
  /VARIABLES R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm 
  R_Imwbcnt R_Imueclt R_Imbgeco
  /MISSING LISTWISE 
  /ANALYSIS R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm 
  R_Imwbcnt R_Imueclt R_Imbgeco
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
  R_Imwbcnt R_Imueclt R_Imbgeco
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL.
* (6) Split file by cntry uitzetten.
SPLIT FILE OFF.
* (7) Run een factoranalyse voor alle landen.
FACTOR
  /VARIABLES R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm 
  R_Imwbcnt R_Imueclt R_Imbgeco
  /MISSING LISTWISE 
  /ANALYSIS R_Rlgueim R_Imtcjob R_Imbleco R_Imwbcrm 
  R_Imwbcnt R_Imueclt R_Imbgeco
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
  R_Imwbcnt R_Imueclt R_Imbgeco
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL.
* (9) Maak de variabele 'waargenomen bedreiging ten aanzien van migranten' aan.
COMPUTE Threat = MEAN.7(R_Rlgueim,R_Imtcjob,R_Imbleco,
    R_Imwbcrm,R_Imwbcnt,R_Imueclt,R_Imbgeco).
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
FREQUENCIES agea.
*Gender.
RECODE gndr (1=1) (2=0) (ELSE=SYSMIS) into
    R_gndr.
VALUE LABELS R_gndr
    1 Man
    0 Vrouw.
VARIABLE LEVEL R_gndr (NOMINAL).
CROSSTABS
  /TABLES=gndr BY R_gndr
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*Migratieachtergrond (zonder of met).
RECODE blgetmg (1=1) (2=0) (ELSE=SYSMIS) into
    R_blgetmg.
VALUE LABELS R_blgetmg
    1 Met migratieachtergrond
    0 Zonder migratieachtergrond.
VARIABLE LEVEL R_blgetmg (NOMINAL).
CROSSTABS
  /TABLES=blgetmg BY R_blgetmg
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*Opleiding in jaren hoeft niet (eduyrs).
FREQUENCIES eduyrs.
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
FREQUENCIES rlgdgr.
*Werkloos of niet?.
RECODE mnactic (3=1) (4=1) (1=0) (2=0) (5 thru 9 = 0)
    (ELSE=SYSMIS) into dummy_werkloos.
VARIABLE LEVEL dummy_werkloos (NOMINAL).
CROSSTABS
  /TABLES=mnactic BY dummy_werkloos
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
*samenwonend of samenwonend met partner?.
RECODE icpart1 (1=1) (2=0) (ELSE=SYSMIS)
    into dummy_samenwonend.
VARIABLE LEVEL dummy_samenwonend (NOMINAL).
CROSSTABS
  /TABLES=icpart1 BY dummy_samenwonend
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
* (3) Dummy Welvaartsstaatregime aanmaken (Ierland kent geen rechts-populistische partijen 
    met als gevolg dat UK het enige liberale regime is
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
FREQUENCIES MIPEX.
CROSSTABS
  /TABLES=cntry BY MIPEX
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
* (5) Threat (waargenomen bedreiging) hoeft niet / is al gedaan.
FREQUENCIES Threat.


**** Beschrijvende statistieken.
* (1) Alleen valide cases selecteren om te steekproef te beschrijven 
    (ofwel, alleen personen die bij alle vragen een antwoord hebben gegeven).
FILTER OFF.
USE ALL.
EXECUTE.
USE ALL.
COMPUTE filter_$=(((NMIS(hinctnta,eduyrs,agea,Threat,dummy_rightwing,R_gndr,dummy_grootstedelijk,
    dummy_stedelijk,dummy_landelijk,dummy_werkloos,dummy_sociaaldemocratisch,dummy_samenwonend,MIPEX,
    rlgdgr)=0) AND (cntry~='IE') AND (vote=1) AND (R_blgetmg=0))).
VARIABLE LABELS filter_$ "((NMIS(hinctnta,eduyrs,agea,Threat,dummy_rightwing,R_gndr,"+
    "dummy_grootstedelijk,dummy_stedelijk,dummy_landelijk,dummy_werkloos,dummy_sociaaldemocratisch,"+
    "dummy_samenwonend,MIPEX,rlgdgr)=0) AND (cntry~='IE') AND (vote=1) AND (R_blgetmg=0)) (FILTER)".
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
* (2) Tabel samenstellen met alle variabelen via custom tables (N, Bereik, M, SD) per land.
* Custom Tables.
CTABLES
  /VLABELS VARIABLES=dummy_rightwing Threat dummy_sociaaldemocratisch MIPEX agea R_gndr eduyrs 
    hinctnta rlgdgr dummy_werkloos dummy_samenwonend dummy_grootstedelijk dummy_stedelijk 
    dummy_landelijk cntry 
    DISPLAY=LABEL
  /TABLE dummy_rightwing [S][COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + Threat [COUNT 
    F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + dummy_sociaaldemocratisch [S][COUNT F40.0, RANGE 
    F40.2, MEAN F40.2, STDDEV F40.2] + MIPEX [COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + 
    agea [COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + R_gndr [S][COUNT F40.0, RANGE F40.2, 
    MEAN F40.2, STDDEV F40.2] + eduyrs [COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + hinctnta 
    [S][COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + rlgdgr [S][COUNT F40.0, RANGE F40.2, MEAN 
    F40.2, STDDEV F40.2] + dummy_werkloos [S][COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + 
    dummy_samenwonend [S][COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + dummy_grootstedelijk 
    [S][COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV F40.2] + dummy_stedelijk [S][COUNT F40.0, RANGE 
    F40.2, MEAN F40.2, STDDEV F40.2] + dummy_landelijk [S][COUNT F40.0, RANGE F40.2, MEAN F40.2, STDDEV 
    F40.2] BY cntry
  /CATEGORIES VARIABLES=cntry ['BE', 'DE', 'DK', 'FR', 'GB', 'NL', 'NO', 'SE'] EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.


**** Outliers checken in niet-categorische data.
GRAPH
  /HISTOGRAM=agea.
FREQUENCIES agea.
GRAPH
  /HISTOGRAM=eduyrs.
FREQUENCIES eduyrs.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER agea 
  /SAVE=COOK
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER eduyrs
  /SAVE=COOK
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
FREQUENCIES VARIABLES=COO_1 COO_2
  /ORDER=ANALYSIS.


**** Multicollineariteit checken.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT dummy_rightwing
  /METHOD=ENTER Threat dummy_sociaaldemocratisch MIPEX agea R_gndr eduyrs dummy_deciel2 dummy_deciel3 
    dummy_deciel4 dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 
    dummy_deciel10 rlgdgr dummy_werkloos dummy_stedelijk dummy_grootstedelijk 
    dummy_samenwonend.


**** Hypothese 1a: Inwoners zonder migratieachtergrond uit sociaaldemocratische welvaartsstaatregimes 
    hebben minder kans op steun voor een rechts-populistisch partij dan inwoners uit een liberaal 
    of conservatief welvaartsstaatregime.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER dummy_sociaaldemocratisch agea R_gndr eduyrs dummy_deciel2 
    dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 dummy_deciel7 
    dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr dummy_werkloos 
    dummy_stedelijk dummy_grootstedelijk dummy_samenwonend
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).


**** Hypothese 2a: Inwoners zonder migratieachtergrond uit landen met een goed integratiebeleid 
    hebben minder kans op steun voor een rechts-populistisch partij dan inwoners uit een 
    land met een slecht integratiebeleid.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER MIPEX agea R_gndr eduyrs dummy_deciel2 
    dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 dummy_deciel7 
    dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr dummy_werkloos 
    dummy_stedelijk dummy_grootstedelijk dummy_samenwonend
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).


**** Hypothese 3: Inwoners zonder migratieachtergrond die meer waargenomen bedreiging rapporteren 
    ten aanzien van migranten hebben meer kans op steun voor een rechts-populistische partij.
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER Threat agea R_gndr eduyrs dummy_deciel2 dummy_deciel3 dummy_deciel4 
    dummy_deciel5 dummy_deciel6 dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr 
    dummy_werkloos dummy_stedelijk dummy_grootstedelijk dummy_samenwonend 
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).


**** Hypothese H1b/H2b: De relatie tussen sociaaldemocratische welvaartsstaatregimes en MIPEX op steun voor
    rechts-populistische partijen kan verklaard worden via waargenomen bedreiging ten aanzien van migranten
    
* (1b.1) Sociaaldemocratisch op steun rechts-populisme (c, totale effect).
* (1b.2) Sociaaldemocratisch en Threat op steun rechts-populisme (c', directe effect; pad b).
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER dummy_sociaaldemocratisch Threat agea R_gndr eduyrs dummy_deciel2 
    dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 dummy_deciel7 
    dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr dummy_werkloos 
    dummy_stedelijk dummy_grootstedelijk dummy_samenwonend
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
* (1b.3) Sociaaldemocratisch op Threat (pad a).
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER dummy_sociaaldemocratisch agea R_gndr eduyrs dummy_deciel2 
    dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 dummy_deciel7 
    dummy_deciel8 dummy_deciel9 dummy_deciel10 rlgdgr dummy_werkloos 
    dummy_stedelijk dummy_grootstedelijk dummy_samenwonend.

* (2b.1) MIPEX op steun voor rechts-populisme (c, totale effect).
* (2b.2) MIPEX en Threat op steun voor rechts-populisme (c', directe effect; pad b).
LOGISTIC REGRESSION VARIABLES dummy_rightwing
  /METHOD=ENTER MIPEX Threat agea R_gndr eduyrs dummy_deciel2 
    dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 
    dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 
    rlgdgr dummy_werkloos dummy_stedelijk dummy_grootstedelijk 
    dummy_samenwonend
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).
* (2b.3) MIPEX op Threat (pad a).
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Threat
  /METHOD=ENTER MIPEX agea R_gndr eduyrs dummy_deciel2 
    dummy_deciel3 dummy_deciel4 dummy_deciel5 dummy_deciel6 
    dummy_deciel7 dummy_deciel8 dummy_deciel9 dummy_deciel10 
    rlgdgr dummy_werkloos dummy_stedelijk dummy_grootstedelijk 
    dummy_samenwonend.

**** Standaarddeviatie per predictor ophalen.
DESCRIPTIVES VARIABLES=dummy_sociaaldemocratisch MIPEX Threat
  /STATISTICS=MEAN STDDEV MIN MAX.
