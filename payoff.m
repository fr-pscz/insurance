function B = payoff(premium, fund, lapse, death, discounts)
    cost = 20;
    guarantee = 110/100;
    
    [tmpLapse, lapseT] = max(lapse,[],2);
    [tmpDeath, deathT] = max(death,[],2);
    
    lapseT(tmpLapse==0) = size(fund,2) + 100;
    deathT(tmpDeath==0) = size(fund,2) + 100;
    
    B = 0.*lapseT;
    
    for ii=1:numel(B)
        if (lapseT(ii) <= deathT(ii)) && (lapseT(ii) <= size(fund,2))
            B(ii) = (fund(ii, lapseT(ii)) - cost)* discounts(lapseT(ii));
        elseif (deathT(ii) < lapseT(ii)) && (deathT(ii) <= size(fund,2))
            B(ii) = (max(guarantee*premium, fund(ii, deathT(ii))) - cost)* discounts(deathT(ii));
        else
            B(ii) = 0;
        end
    end
end

