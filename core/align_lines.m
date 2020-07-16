% Date     : 17.07.2019
% Author   : Philipp Flotho
% Copyright 2020 by Philipp Flotho, All rights reserved.

function [reg, v] = align_lines( f1, f_ref, varargin )

    f1 = permute(f1, [2, 1, 3]);
    f_ref = permute(f_ref, [2, 1, 3]);
    
    alpha = 1;
    sigma = 1;
    iterations = 50;
    update_lag = 5;
    
    smoothing = true;
    
    levels = 40;
    eta = 0.9;
    
    a_smooth = 0.5;
    
    [m, n, n_channels] = size(f1);
    
    weight = ones(size(f1)) * (1/n_channels);
    
    v_init = zeros(m, n);
    
    a_data = 0.5 * ones(1, n_channels);
    sorting = false;

    for k = 1:length(varargin)
        if ~isa(varargin{k}, 'char')
            continue;
        end
        switch varargin{k}
            case 'alpha'
                alpha = varargin{k + 1};
                if length(alpha) == 1
                    alpha = alpha .* ones(1, 2);
                end
            case 'sigma'
                sigma = varargin{k + 1};
            case 'eta'
                eta = varargin{k + 1};
            case 'levels'
                levels = varargin{k + 1};       
            case 'update_lag'
                update_lag = varargin{k + 1};
            case 'iterations'
                iterations = varargin{k + 1};
            case 'smoothing'
                smoothing = varargin{k + 1};
            case 'v'
                v_init = varargin{k + 1}';
            case 'a_data'
                a_data = varargin{k + 1};
                if (length(a_data) == 1)
                    a_data = a_data * ones(1, n_channels);
                end
            case 'a_smooth'
                a_smooth = varargin{k + 1};
            case 'sorting'
                sorting = varargin{k + 1};
            case 'weight'
                weight = varargin{k + 1};
        end
    end
        
    if smoothing
        f1_low = imgaussfilt2(f1, [sigma, 0]);
        f_ref_low = imgaussfilt2(f_ref, [sigma, 0]);
    else
        f1_low = f1;
        f_ref_low = f_ref;
    end
    
    if sorting
        mse = zeros(1, size(f1, 2));
        for i = 1:n
            tmp = sqrt((f_ref - f1(:, i, :)).^2);
            mse(i) = mean(tmp(:));
        end
        [~, order] = sort(mse);
        order = int64([0 order 0]);
        clear mse tmp
    else
        order = int64(0:n+1);
    end
    
    size_old = [1 1];
    
    method = 'bicubic';
    max_level = warpingDepthY(eta, levels, m);
    for i = max_level:-1:1
        f1_level = imresize(f1_low, [m * eta^i, n], method, 'Colormap', 'original', 'Antialiasing', true);
        f_ref_level = imresize(f_ref_low, [size(f1_level, 1), 1], method, 'Colormap', 'original', 'Antialiasing', true);
        
        level_size = [size(f1_level, 1) size(f1_level, 2)];
        
        weight_level = imresize(weight, level_size);
        
        hy = m / size(f1_level, 1);
        hx = 1;
        
        if i == max_level
            v = add_boundary(imresize(v_init, level_size, method, 'Colormap', 'original')); 
            tmp = double(f1_level);
        else
            v = add_boundary(imresize(v(2:end - 1, 2:end - 1), level_size, method, 'Colormap', 'original'));
            tmp = vert_alignment(double(f1_level), double(v(2:end-1, 2:end-1)) / hy);
            tmp(tmp == 0) =  double(f1_level(tmp == 0));
        end

        fy = [];
        fyy = [];
        f_ref_y = [];
        for j = 1:n_channels
            [ fy(:, :, j), fyy(:, :, j), f_ref_y(:, :, j)] = ...
                get_derivatives(...
                tmp(:, :, j), f_ref_level(:, :, j), hx, hy);
        end
        
        dv = align_core(fy, fyy, f_ref_y, ...
            v, alpha, iterations, ...
            update_lag, 0, a_data, a_smooth, hx, hy, order, add_boundary(weight_level));
        
        dv = medfilt2(dv, [5 1]);
        v = v + dv;
        
        size_old = size(f1_level);
    end
    
    hx = 1;
    hy = size(f1, 1) / size_old(1);    
    v = add_boundary(imresize(v(2:end - 1, 2:end - 1), [m, n], method, 'Colormap', 'original', 'Antialiasing', true));
    tmp = vert_alignment(double(f1_low), double(v(2:end-1, 2:end-1)));
    tmp(tmp == 0) = double(f1_low(tmp == 0));
    
    fy = [];
    fyy = [];
    f_ref_y = [];
    for j = 1:n_channels
        [ fy(:, :, j), fyy(:, :, j), f_ref_y(:, :, j)] = ...
            get_derivatives(...
            tmp(:, :, j), squeeze(f_ref_low(:, :, j)), hx, hy);
    end
    dv = align_core(fy, fyy, f_ref_y, ... 
        v, alpha, iterations, ...
        update_lag, 0, a_data, a_smooth, 1, 1, order, add_boundary(weight));
    
    v = v + dv;
    v = v(2:end-1, 2:end-1);
    reg = zeros(size(f1));
    
    reg = permute(vert_alignment(...
        double(f1), double(v)), [2, 1, 3]);
    v = v';
end

function f = add_boundary(f)
    f = padarray(f, [1 1]);
end

function d = warpingDepthY(eta, levels, m)
    warpingdepth = 0;
    d = warpingdepth;

    for i = 1:levels
        warpingdepth = warpingdepth + 1;
        m = m * eta;
        if (round(m) < 10	)
            break;
        end
        d = warpingdepth;
    end
end

function [fy, fyy, f_ref_y] = get_derivatives(f, f_ref, hx, hy)
    
    f = f - min(f, [], 1);
    f = f./ max(f, [], 1);
    
    f_ref = f_ref - min(f_ref(:));
    f_ref = f_ref./ max(f_ref(:));

    f = set_boundary(padarray(f, [1 1], 'symmetric'));

    fyy = zeros(size(f));
    
    fyy(2:end-1, 2:end-1) = ...
        (f(1:end-2, 2:end-1) - 2 * f(2:end-1, 2:end-1) ...
        + f(3:end, 2:end-1)) ./ hy^2;
    
    [~, fy] = gradient(set_boundary(f), hx, hy);
    f_ref_y = gradient([f_ref(2); f_ref; f_ref(end-1)], hy);
end

function f = set_boundary(f)
    f(:, 1) = f(:, 3);
    f(:, end) = f(:, end - 2);
    f(1, :) = f(3, :);
    f(end, :) = f(end - 2, :);
end
