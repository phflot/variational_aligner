% author: David Thinnes
% date:  06/27/2020
%% open path
addpath(fullfile(pwd, 'functionsERP'));
load('exampleERP');

close all
clc

[Reg,V] = Var_Alignment(exampleERP,'mean',1,1000);