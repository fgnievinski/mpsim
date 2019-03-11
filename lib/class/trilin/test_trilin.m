priv_dir = fullfile(fileparts(mfilename('fullpath')), 'private');
%priv_dir = fullfile(fileparts(which('test_trilin')), 'private');

test('full_trifactor_check_in', [], priv_dir)
test('trifactor_diag')
test('trifactor_gen')
test('trifactor_pos')
test('trifactor_sym')
test('trifactor_tri')
test('trifactor')

test('full_trisolve_check_in', [], priv_dir)
test('trisolve_diag')
test('trisolve_gen')
test('trisolve_pos')
test('trisolve_sym')
test('trisolve_tri')
test('trisolve')

test('full_triinv_check_in', [], priv_dir)
test('triinv_diag')
test('triinv_gen')
test('triinv_pos')
test('triinv_sym')
test('triinv_tri')
test('triinv')

test('full_tricond_check_in', [], priv_dir)
test('tricond_diag')
test('tricond_gen')
test('tricond_pos')
test('tricond_sym')
test('tricond_tri')
test('tricond')

test('rcond_inv')
test('tri_mldivide')
test('tri_rcond')
test_blank_diag_tri_sym

clear priv_dir

