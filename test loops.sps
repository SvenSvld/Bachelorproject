* Encoding: UTF-8.
*Simpel loopscript in SPSS met strings.


data list free/name(a10).
begin data
Anneke Martin Stefan
end data.

compute count_e = 0.
loop # = 1 to char.length(name).
if char.substr(name,#,1) = 'e' 
    count_e = count_e + 1.
end loop.
exe.

compute count_num = 0.
loop # = 1 to count_e.
if count_e > 0
    count_num = count_e + 1.
end loop.
exe.

do if count_num = 0.
    recode count_num (0=1).
end if.
exe.

compute count_num2 = 0.
loop # = 1 to count_num.
if count_num > 0
    count_num2 = count_num + 1.
end loop.
exe.

