% In this program we assume only one action will be taken at a time.

block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).
block(i).
time(1..10).

% data, each situation S default fluents on/3
% we give the initial fluents and use frame problem code to generate fluents for time forward 
on(g,h,1).on(h,a,1).on(a,t,1).
on(d,e,1).on(e,b,1).on(b,t,1).
on(i,f,1).on(f,c,1).on(c,t,1).


% Define what means a block is clear at time T.
% The idea is to generate clear/2 based on fluent on/3 at each time.
clear(B,T):- not not_clear(B,T),on(B,O,T). % on/3 here is only for safe rule.
not_clear(B,T):-on(AB,B,T),block(B).

% Code solve the frame axiom problem.
on(B,O,T):- move_on(B,O,T-1),time(T).
on(B,O,T):- on(B,O,T-1),move_on(B1,O1,T-1),B!=B1,time(T).% This rule restrict one action at a time.
on(B,O,T):- not action(T-1),time(T),on(B,O,T-1).
action(T):- move_on(B,O,T).

% Helper functions of 'make_clear/2'.
make_clear_h(B,T):- make_clear(B,T). % for generate atom make_clear_h/2
make_clear_h(B,T+1):- make_clear_h(B,T),not clear(B,T+1),time(T+1). % If block B is not clear after doing 
                                                                  % make_clear at time T, then we would
                                                                  % like to continually clear it in the 
                                                                  % future until it is clear.


% Because we have 2 different ruleapp/3 so we have 2 different higher_rule_s and higher_rule_m.
% We don not want two ruleapps generate 'higher_rule/2' for the other TR procedure, so we give them
% different name.
higher_rule_m(T,Priority):- time(T),
    ruleapp(T,Priority,m),
    ruleapp(T,Priority1,m),
    Priority1<Priority.
higher_rule_s(T,Priority):- time(T),
    ruleapp(T,B,Priority,s),
    ruleapp(T,B,Priority1,s),
    Priority1<Priority.

goal(T):- on(a,b,T),on(b,c,T),on(c,t,T),clear(a,T).

donothing(T):- ruleapp(T,1,m),not higher_rule_m(T,1).
move_on(a,b,T):- ruleapp(T,2,m),not higher_rule_m(T,2).
make_clear(b,T):- ruleapp(T,3,m),not higher_rule_m(T,3).
make_clear(a,T):- ruleapp(T,4,m),not higher_rule_m(T,4).
move_on(b,c,T):- ruleapp(T,5,m),not higher_rule_m(T,5).
make_clear(c,T):- ruleapp(T,6,m),not higher_rule_m(T,6).
make_clear(b,T):- ruleapp(T,7,m),not higher_rule_m(T,7).
move_on(c,t,T):- ruleapp(T,8,m),not higher_rule_m(T,8).
make_clear(c,T):- ruleapp(T,9,m),not higher_rule_m(T,9).

% Actions for sub-task TR procedure 'make_clear/2'
% I do not know wether it is good to let ruleapp have variable B in it
ruleapp(T,B,1,s):- make_clear_h(B,T),clear(B,T).
ruleapp(T,AB,2,s):- make_clear_h(B,T),on(AB,B,T),clear(AB,T).
ruleapp(T,AB,3,s):- make_clear_h(B,T),on(AB,B,T),not clear(AB,T). 
already_clear(B,T):- ruleapp(T,B,1,s),not higher_rule_s(T,1).
move_on(AB,t,T):- ruleapp(T,AB,2,s),not higher_rule_s(T,2).
make_clear_h(AB,T):- ruleapp(T,AB,3,s),not higher_rule_s(T,3).


% S_M
ruleapp(T,P,m):- time(T),rule(1,P).
ruleapp(T,P,m):- goal(T),rule(2,P).
ruleapp(T,P,m):- on(O1,O2,T),rule(3,P,O1,O2).
ruleapp(T,P,m):- clear(B,T),rule(4,P,B).
ruleapp(T,P,m):- goal(T),on(O1,O2,T),rule(5,P,O1,O2).
ruleapp(T,P,m):- goal(T),clear(B,T),rule(6,P,B).
ruleapp(T,P,m):- on(O1,O2,T),clear(B,T),rule(7,P,O1,O2,B).
ruleapp(T,P,m):- on(O1,O2,T),on(O3,O4,T),rule(8,P,O1,O2,O3,O4,B).
ruleapp(T,P,m):- clear(B1,T),clear(B2,T),rule(9,P,B1,B2).
ruleapp(T,P,m):- goal(T),on(O1,O2,T),clear(B,T),rule(10,P,O1,O2,B).
ruleapp(T,P,m):- goal(T),on(O1,O2,T),on(O1,O2,T),rule(11,P,O1,O2,O3,O4).
ruleapp(T,P,m):- goal(T),clear(B1,T),clear(B2,T),rule(12,P,B1,B2).
ruleapp(T,P,m):- clear(B1,T),clear(B2,T),on(O1,O2,T),rule(13,P,B1,B2,O1,O2).
ruleapp(T,P,m):- on(O1,O2,T),on(O3,O4,T),clear(B,T),rule(14,P,O1,O2,O3,O4,B).
ruleapp(T,P,m):- goal(T),on(O1,O2,T),on(O3,O4,T),clear(B,T),rule(15,P,O1,O2,O3,O4,B).
ruleapp(T,P,m):- goal(T),on(O1,O2,T),clear(B1,T),clear(B2,T),rule(16,P,B1,B2,O1,O2).
ruleapp(T,P,m):- on(O1,O2,T),on(O1,O2,T),clear(B1,T),clear(B2,T),rule(17,P,B1,B2,O1,O2).

% Generate hyporheses.

:- move_on(B1,B2,T),not clear(B1,T),not clear(B2,T).

{rule(1,1..9),rule(2,1..9),rule(3,1..9,c,t),
 rule(3,1..9,b,c),rule(4,1..9,a),rule(4,1..9,b),rule(4,1..9,c),
 rule(5,1..9,c,t),rule(5,1..9,b,c),rule(6,1..9,a),rule(6,1..9,b),rule(6,1..9,c),
 rule(7,1..9,c,t,a),rule(7,1..9,c,t,b),rule(7,1..9,c,t,c),
 rule(7,1..9,b,c,a),rule(7,1..9,b,c,b),rule(7,1..9,b,c,c),
 rule(8,1..9,c,t,b,c),
 rule(9,1..9,a,b),rule(9,1..9,b,c),rule(9,1..9,c,a),
 rule(10,1..9,c,t,a),rule(10,1..9,c,t,b),rule(10,1..9,c,t,c),
 rule(10,1..9,b,c,a),rule(10,1..9,b,c,b),rule(10,1..9,b,c,c),
 rule(11,1..9,b,c,c,t),
 rule(12,1..9,a,b),rule(12,1..9,b,c),rule(12,1..9,c,a),
 rule(13,1..9,a,b,c,t),rule(13,1..9,b,c,c,t),rule(13,1..9,c,a,c,t),
 rule(13,1..9,a,b,b,c),rule(13,1..9,b,c,b,c),rule(13,1..9,c,a,b,c),
 rule(14,1..9,b,c,c,t,a),rule(14,1..9,b,c,c,t,b),rule(14,1..9,b,c,c,t,c),
 rule(15,1..9,b,c,c,t,a),rule(15,1..9,b,c,c,t,b),rule(15,1..9,b,c,c,t,c),
 rule(16,1..9,c,t,a,b),rule(16,1..9,c,t,a,c),rule(16,1..9,c,t,c,b),
 rule(16,1..9,b,c,a,b),rule(16,1..9,b,c,a,c),rule(16,1..9,b,c,c,b),
 rule(17,1..9,b,c,c,t,a,b),rule(17,1..9,b,c,c,t,a,c),rule(17,1..9,b,c,c,t,c,b)}.

#minimise[rule(1,1..9)=1,rule(2,1..9)=2,rule(3,1..9,c,t)=2,rule(3,1..9,b,c)=2,
	  rule(4,1..9,a)=2,rule(4,1..9,b)=2,rule(4,1..9,c)=2,rule(5,1..9,c,t)=3,
	  rule(5,1..9,b,c)=3,rule(6,1..9,a)=3,rule(6,1..9,b)=3,rule(6,1..9,c)=3,
	  rule(7,1..9,c,t,a)=3,rule(7,1..9,c,t,b)=3,rule(7,1..9,c,t,c)=3,
 	  rule(7,1..9,b,c,a)=3,rule(7,1..9,b,c,b)=3,rule(7,1..9,b,c,c)=3,
 	  rule(8,1..9,c,t,b,c)=3,
 	  rule(9,1..9,a,b)=3,rule(9,1..9,b,c)=3,rule(9,1..9,c,a)=3,
 	  rule(10,1..9,c,t,a)=4,rule(10,1..9,c,t,b)=4,rule(10,1..9,c,t,c)=4,
 	  rule(10,1..9,b,c,a)=4,rule(10,1..9,b,c,b)=4,rule(10,1..9,b,c,c)=4,
 	  rule(11,1..9,b,c,c,t)=4,
 	  rule(12,1..9,a,b)=4,rule(12,1..9,b,c)=4,rule(12,1..9,c,a)=4,
 	  rule(13,1..9,a,b,c,t)=4,rule(13,1..9,b,c,c,t)=4,rule(13,1..9,c,a,c,t)=4,
 	  rule(13,1..9,a,b,b,c)=4,rule(13,1..9,b,c,b,c)=4,rule(13,1..9,c,a,b,c)=4,
 	  rule(14,1..9,b,c,c,t,a)=4,rule(14,1..9,b,c,c,t,b)=4,rule(14,1..9,b,c,c,t,c)=4,
 	  rule(15,1..9,b,c,c,t,a)=5,rule(15,1..9,b,c,c,t,b)=5,rule(15,1..9,b,c,c,t,c)=5,
 	  rule(16,1..9,c,t,a,b)=5,rule(16,1..9,c,t,a,c)=5,rule(16,1..9,c,t,c,b)=5,
 	  rule(16,1..9,b,c,a,b)=5,rule(16,1..9,b,c,a,c)=5,rule(16,1..9,b,c,c,b)=5,
 	  rule(17,1..9,b,c,c,t,a,b)=5,rule(17,1..9,b,c,c,t,a,c)=5,rule(17,1..9,b,c,c,t,c,b)=5].

goal:- on(c,t,1),on(b,c,6),on(a,b,9),
       on(d,t,2),on(e,t,3),on(f,t,5),
       on(g,t,7),on(h,t,8),on(i,t,4).

:- not goal.

rule_h(1,P):- rule(1,P).
rule_h(2,P):- rule(2,P).
rule_h(3,P):- rule(3,P,O1,O2).
rule_h(4,P):- rule(4,P,B).
rule_h(5,P):- rule(5,P,O1,O2).
rule_h(6,P):- rule(6,P,B).
rule_h(7,P):- rule(7,P,O1,O2,B).
rule_h(8,P):- rule(8,P,O1,O2,O3,O4,B).
rule_h(9,P):- rule(9,P,B1,B2).
rule_h(10,P):- rule(10,P,O1,O2,B).
rule_h(11,P):- rule(11,P,O1,O2,O3,O4).
rule_h(12,P):- rule(12,P,B1,B2).
rule_h(13,P):- rule(13,P,B1,B2,O1,O2).
rule_h(14,P):- rule(14,P,O1,O2,O3,O4,B).
rule_h(15,P):- rule(15,P,O1,O2,O3,O4,B).
rule_h(16,P):- rule(16,P,B1,B2,O1,O2).
rule_h(17,P):- rule(17,P,B1,B2,O1,O2).

:- rule_h(ID1,P1),rule_h(ID2,P2),ID1=ID2,P1!=P2.
:- rule_h(ID1,P1),rule_h(ID2,P2),ID1!=ID2,P1=P2.




#hide.
%#show do(move_on(V1,V2),T).
%#show rule/2.
#show rule(1,P).
#show rule(2,P).
#show rule(3,P,O1,O2).
#show rule(4,P,B).
#show rule(5,P,O1,O2).
#show rule(6,P,B).
#show rule(7,P,O1,O2,B).
#show rule(8,P,O1,O2,O3,O4,B).
#show rule(9,P,B1,B2).
#show rule(10,P,O1,O2,B).
#show rule(11,P,O1,O2,O3,O4).
#show rule(12,P,B1,B2).
#show rule(13,P,B1,B2,O1,O2).
#show rule(14,P,O1,O2,O3,O4,B).
#show rule(15,P,O1,O2,O3,O4,B).
#show rule(16,P,B1,B2,O1,O2).
#show rule(17,P,B1,B2,O1,O2).
