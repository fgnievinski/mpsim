function answer = snr_po_delay_grad (answer)
    %% Horizontal gradient of the delay:
    [temp1,temp2] = gradient(answer.map.delay, ...
        answer.info.x_domain, answer.info.y_domain);
    answer.map.delay_grad = sqrt(temp1.^2 + temp2.^2);
    answer.map.phase_grad = [];  % DEPRECATED
    
%     %% Horizontal distance between successive elements (in the order of delay):
%     temp = [answer.map.x(:), answer.map.y(:)];
%     temp = temp(answer.map.ind_delay(:),:);
%     temp = sqrt(sum(diff(temp,1,1).^2,2));
%     temp(end+1) = NaN;  % (diff() returns one fewer element)
%     answer.map.dist_horiz = temp(ind_delay_inv);
%     %answer.map.dist_horiz = getel(temp, ind_delay_inv);
%     answer.map.cum_dist_horiz = getel(cumsum(temp), ind_delay_inv(:));
end

