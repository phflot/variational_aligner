% Author: David Thinnes
% date:  07/02/2020
% Copyright 2020 by David Thinnes, All rights reserved.

%% set path
run('set_path_functionsERP');
load('ERPexample');

close all
clc

[Reg,V] = Var_Alignment(ERPexample,'mean',1,200);