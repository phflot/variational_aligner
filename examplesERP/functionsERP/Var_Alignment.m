function [Reg,V] = Var_Alignment(inputImage,method,iter_ref,Fs)
% Author: David Thinnes
% date:  07/02/2020
% Copyright 2020 by David Thinnes, All rights reserved.

% description:
% the function corrects the latency shift of evoked potentials by choosing a stable
% reference and realigning the 2D Sweep Image of the data

% it performs 1 dimensional alignment according to the selected reference
% method: cross correlation, mean of all image rows 
% default: 'Mean'

% input: 
%===============================================================================================
% type :        input Image (Sweep matrix, Single trial matrix)
% method :      'Cross', 'Mean'                      
% iter_ref :    iterative refinement
% Fs :          Sampling Frequency of the signal

% output
%===============================================================================================
% Reg =         the realigned image after image registration
%   V =         the displacement field of all pixels, samples

% please refere to:
%===============================================================================================
% variational_aligner Philipp Flotho, 2020
% Philipp Flotho David Thinnes, F. I. Corona Strauss, J. F. Vibell  & D.J. Strauss    Fast Variational Method for the Estimation and Quantization of non–flat Displacements in 1D Signals with Applications in Neuroimaging, 2020
% David Thinnes Philipp Flotho, F. I. Corona Strauss, D. J. Strauss  & J.F. Vibell   Compensation of P300 Latency Jitter using fast variational 1D Displacement Estimation, 2020


%% define image size

 % size of inputImage
 L1 = size(inputImage,1);
 L2 = size(inputImage,2);

%% create time vector
L = (L2-1)/Fs;
time  = 0:1/Fs:L;
time = time.*1000;      % in ms
time = time -100;       % first 100 ms are baseline
    
figure('units','normalized','outerposition',[0 0 1 1]);         % fullsize figure
tic;            % start alignment program

%% define the reference
switch method
    
    case 'Cross', case 'cross'
        [ ref ] = CrossCorrRef(inputImage,1);
        ref = inputImage(ref,:);
        ref = mean(ref,1);
        
    case 'Mean' , case 'mean'
        ref = mean(inputImage);
        
    otherwise
        ref = mean(inputImage); % default
end

%% define parameters for the alignment program
s_i = 10;
it_i = 60;
a_i = 0.6;
as_i = 0.5;

s_r = 5;
it_r = 20;
a_r = 0.6;
as_r = 0.5;

%% 1 dimensional displacement estimation, Philipp Flotho 2020

% initial alignment to get the reference (select stable reference measurements):
[~, v] = align_lines(...
    inputImage, ...
    mat2gray(ref), ...
    'sigma',s_i, ...
    'iterations', it_i, ...                         % about 20-150
    'alpha', a_i, ...                               % Smoothness weight: if the codes crashes choose a smaller value / if the result is too uniformly choose a larger value
    'a_smooth', as_i);                              % 0.5 allows discontinuities, 1 smoother transitions
reg = horiz_alignment(inputImage, v);               % inputImage

% second filter with anisotropic gaussian
[reg_filt, ~] = imgaussfiltaniso( reg, 15, 20, true);

% iterative application possible
for tt = 1:iter_ref
    
    % refinement:
    [~, v] = align_lines(...
        inputImage, ...
        mat2gray(mean(reg_filt, 1)), ...
        'v', v, ...
        'sigma', s_r, ...
        'iterations', it_r, ...
        'alpha', a_r, ...
        'a_smooth', as_r);
    
    w(:, :, 1) = double(zeros(size(v)));
    w(:, :, 2) = v;
    
    registered = horiz_alignment(inputImage, v);          % inputImage
    
    [reg_filt, ~] = imgaussfiltaniso( registered, 15, 20, true);
end

%% Save the results
tmp_original = inputImage;
tmp = registered;

Reg = registered;
V = v;

% show elapsed time of the program
elapsedtime = toc;
fprintf(['Elapsed Time Alignment =' num2str(elapsedtime) 'sec \n']);

%% Plot the results

ROI1 = 250;
ROI2 = 400;
x = [ROI1 ROI2  ROI2  ROI1];
y = [(min(mean(tmp))-0.2) (min(mean(tmp))-0.2) (max(mean(tmp))+0.2) (max(mean(tmp))+0.2)];

subplot(2,2,1)
imagesc(tmp_original);
xticklabels = time(1):100:time(end);
xticks = linspace(1, size(time, 2), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
xlabel('time [ms]','FontSize',15);
ylabel('ERP trials','FontSize', 15)
title('Pre Alignment','FontSize', 15);
colorbar;
subplot(2,2,2);
imagesc(tmp);
title('Post Alignment','FontSize', 15);
xticks = linspace(1, size(time, 2), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
xlabel('time [ms]','FontSize',15);
ylabel('ERP trials','FontSize', 15)
colorbar;
subplot(2,2,3);
patch(x,y, [0.85 0.85 0.85]);
hold on;
title('Average of all trials','FontSize', 15);
plot(time,mean(inputImage),'LineWidth', 2); 
mean_tmp = mean(tmp, 1, 'omitnan');
plot(time,mean_tmp,'LineWidth', 2);
legend('ROI','Pre-Alignment','Post-Alignment','Location','NW');
xlim([time(1) time(end)]);
xlabel('time [ms]','FontSize', 15)
ylabel('voltage [\muV]','FontSize', 15)
grid on;
hold off;

% plot displacements for a certain time frame (over a certain trace)
subplot(2,2,4);

Dis = squeeze(mean(v(:, find(time == ROI1):find(time == ROI2) ), 2));
plot(Dis, 'LineWidth', 2);
xlim([1 L1]);
xlabel('number of Sweeps','FontSize', 15)
ylabel('displacements','FontSize', 15)
title(['Mean displacements between  ', num2str(ROI1), ':', num2str(ROI2),'ms'],'FontSize', 15)
grid on;

clear w v registered
end


