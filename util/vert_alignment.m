% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

function registered = vert_alignment( f2, v)

    f_tmp = permute(f2, [2, 1, 3]);
    v_tmp = v';
    registered = permute(...
        horiz_alignment(f_tmp, v_tmp), [2, 1, 3]);
end

