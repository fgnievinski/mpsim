function answer = std2 (obs)
    myassert(isvector(obs));
    answer = zeros(size(obs));
    m = length(obs);
    n = m - 1;
    means = (sum(obs) - obs) / n;
    for i=1:m
        sqs = (obs-means(i)).^2;
        answer(i) = sqrt( (sum(sqs) - sqs(i)) / (n-1) );
    end
end

%!test
%! obs = [1 2 3 4]';
%! %means = [mean([2 3 4]), mean([1 3 4]), mean([1 2 4]), mean([1 2 3])]'
%! answer = [std([2 3 4]), std([1 3 4]), std([1 2 4]), std([1 2 3])]';
%! myassert (std2 (obs), answer, -eps);

