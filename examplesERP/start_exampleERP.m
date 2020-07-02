% author: David Thinnes
% date:  07/02/2020

%% set path
run('set_path_functionsERP');
load('ERPexample');

close all
clc

[Reg,V] = Var_Alignment(ERPexample,'mean',1,200);