temp = {...
    ...'mydatebod'
    ...'mydatebow'
    ...'mydateday'
    ...'mydatedayi'
    'mydatedoy'
    'mydatedoyi'
    'mydatedoyw'
    'mydatedoywi'
    'mydategpsw'
    'mydategpswi'
    ...'mydatehod'
    'mydatehour'
    ...'mydatehouri'
    'mydatejd'
    'mydatejdi'
    'mydatemjd'
    'mydatemjdi'
    'mydatenum'
    ...'mydatenumi'
    'mydatesec'
    ...'mydateseci'
    'mydatesod'
    'mydatesodi'
    'mydatesow'
    'mydatesowi'
    ...'mydatestd'
    ...'mydatestdi'
    'mydatestr'
    'mydatestri'
    'mydatevec'
    ...'mydateveci'
    'mydateyear'
    ...'mydatehouri'
};

for i=1:numel(temp)
    disp(temp{i})
    test(temp{i})
end

test('mydatestd_aux', [], fullfile(fileparts(which('mydatestd')), 'private'))
