% Date     : 17.07.2020
% Author   : Philipp Flotho

function [img, v_ref, reference, groundTruthMap] = generate_synth_ERP(rng_idx, v_ref)
    run('../set_path.m');

    load('ERPexample.mat', 'ERPexample');
    reference = circshift(ERPexample(1, :), -20);
    clear ERPexample;

    [~, idx] = findpeaks(reference);
    
    kernel_size = 71;

    n_trials = 400;
    width = length(reference);

    tmp = sin(linspace(0, 1, n_trials) * 3 * pi)-1;

    if nargin >= 1
        rng(rng_idx);
    else
        rng(20);
    end
    
    img = repmat(reference, n_trials, 1);
    
    if nargin < 2
        v_ref = zeros(size(img));
        
        % global displacements: 
        max_disp = 1;
        v_ref = zeros(size(img));
        prev_rand = 0;
        for i = 1:n_trials
            prev_rand = (rand - 0.5) * max_disp + prev_rand;
            v_ref(i, :) = prev_rand;
        end

        v_ref(1, :) = 0;
        
        % local displacements
        for i = 1:n_trials
            v_ref(i, idx(1)-10:idx(1)+ 10) = v_ref(i, 1) + normrnd(0, 0.5);
            v_ref(i, idx(2)-15:idx(2)+ 15) = v_ref(i, 1) + normrnd(0, 2);
        end
        v_ref = imgaussfilt2(v_ref, [0, 5]);
    end
    
    m = width;
    n = n_trials;
    [X, Y] = meshgrid(1:m, 1:n);
    F = scatteredInterpolant(...
        X(:) + v_ref(:), ...
        Y(:) + zeros(m * n, 1), img(:));
    groundTruthMap = F(X, Y);
    img = groundTruthMap + ...
        imgaussfilt2(normrnd(0, 2, n_trials, width), [0, 2]) + ...
        normrnd(0, 0.5, n_trials, width);
end

