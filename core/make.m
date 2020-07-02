% Date     : 17.07.2019
% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

function make(varargin)  
    clear functions;
    clear mex;

    if exist(fullfile(pwd, ['align_core.' mexext]), 'file')
        delete(fullfile(pwd, ['align_core.' mexext]));
    end
    if exist(fullfile(pwd, ['align_core.' mexext '.pdb']), 'file')
        delete(fullfile(pwd, ['align_core.' mexext '.pdb']));
    end
    
    mex(varargin{:}, 'align_core.cpp');
end