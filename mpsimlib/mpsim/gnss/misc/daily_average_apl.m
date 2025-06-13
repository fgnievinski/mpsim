% daily average APL:
function apl2 = daily_average_apl (apl)
    apl.doy_trunc = fix(apl.doy);
    [apl2.doy_trunc, count] = unique2(apl.doy_trunc);
    apl2.doy_trunc(count == 1) = [];  % discard dangling epoch at the end.
    apl2.doy_mid = apl2.doy_trunc + 0.5;  % noon of each day.
    %f = {'n','e','u','doy'};
    f = fieldnames(apl);
    for j=1:length(f)
        apl2.(f{j}) = NaN(size(apl2.doy_trunc));
    end
    for i=1:length(apl2.doy_trunc)
        idx = ( abs(apl.doy - apl2.doy_mid(i)) <= (0.5+eps) );
        apl2.doy_range(i,:) = max(apl.doy(idx)) - min(apl.doy(idx));
        for j=1:length(f)
            apl2.(f{j})(i) = mean(apl.(f{j})(idx));
        end
    end

    % apl2.doy will be a mean day, therefore the best epoch 
    % for which the other averages refer to.
end

%!test
%! temp = [...
%!           182      0.00376     -0.00019     -0.00234
%!        182.25      0.00379      -6e-005     -0.00311
%!         182.5      0.00372     -0.00015     -0.00372
%!        182.75      0.00382       5e-005     -0.00414
%!           183      0.00378       3e-005     -0.00425
%!        183.25      0.00366       1e-005     -0.00469
%!         183.5      0.00361     -0.00011     -0.00484
%!        183.75      0.00377      0.00025     -0.00415
%!           184      0.00356       0.0003     -0.00358
%!        184.25      0.00356      0.00057     -0.00381
%!         184.5      0.00357      0.00051     -0.00315
%!        184.75      0.00365      0.00063     -0.00253
%!           185      0.00337      0.00055     -0.00156
%! ];
%! apl.doy = temp(:,1);
%! apl.n   = temp(:,2);
%! apl.e   = temp(:,3);
%! apl.u   = temp(:,4);
%!  
%! temp2 = [...
%!           182      0.00376     -0.00019     -0.00234
%!        182.25      0.00379      -6e-005     -0.00311
%!         182.5      0.00372     -0.00015     -0.00372
%!        182.75      0.00382       5e-005     -0.00414
%!           183      0.00378       3e-005     -0.00425
%!        183.25      0.00366       1e-005     -0.00469
%!         183.5      0.00361     -0.00011     -0.00484
%!        183.75      0.00377      0.00025     -0.00415
%!           184      0.00356       0.0003     -0.00358
%!        184.25      0.00356      0.00057     -0.00381
%!         184.5      0.00357      0.00051     -0.00315
%!        184.75      0.00365      0.00063     -0.00253
%!           185      0.00337      0.00055     -0.00156
%! ];
%! apl2.doy = [...
%!      182.5
%!      183.5
%!      184.5
%! %     185.0
%! ];
%! temp = mean(temp2( 1:5 ,:), 1);
%!   apl2.n(1,1) = temp(2);
%!   apl2.e(1,1) = temp(3);
%!   apl2.u(1,1) = temp(4);
%! temp = mean(temp2( 5:9 ,:), 1);
%!   apl2.n(2,1) = temp(2);
%!   apl2.e(2,1) = temp(3);
%!   apl2.u(2,1) = temp(4);
%! temp = mean(temp2( 9:13,:), 1);
%!   apl2.n(3,1) = temp(2);
%!   apl2.e(3,1) = temp(3);
%!   apl2.u(3,1) = temp(4);
%! %temp = mean(temp2(13:13,:), 1);
%! %  apl2.n(4,1) = temp(2);
%! %  apl2.e(4,1) = temp(3);
%! %  apl2.u(4,1) = temp(4);
%! 
%! apl2b = daily_average_apl (apl);
%! %apl2, apl2b  % DEBUG
%! %apl2.n, apl2b.n, apl2.n-apl2b.n  % DEBUG
%! myassert(apl2b.n, apl2.n)
%! myassert(apl2b.e, apl2.e)
%! myassert(apl2b.u, apl2.u)
%! myassert(apl2b.doy, apl2.doy)

