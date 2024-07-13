$TITLE Retail Cafe

SETS
d day of the week /Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday/
s store /Bucks, Negro, Taste, Flower/
p person (waiter) /Emily, John, Sarah, Mike/
;

ALIAS (d2, d);
ALIAS (p2, p);
ALIAS (s2, s);

PARAMETERS
Profit(s) profit per unit in store s /Bucks 0.6, Negro 0.8, Taste 0.9, Flower 0.7/
Sales(d) number of total units sold per day /Monday 250, Tuesday 250,
Wednesday 300, Thursday 450,Friday 550, Saturday 700, Sunday 650/
Reception(d) number of total units received per day /Monday 550, Tuesday 500,
Wednesday 500, Thursday 500,Friday 550, Saturday 550, Sunday 0/

MaxRec max number of units a store can receive per day /150/
MinStock min number of units in a store /100/

Wage(p) wage per day of person p /Emily 100, John 150, Sarah 120, Mike 110/
ExtraP(p) extra profit earned by person p /Emily 0.18, John 0.25, Sarah 0.22, Mike 0.20/

ExtraCost(p) extra cost per day from transferring person to another store /Emily 30,
John 45, Sarah 36, Mike 33/

MaxSameStore max num of days per week a person can work in the same store /3/
MinDays min days of work a person must work /4/
MaxDays max days of work a person can work /6/
BigNumber M /1000000/
NegBigNumber m /-1000000/
;

TABLE NotBaseStore(p,s) equals 1 if not person's base store - otherwise 0
        Bucks   Negro   Taste   Flower
Emily   0       1       1       1
John    1       0       1       1
Sarah   1       1       0       1
Mike    1       1       1       0
;

VARIABLES
X(d,s,p) bin var if p worked in s on day d 
Y1(d,s) units recepted in s on day d 
Y2(d,s) units sold in s on day d

UnitsLeft(d,s) amount of units left at store s at the end of day d

OFV obj func value
;

BINARY VARIABLES X;
POSITIVE VARIABLES Y1, Y2;

EQUATIONS
OF obj func

MAXUNITS(d,s) each store can receive max 150 units
UNITSPERSTORE(d) sum of units per store = total units
MAXUNITSSOLD(d) max total units sold

MAXDAYSSAMESTORE(s,p) max num of days a waiter can work in the same store
MINDAYSPERSON(p) min days person must work per week
MAXDAYSPERSON(p) max days person can work per week

ONESTOREONLY(s,d) only 1 person can work in a store on day d
ONEPERSONONLY(p,d) 1 person can only work at 1 store on day d

UNITSLEFTGREATER(d,s,d2) units left at the end of every day must be greater than MinStock
UNITSLEFTGREATER_M(d,s) monday
UNITSLEFTCALC(d,s,d2) calculation of UnitsLeft variable
UNITSLEFTCALC_M(d,s) monday

Y2_1(d,s) Y2=0 if noone is working in s on day d
Y2_2(d,s) Y2=0 if noone is working in s on day d
Y_MAX(d,s)

ADDED_1(d,p,p2) John and Mike must work on the same days
ADDED_2(d,s,p,s2,p2) Emily stays at Bucks -> Sarah stays at Taste

ADDED_3(d,p) Emily and John can't work at the weekend
ADDED_4(d,s,p) all the waiters want to work outside of their base store
;

OF .. OFV =E= SUM((d,s,p), Y2(d,s) / CARD(p) *(1+ExtraP(p))*Profit(s)- X(d,s,p)*Wage(p) - X(d,s,p)*NotBaseStore(p,s)*ExtraCost(p));

MAXUNITS(d,s) .. Y1(d,s) =L= MaxRec;
UNITSPERSTORE(d) .. SUM(s, Y1(d,s)) =E= Reception(d);
MAXUNITSSOLD(d) .. SUM(s, Y2(d,s)) =L= Sales(d);

MAXDAYSSAMESTORE(s,p) .. SUM(d, X(d,s,p)) =L= MaxSameStore;
MINDAYSPERSON(p) .. SUM((d,s), X(d,s,p)) =G= MinDays;
MAXDAYSPERSON(p) .. SUM((d,s), X(d,s,p)) =L= MaxDays;

ONESTOREONLY(s,d) .. SUM(p, X(d,s,p)) =L= 1;
ONEPERSONONLY(p,d) .. SUM(s, X(d,s,p)) =L= 1;

UNITSLEFTGREATER(d,s,d2)$(ord(d)=ord(d2)+1) .. UnitsLeft(d2, s) + Y1(d,s) - Y2(d,s) =G= MinStock;
UNITSLEFTGREATER_M(d,s)$(ord(d)=1) .. MinStock + Y1(d,s) - Y2(d,s) =G= MinStock;
UNITSLEFTCALC(d,s,d2)$(ord(d)=ord(d2)+1) .. UnitsLeft(d,s) =E= UnitsLeft(d2, s) + Y1(d,s) - Y2(d,s);
UNITSLEFTCALC_M(d,s)$(ord(d)=1) .. UnitsLeft(d,s) =E= MinStock + Y1(d,s) - Y2(d,s);

Y2_1(d,s) .. Y2(d,s) =L= SUM(p, X(d,s,p)) * BigNumber;
Y2_2(d,s) .. Y2(d,s) =G= SUM(p, X(d,s,p)) * NegBigNumber;


ADDED_1(d,p,p2)$(ord(p)=2 and ord(p2)=4) .. SUM(s, X(d,s,p)) =E= SUM(s, X(d,s,p2));

ADDED_2(d,s,p,s2,p2)$(ord(s)=1 and ord(p)=1 and ord(s2)=3 and ord(p2)=3) .. X(d,s,p) =L= X(d,s2,p2);

ADDED_3(d,p)$((ord(d)=6 or ord(d)=7) and (ord(p)=1 or ord(p)=2)) .. SUM(s, X(d,s,p)) =E= 0;

ADDED_4(d,s,p)$(ord(p) = ord(s)) .. X(d,s,p) =E= 0;



$ontext
MODEL RETAILCAFE0 /OF, MAXUNITS, MAXUNITSSOLD, UNITSPERSTORE, MAXDAYSSAMESTORE, MINDAYSPERSON,
MAXDAYSPERSON, ONESTOREONLY, ONEPERSONONLY, UNITSLEFTGREATER, UNITSLEFTGREATER_M,
UNITSLEFTCALC, UNITSLEFTCALC_M, Y2_1, Y2_2/;

SOLVE RETAILCAFE0 MAXIMIZING OFV USING MIP;
$offtext

$ontext
MODEL RETAILCAFEA /OF, MAXUNITS, MAXUNITSSOLD, UNITSPERSTORE, MAXDAYSSAMESTORE, MINDAYSPERSON,
MAXDAYSPERSON, ONESTOREONLY, ONEPERSONONLY, UNITSLEFTGREATER, UNITSLEFTGREATER_M,
UNITSLEFTCALC, UNITSLEFTCALC_M, Y2_1, Y2_2,
ADDED_1/;

SOLVE RETAILCAFEA MAXIMIZING OFV USING MIP;
$offtext

$ontext
MODEL RETAILCAFEB /OF, MAXUNITS, MAXUNITSSOLD, UNITSPERSTORE, MAXDAYSSAMESTORE, MINDAYSPERSON,
MAXDAYSPERSON, ONESTOREONLY, ONEPERSONONLY, UNITSLEFTGREATER, UNITSLEFTGREATER_M,
UNITSLEFTCALC, UNITSLEFTCALC_M, Y2_1, Y2_2,
ADDED_2/;

SOLVE RETAILCAFEB MAXIMIZING OFV USING MIP;
$offtext

*$ontext
MODEL RETAILCAFEAB /OF, MAXUNITS, MAXUNITSSOLD, UNITSPERSTORE, MAXDAYSSAMESTORE, MINDAYSPERSON,
MAXDAYSPERSON, ONESTOREONLY, ONEPERSONONLY, UNITSLEFTGREATER, UNITSLEFTGREATER_M,
UNITSLEFTCALC, UNITSLEFTCALC_M, Y2_1, Y2_2,
ADDED_1, ADDED_2, ADDED_4/;

SOLVE RETAILCAFEAB MAXIMIZING OFV USING MIP;
*$offtext











