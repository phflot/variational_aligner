% Author   : David Thinnes
%% open path
addpath(fullfile(pwd, 'functions'));
load('exampleERP');

close all
clc

[Reg,V] = Var_Alignment(exampleERP,'mean',1,1000);