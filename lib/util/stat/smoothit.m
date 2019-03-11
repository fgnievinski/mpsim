function varargout = smoothit (x, y, dx, xi, f, ...
ignore_nans, input_x, ignore_self, return_as_cell, verbose, ...
force_row_input_if_scalar)
%SMOOTHIT  Data smoother (running average or other user-specified function).
% this is faster when the sampling spacing of the smoothed results is much
% greater than the sampling spacing of the original data (e.g, original
% data is given every second and smoothed version is needed every hour).

    if (nargin < 4) || isempty(xi),  xi = x;  end
    assert(~isa(xi, 'function_handle') && ~iscell(xi))
    if isscalar(xi) && ~isscalar(dx)
        warning('MATLAB:smoothit:badInputOrder', ...
            'Third and fourth input arguments seem misexchanged in order.')
    end
    if isscalar(xi) && isinf(xi)
        xi = linspaceout(min(x), max(x), dx)';
    end
    assert(~islogical(xi))
    if (nargin < 5) || isempty(f)
        f = {@mean};
        if (nargout > 2),  f{2} = @std;   end
    end
    if (nargin < 06) || isempty(ignore_nans),     ignore_nans    = true;   end
    if (nargin < 07) || isempty(input_x),         input_x        = false;  end
    if (nargin < 08) || isempty(ignore_self),     ignore_self    = false;  end
    if (nargin < 09) || isempty(return_as_cell),  return_as_cell = false;  end
    if (nargin < 10) || isempty(verbose),         verbose        = false;  end
    if (nargin < 11) || isempty(force_row_input_if_scalar), force_row_input_if_scalar = false;  end    
    
    if ~iscell(f),  f = {f};  end
    if ~input_x
        % some smoothing functions don't require both x and y values:
        f = arrayfun2(@(i) @(x,y,xi) f{i}(y), reshape(1:numel(f), size(f)));
    end
    
    [n, p, ms, yi, f_colvec] = get_sizes (y, xi, f);
    
    if ignore_nans,  idx_notnan = ~anynan(y, 2);  end
    for i=1:n
        if verbose && is_multiple(i, round(0.01*n));  fprintf('%3.0f%% done\n', 100*i./n);  end
        idx = ((xi(i) - dx/2) <= x & x <= (xi(i) + dx/2));
        if ignore_nans,  idx = idx & idx_notnan;  end
        if ignore_self,  idx(x==xi(i)) = false;   end
        %[sum(idx), f(x(idx))], pause  % DEBUG
        %disp(sum(idx)), x(idx), f(x(idx)), pause  % DEBUG
        switch sum(idx)
        case 0
            continue;
        case 1
            % Here we avoid a bug that would be triggered when the averaging 
            % window width is so small that there is only a single 
            % observation within each series, in which case we end up with 
            % a vector instead of a matrix across multiple series; 
            % in that case mean, std would average over different series.
            % 
            % Of course, we could employ @(x) mean(x, 1) to force it to 
            % always treat x as a matrix even when it's a vector, or do 
            % simply yi{k}(i,:) = y(idx,:), but we accept user-defined 
            % averaging functions (kernels) over which we have little 
            % control of yet we wish to handle the user's data correctly.
            for k=1:p
                if force_row_input_if_scalar ...
                || (ms(k) == 1) || (size(y,2) == 1) || f_colvec(k)
                    yi{k}(i,:) = f{k}(x(idx), y(idx,:), xi(i));
                    continue
                end
                for j=1:ms(k)
                    yi{k}(i,j) = f{k}(x(idx), y(idx,j), xi(i));
                end
            end
        otherwise
            for k=1:p
                yi{k}(i,:) = f{k}(x(idx), y(idx,:), xi(i));
            end
        end
    end
    
    temp = cat(finddim(yi), yi, {xi});
    if return_as_cell,  temp = {temp};  end
    varargout = temp;
end

%%
function [n, p, ms, yi, f_colvec] = get_sizes (y_input, xi, f)
    n = length(xi);
    p = numel(f);
    ms = NaN(p, 1);
    yi = cell(p, 1);
    q = 10;
    x_trialn = rand(q,1);
    x_trial1 = rand(1,1);
    y_input1 = y_input(1,:);
    %%y_trial1 = rand(1,size(y_input,2));
    %%y_trialn = rand(q,size(y_input,2));
    % reuse parts of y_input as function f might require it to be integer:
    y_trial1 = y_input1;
    y_trialn = repmat(y_trial1, [q 1]);
    % avoid error 'stats:robustfit:NotEnoughData'
    y_trialn = bsxfun(@times, (1:q)', y_trialn);
    f_colvec = false(p, 1);
    for k=1:p
        out = f{k}(x_trialn,y_trialn,0);
        ms(k) = length(out);
        yi{k} = NaN(n,ms(k));
        try
            out1 = f{k}(x_trial1,y_trial1,0);
            f_colvec(k) = (length(out1) == ms(k));
        catch err
            if ~strcmp(err.identifier, 'stats:robustfit:NotEnoughData')
                rethrow(err)
            end
        end
    end
end

%%
%!test
%! % more complicated averaging kernels:
%! %close all
%! rand('seed',0)
%! n = 100;
%! x = linspace(0,1,n)';
%! y = rand(n,1) + sin(2*pi.*x);
%! f{1} = @(x,y,xi) median(y);
%! f{2} = @(x,y,xi) polyval(polyfit(x,y,2),xi);
%! f{3} = @(x,y,xi) polyval(regress(y, polydesign1a(x, [1 1])), xi);
%! %f{4} = @(x,y,xi) polyval(robustfit(polydesign1a(x, [1 1]), y, [], [], 'off'), xi);
%! ys = smoothit(x,y,0.3,x,f,true,true);
%! keyboard
%! figure
%! plot(x,  y,  '.-k')
%! hold on
%! for i=1:length(f),  plot(x, ys{i}, '.-r');  end
%! %plot(x, ys{4}, '.-b');
%! %error('blah')  % DEBUG

%!test
%! % missing observations should be ignored:
%! rand('seed',0)
%! n = 100;
%! x = linspace(0,1,n)';
%! y = rand(n,1) + sin(2*pi.*x);
%! y(ceil(n*rand)) = NaN;
%! y2 = smoothit(x,y,0.1,x);
%! y3 = smoothit(x,y,0.3,x);
%! x4 = x(1:3:end);
%! y4 = smoothit(x,y,0.3,x4);
%! figure
%! hold on
%! plot(x,  y,  '.-k')
%! plot(x,  y2, '.-r')
%! plot(x,  y3, '.-b')
%! plot(x4, y4, '.-g')
%! %pause  % DEBUG

%!test
%! % multiple averaging functions:
%! randn('seed',0)
%! n = 100;
%! x = linspace(0,1,n)';
%! y = randn(n,1) + sin(2*pi.*x);
%! y2 = smoothit(x,y,0.1,x,{@mean,@std});
%! y3 = smoothit(x,y,0.3,x,{@mean,@std});
%! x4 = x(1:3:end);
%! y4 = smoothit(x,y,0.3,x4,{@mean,@std});
%! figure
%! hold on
%! 
%! plot(x, y, '.-k')
%! errorbar(x,  y2{1}, y2{2}, '.-r')
%! errorbar(x,  y3{1}, y3{2}, '.-b')
%! errorbar(x4, y4{1}, y4{2}, '.-g')

%!test
%! % multime columns:
%! randn('seed',0)
%! n = 100;  m = 3;
%! x = linspace(0,1,n)';
%! temp = horzcat(x, x./2, x./4);
%! y = randn(n,m) + 10*sin(2*pi.*temp);
%! y2 = smoothit(x,y,0.01,x,{@mean,@std});  % keep widht tiny!
%! y3 = smoothit(x,y,0.3,x,{@mean,@std});
%! x4 = x(1:3:end);
%! y4 = smoothit(x,y,0.3,x4,{@mean,@std});
%! whos  % DEBUG
%! 
%! figure
%! for j=1:m
%!   subplot(m,1,j),  hold on
%!   plot(x, y(:,j), '.-k')
%!   errorbar(x,  y2{1}(:,j), y2{2}(:,j), '.-r')
%!   errorbar(x,  y3{1}(:,j), y3{2}(:,j), '.-b')
%!   errorbar(x4, y4{1}(:,j), y4{2}(:,j), '.-g')
%! end

%!test
%! rand('seed',0)
%! n = 100;
%! x = linspace(0,1,n)';
%! y = rand(n,1) + sin(2*pi.*x);
%! y2 = smoothit(x,y,0.1,x);
%! y3 = smoothit(x,y,0.3,x);
%! x4 = x(1:3:end);
%! y4 = smoothit(x,y,0.3,x4);
%! figure
%! hold on
%! plot(x,  y,  '.-k')
%! plot(x,  y2, '.-r')
%! plot(x,  y3, '.-b')
%! plot(x4, y4, '.-g')
