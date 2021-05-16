* Encoding: UTF-8.
**Datamatrix maken.
DATA LIST /ID 1-3 SEX 5 (A) AGE 7-8 OPINION1 TO OPINION5 10-14.
*zie dit als volgt:
    (1) De eerste variabele (ID) heeft een width van drie (oftewel beslaat drie kolommen)
    -------------------------------------------------------------- ruimte tussen de variabelen in de datamatrix [kolom vier]
    (2) De variabele SEX begint bij kolom vijf én is een string (A)
    -------------------------------------------------------------- ruimte tussen de variabelen in de datamatrix [kolom zes]
    (3) De variabele AGE begint bij kolom zeven en heeft een width van twee (oftewel beslaat twee kolommen)
    -------------------------------------------------------------- ruimte tussen de variabelen in de datamatrix [kolom negen]
    (4) De variabele OPINION1 , OPINION2 , OPINION3 , OPINION4 , OPINION 5
    beginnen bij kolom tien en hebben een width van vier [* vijf]
    .
*waardes.
BEGIN DATA
001 m 28 12212
002 f 29 21212
003 f 45 32145
END DATA.

*testset.
data list /Leeftijd 1-2 Gender 4 (A) Yrsedu 6-7.
begin data
21 m 10
22 f 10
40 m 20
50 m 10
60 f 10
70 f 20
end data.

**Script.
*Zoek in Yrsedu voor waardes tussen 0 tot 10 en retourneer bij elke rij die voldoet aan dit statement '0'.
do if range(Yrsedu,0,10).
compute opleiding_hoog = 0.
*Voor statements die niet voldoen aan het eerste argument,
retourneer alles tussen 11 en 20 als '1'.
else if range(Yrsedu,11,20).
compute opleiding_hoog = 1.
end if.
frequencies opleiding_hoog.

