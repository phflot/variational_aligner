% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.
% alternative imgaussfilt with 2D sigma

function img_low = imgaussfilt2(img, sigma)

    l = 3 * sigma;
    
    if (length(sigma) == 1)
        G = fspecial('gauss', [2 * l + 1, 2 * l + 1], sigma);
    elseif (sigma(1) == 0)
        G = fspecial('gauss', [1, 2 * l(2) + 1], sigma(2));
    elseif (sigma(2) == 0)
        G = fspecial('gauss', [2 * l(1) + 1, 1], sigma(1));
    else
        G1 = fspecial('gauss', [2 * l(1) + 1, 1], sigma(1));
        G2 = fspecial('gauss', [1, 2 * l(2) + 1], sigma(2));
        G = G1 * G2;
    end
    
    img_low = imfilter(img, G, 'symmetric');
end
