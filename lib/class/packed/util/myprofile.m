function p = myprofile (func, storage_type, order_opt)
    if (nargin < 3)
        order_opt.step_percent = 5;
        order_opt.step_min = 100;
        order_opt.max = Inf;
    end
        
    i = 1;
    n = 0;
    order = [];
    memsize = [];
    time = [];
    while n <= order_opt.max
        if (n == 1),  continue;  end
        fprintf('Order: %5d\t', n);
        pause(0)

        try
            tic
            s = feval (func, storage_type, n);
        catch s
            if ~strcmp(s.identifier, 'MATLAB:nomem')
                rethrow(s);
            end
            warning(s.identifier, s.message);
            p.order = order;
            p.memsize = memsize;
            p.time = time;
            return;
        end
        t = toc;

        order(i) = n;
        memsize(i) = sum([s.bytes]);
        time(i) = t;
        
        fprintf('Memsize: %4.1f MB\t', memsize(i)./1e6);
        fprintf('Time: %.3f s\t', time(i));
        fprintf('\n');
        pause(0)

        n = n + max(order_opt.step_min, ceil(n*order_opt.step_percent/100));
        i = i + 1;
    end

    p.order = order;
    p.memsize = memsize;
    p.time = time;
end

function s = myprofile_storage (storage_type, n)
    switch storage_type
    case 'full'
        A = zeros(n, n);
    case 'sparse'
        A = sparse([], [], [], n, n, numeltriorder(n));
    case 'packed'
        A = packed(zeros(numeltriorder(n), 1), 'tri', 'u');
    otherwise
        error('Storage type %s unknown.', storage_type);
    end

    s = whos('A');
end

function s = myprofile_chol (storage_type, n)
    state = 'A';
    A = gallery2('minij', n, storage_type);
    
    state = 'R';
    R = chol(A);
    
    s = whos;
end

function s = myprofile_linsolve (storage_type, n)
    A = gallery2('minij', n, storage_type);
    b = ones(n, 1);
    R = chol(A);
    
    switch storage_type
    case 'full'
        %opt.SYM = true;
        %opt.POSDEF = true;
        %x = linsolve (A, b, opt);
        x = R \ (R' \ b);
    case 'sparse'
        x = R \ (R' \ b);
    case 'packed'
        x = trisolve(b, R, struct('type','pp'));
    end

    s = whos;
end


function A = gallery2 (matrix_type, n, storage_type)
    myassert(matrix_type, 'minij');

    if strcmp(storage_type, 'full')
        A = gallery('minij', n);
        return;
    end
    
    data = zeros(numeltri(spalloc(n,n,0)), 1);
    i = 1;
    for d=1:n
        data(i+(1:d)-1) = 1:d;
        i = i + d;
    end
    
    switch storage_type
    case 'sparse'
        [i, j] = ind2sub( [n, n], find(triu(true(n))) );
        A = sparse (i, j, data, n, n, numeltri(spalloc(n,n,0)));
    case 'packed'
        A = packed(data, 'sym', 'u');
    otherwise
        error('Storage type %s unknown.', storage_type);
    end
    
end

%!test

