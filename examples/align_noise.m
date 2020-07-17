% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

run('../set_path');

clear
close all
clc

rng(16583);

inputImage = rand(199, 802);
inputImage = imgaussfilt2(inputImage, [0, 5]);

reference = mat2gray(sin(0.1 * (1:802)));

% prefiltering rot. asymmetric kernel:
prefiltered = ...
    mat2gray(imgaussfiltaniso(inputImage, 0.5));

[~, v] = align_lines(...
    prefiltered, ...
    reference, ...
    'sigma', 5, ...
    'iterations', 100, ...
    'eta', 0.9, ...
    'alpha', 1, ...
    'a_data', 0.45, ...
    'a_smooth', 1);

w(:, :, 1) = double(zeros(size(v)));
w(:, :, 2) = v;

registered = horiz_alignment(inputImage, v);

% prefiltering rot. asymmetric kernel:
prefiltered = ...
    mat2gray(imgaussfiltaniso(inputImage, 4));

[~, v2] = align_lines(...
    prefiltered, ...
    reference, ...
    'sigma', 5, ...
    'iterations', 100, ...
    'eta', 0.9, ...
    'alpha', 1, ...
    'a_data', 0.45, ...
    'a_smooth', 1);

w(:, :, 1) = double(zeros(size(v)));
w(:, :, 2) = v;

registered2 = horiz_alignment(inputImage, v2);

tmp = imgaussfiltaniso(registered, 4);

idx = 70:802-70;
Y = 1:size(inputImage, 1);

yLabelText = 'Number of trials';
xLabelText = 'Number of samples';

x0 = 0.2;
y0 = 0.2;
width = 0.6;
height = 0.6;

figure(1)
set(gcf, 'units', 'normalized', 'position', [x0, y0, width, height]);

subplot(3, 2, 1);
imagesc(idx, Y, inputImage(:, idx));

set(gca, 'XTickLabel', []);
ylabel(yLabelText);


title('Random input matrix');
subplot(3, 2, 2);
plot(idx, reference(idx), 'color', [0 0 0] + 0.5, 'LineWidth', 1.5);
hold on
plot(idx, 7*(mean(inputImage(:, idx), 1))-3, '--', 'color', [0 0 0] + 0.5, 'LineWidth', 1);
cb = colorbar;
cb.Visible = 'off';
p = plot(idx, 7*(mean(registered2(:, idx), 1))-3, 'b-');
% p.Color(4) = 0.8;
p = plot(idx, 7*(mean(registered(:, idx), 1))-3, 'r-');
% p.Color(4) = 0.8;
lgd = legend({'reference', 'raw', '\sigma = 4', '\sigma = 0.5'});
lgd.Location = 'southeast';
% grid on
title('Signal Averages');

xlim([min(idx) max(idx)]);
set(gca, 'XTickLabel', []);

box on

subplot(3, 2, 3);
imagesc(idx, Y, registered2(:, idx));
title('Alignment, \sigma = 4');

set(gca, 'XTickLabel', []);
ylabel(yLabelText);

subplot(3, 2, 4);
imagesc(idx, Y, v2(:, idx));

colormap(gca, 'gray');
title('Displacements, \sigma = 4');
colorbar

set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);

subplot(3, 2, 5);
imagesc(idx, Y, registered(:, idx));
ylabel(yLabelText);
xlabel(xLabelText);

title('Alignment, \sigma = 0.5');

subplot(3, 2, 6);
imagesc(idx, Y, v(:, idx));
xlabel(xLabelText);

colormap(gca, 'gray');
title('Displacements, \sigma = 0.5');
colorbar

set(gca, 'YTickLabel', []);