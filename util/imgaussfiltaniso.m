% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

function [img, G] = imgaussfiltaniso( img, sigma, l, half_filter)

    if nargin < 2
        sigma = 4;
    end
    if nargin < 4
        half_filter = false;
    end
    if nargin < 3
        l = 3 * sigma;
    end

    if (length(sigma) == 1)
        G = fspecial('gauss', [2 * l + 1, 2 * l + 1], sigma);
        [X,Y] = meshgrid(-l:l, -l:l);
    else
        G1 = fspecial('gauss', [2 * l(1) + 1, 1], sigma(1));
        G2 = fspecial('gauss', [1, 2 * l(2) + 1], sigma(2));
        G = G1 * G2;
        [X,Y] = meshgrid(-l(2):l(2), -l(1):l(1));
    end
    
    angle_weight = abs(Y ./ (sqrt(X.^2 + Y.^2)));
    angle_weight(ceil(size(angle_weight, 1) / 2), ...
                 ceil(size(angle_weight, 2) / 2)) = 1;
    G = G .* angle_weight;
    if half_filter
        G(l+2:end, :) = 0;
    end
    G = G ./ sum(G(:));
    
    img = imfilter(img, G, 'symmetric');
end