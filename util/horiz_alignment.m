% Date     : 17.07.2019
% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

function [ registered ] = horiz_alignment( f2, v )

    assert(sum(size(f2(:, :, 1)) == size(v))  == 2, ...
           'imregister sizes do not match, size \n f2 = (%i, %i) v = (%i, %i)', ...
           size(f2, 1), size(f2, 2), size(v, 1), size(v, 2));
        
    D(:, :, 1) = v;
    D(:, :, 2) = zeros(size(v));

    
    registered = zeros(size(f2));
    for i = 1:size(f2, 3)
        registered(:, :, i) = imwarp(f2(:, :, i), D, 'cubic');
    end
end

