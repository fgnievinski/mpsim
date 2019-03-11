function do_test_blockdiag

% blockdiag/
test('isblockdiag');

% blockdiag/@cell/
test('nnz', 'cell(1)');
test('sizes', 'cell(1)');
test('diag', 'cell(1)');

% blockdiag/@blockdiag/
test('blockdiag');
test('cell', 'blockdiag');
test('isempty', 'blockdiag');
test('nnz', 'blockdiag');
test('order', 'blockdiag');
test('isscalar', 'blockdiag');
test('sizes', 'blockdiag');
test('size', 'blockdiag');
test('plus', 'blockdiag');
test('horzcat', 'blockdiag');

test('display', 'blockdiag');

end

