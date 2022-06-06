%% SIMULATE LAPSE
lapse  = rand(N,M);
lapse  = lapse <= probLapse;

%% SIMULATE DEATH
death = rand(N,M);
death = death >= repmat(survProb(x:x+M-1)',N,1);

%% SIMULATE FUND
g = randn(N,M);

% time steps
T  = 1:M;
dT = ones(1,M);

% interest rates
riskfree  = riskfree(1:M)';
forwards  = riskfree.*T - [1 riskfree(1:end-1)].*(T-1);
discounts = exp(-riskfree.*T);

F       = zeros(N,M); % fund value
P       = zeros(N,M); % profits collected from fund

% at each step, the fund evolves like a GBM with:
%   drift     = forward rate
%   diffusion = volatility
% then, RD (proportional) is deducted from the fund value

F(:,1) = F0*exp((forwards(1) - sigma^2/2) + sigma.*g(:,1))*(1-RD);
P(:,1) = F0*exp((forwards(1) - sigma^2/2) + sigma.*g(:,1))*(RD-COMM);

for ii = 2:M
    F(:,ii) = F(:,ii-1).*exp((forwards(ii) - sigma^2/2) + sigma.*g(:,ii))*(1-RD);
    P(:,ii) = F(:,ii-1).*exp((forwards(ii) - sigma^2/2) + sigma.*g(:,ii))*(RD-COMM);
end


%% COMPUTATION
% <event>T is the time of the <event>, except when <event> did not happen
[lapseHappened, lapseT] = max(lapse,[],2);
[deathHappened, deathT] = max(death,[],2);

% If <event> did not happen, <event>T is set to a very large number
lapseT(~lapseHappened) = size(F,2) + 100;
deathT(~deathHappened) = size(F,2) + 100;

benefitD = zeros(N,M);
benefitL = zeros(N,M);
benefit = zeros(N,M);
revenue = zeros(N,M);
expense = zeros(N,M);

for ii=1:N
    
    % LAPSE
    % note: years with death+lapse are counted as lapse
    if (lapseT(ii) <= deathT(ii)) && (lapseT(ii) <= size(F,2))
        % lapse benefit = fund - cost
        benefit(ii,lapseT(ii))  = F(ii, lapseT(ii)) - benefit_cost;
        benefitL(ii,lapseT(ii)) = benefit(ii,lapseT(ii));
        
        % revenues and operating expenses
        revenue(ii,1:lapseT(ii)) = P(ii,1:lapseT(ii));
        expense(ii,1:lapseT(ii)) = fixedFees .* discounts(1:lapseT(ii)) .* (1 + inflation).^(1:lapseT(ii));
    
    % DEATH
    elseif (deathT(ii) < lapseT(ii)) && (deathT(ii) <= size(F,2))
        % death benefit = fund (with guarantee) - cost
        benefit(ii,deathT(ii)) = max(guarantee*premium, F(ii, deathT(ii))) - benefit_cost;
        benefitD(ii,deathT(ii)) = benefit(ii,deathT(ii));
        
        % revenues and operating expenses
        revenue(ii,1:deathT(ii)) = P(ii,1:deathT(ii));
        expense(ii,1:deathT(ii)) = fixedFees .* discounts(1:deathT(ii)) .* (1 + inflation).^(1:deathT(ii));
    
    % NEITHER
    else
        % assume that all remaining policyholders lapse at the end of
        % the time horizon
        benefit(ii,M) = F(ii, M) - benefit_cost;
        benefitL(ii,M) = benefit(ii,M);
        % revenues and operating expenses
        revenue(ii,1:M) = P(ii,1:M);
        expense(ii,1:M) = fixedFees .* discounts(1:M) .* (1 + inflation).^(1:M);
    end
end

deathNPV = mean(benefitD*discounts(1:M)');
lapseNPV = mean(benefitL*discounts(1:M)');
benefitNPV = mean(benefit*discounts(1:M)');
revenueNPV = mean(revenue*discounts(1:M)');
expenseNPV = mean(expense*discounts(1:M)');

profitNPV = revenueNPV - expenseNPV;


BEL    = benefitNPV - profitNPV;
ASSETS = F0;
BOF    = ASSETS - BEL;

BEL_cfs = mean(benefit + expense - revenue,1);
Mac_D = sum((1:M).*BEL_cfs.*discounts(1:M))/BEL;
