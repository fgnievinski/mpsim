% packed/:
test('ispacked');

% packed/util/:
test('numeltriorder');
test('numeltri');
test('numeldiag');
test('myprofile');

% packed/@packed/:
test('packed');
test('issym', 'packed');
test('istriu', 'packed');
test('istril', 'packed');
test('isa', 'packed');
test('class', 'packed');
test('isempty', 'packed');
test('size', 'packed');
test('length', 'packed');
test('numel', 'packed');
test('nnz', 'packed');
test('isequal', 'packed');
test('isequalwithequalnans', 'packed');
test('full', 'packed');
test('sparse', 'packed');
test('transpose', 'packed');
test('triu', 'packed');
test('isreal', 'packed');
test('cast', 'packed');
test('double', 'packed');
test('single', 'packed');
test('logical', 'packed');
test('power', 'packed');
test('times', 'packed');
test('plus', 'packed');
test('minus', 'packed');
test('eq', 'packed');
test('lt', 'packed');
test('le', 'packed');
test('and', 'packed');
test('sqrt', 'packed');
test('exp', 'packed');
test('mtimes', 'packed');

test('subsref', 'packed');
test('subsasgn', 'packed');
test('end', 'packed')

test('find', 'packed');
test('display', 'packed');

%test('norm', 'packed');
%test('trifactor_pos', 'packed');
%test('trifactor_sym', 'packed');  % todo.
test('trifactor_gen', 'packed');
%test('tricond_tri', 'packed');
%test('tricond_pos', 'packed');
%test('tricond_sym', 'packed');
%test('tricond_gen', 'packed');
%test('trisolve_tri', 'packed');
%test('trisolve_pos', 'packed');
%test('trisolve_sym', 'packed');
%test('trisolve_gen', 'packed');
%test('triinv_tri', 'packed');
%test('triinv_pos', 'packed');
%test('triinv_sym', 'packed');
%test('triinv_gen', 'packed');
%test('chol', 'packed');
%test('rcond', 'packed');
%test('mldivide', 'packed');

test('ctranspose', 'packed');

% packed/@packed/private/:
test('issym_type', 'packed', 'private');
test('istri_type', 'packed', 'private');
test('isup', 'packed', 'private');
test('islow', 'packed', 'private');
test('get_full_len_by_pkd_len', 'packed', 'private');

end

