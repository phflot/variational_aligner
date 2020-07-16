% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

clear;
close all;

run('../set_path.m');

[img_ch1, v_ref] = get_phantom_linescan(15);
[img_ch2, v_ref] = get_phantom_linescan(20, v_ref);

% input matrix design for multichannel input:
c(:, :, 1) = img_ch1;
c(:, :, 2) = img_ch2;

viz_1 = [2 1.2];
img1 = get_visualization(double(img_ch1'), ...
    double(img_ch2'), viz_1, viz_1);

% Call to the example function for line scan alignment:
% The error The value of 'DisplacementField' is invalid. Expected D to be finite.
% should be solved with higher values of alpha
% there is currently only a mex file wrapper for horizontal alignment
[registered, v] = register_1(c);

v = v';
v_ref = v_ref';

img_reg = get_visualization(double(registered(:, :, 1)'), ...
    double(registered(:, :, 2)'), viz_1, viz_1);

subplot(2, 2, 1)
imagesc(img1)
title('synthetic linescan');
colormap(gca, 'gray')
subplot(2, 2, 2);
imagesc(v_ref);
title('ground truth displacement');
colormap(gca, 'parula')
subplot(2, 2, 3);
imagesc(img_reg);
title('motion compensated');
colormap(gca, 'gray')
subplot(2, 2, 4);
imagesc(v);
title('estimated displacement');
colormap(gca, 'parula')


function [registered, v] = register_1(inputImage)
    
    reg = inputImage;
    v = zeros(size(reg, 1), size(reg, 2));
    
    sigma = [4, 1];
    alpha = [0.05, 0.005];
    a_smooth = [1, 0.5];
    
    % two data passes with different values for alpha an a_smooth
    for i = 1:2
        reg = mat2gray(imgaussfiltaniso(reg, 1));
        [~, v_tmp] = align_lines(...
            reg, ...
            mean(reg(:, :, :), 1), ...
            'sigma', sigma(i), ...
            'eta', 0.9, ...
            'levels', 100, ...
            'iterations', 70, ...
            'alpha', alpha(i), ...
            'a_smooth', a_smooth(i));

        v = v + v_tmp;
        reg = horiz_alignment(inputImage, v);
    end

    registered = horiz_alignment(inputImage, v);
end

% function to generate a synthetic linescan with 
% discontinuity in the displacement and noise contamination
function [img, v_ref] = get_phantom_linescan(rgn_idx, v_ref)

    kernel_size = 71;

    height = 2000;
    width = 200;

    tmp = sin(linspace(0, 1, height) * 3 * pi)-1;

    rng(rgn_idx);
    img = repmat(...
        rand(1, 2*(width-50)) - 0.2 * (rand(1, 2*(width-50))-0.3), ...
        height, 1);
    img = img + 0.05 * rand(height, 1);
    img = convn(padarray(img, [0, 50+floor(kernel_size/2)], 0), 1/kernel_size * ones(1, kernel_size), 'valid');

    v_ref2 = ones(size(img));
    tmp = reshape(tmp, height, 1);
    v_ref2 = v_ref2 .* tmp * 5;
    v_ref2(:, width+1:end) = - v_ref2(:, 1:width);

    if nargin < 2
        max_disp = 1;
        v_ref = zeros(size(img));
        prev_rand = 0;
        for i = 1:height
            v_ref(i, :) = ...
                max_disp * convn(rand(1, 2 * width), 1/81 * ones(1, 81), 'same') - max_disp / 2;
            prev_rand = (rand - 0.5) * 4 + prev_rand;
            v_ref(i, :) = v_ref(i, :) + prev_rand;
        end

    v_ref = v_ref + v_ref2;
    v_ref(1, :) = 0;
    end

    m = 2 * width;
    n = height;
    [X, Y] = meshgrid(1:m, 1:n);
    F = scatteredInterpolant(...
        X(:) + v_ref(:), ...
        Y(:) + zeros(m * n, 1), img(:));
    img = F(X, Y);
    img = mat2gray(imnoise(img, 'gaussian', 0, 0.0005));
end

% Date     : 2019-09-16
% Author   : Philipp Flotho
function img = get_visualization(ch1, ch2, ...
    scaling_left, scaling_right, reference_left, reference_right)

    if (nargin < 6)
        ch1 = ch1 - min(ch1(:));
        ch1 = ch1 ./ max(ch1(:));

        ch2 = ch2 - min(ch2(:));
        ch2 = ch2 ./ max(ch2(:));
    else
        ch1 = ch1 - min(reference_left(:));
        ch1 = ch1 ./ (max(reference_left(:)) - min(reference_left(:)));

        ch2 = ch2 - min(reference_right(:));
        ch2 = ch2 ./ (max(reference_right(:)) - min(reference_left(:)));
    end

    if (nargin >= 4)
        ch1 = scaling_left(1) * ch1 - scaling_left(2);
        ch2 = scaling_right(1) * ch2 - scaling_right(2);
    end


    img(:, :, 1, :) = ch1;
    img(:, :, 2, :) = (ch1 + ch2) * 0.5;
    img(:, :, 3, :) = ch2;
    
    img(img < 0) = 0;
    img(img > 1) = 1;
end
