clear all
format bank
load('riskfree.mat')
load('survProb.mat')

%% PARAMS
M            = 50;       % years of coverage
N            = 10000000; % number of simulations
RD           = 2/100;    % regular deduction
COMM         = 1.4/100;  % commission fee
x            = 60;       % age of policyholder
fixedFees    = 50;       % yearly fees ex-inflation
inflation    = 2/100;    % yearly inflation
sigma        = 0.25;     % fund volatility
probLapse    = 0.15;     % yearly lapse rate
benefit_cost = 20;       % commission contingent on benefits
guarantee    = 110/100;  % guaranteed return on premium (case of death)
F0           = 100000;   % premium
riskfree     = riskfree; % riskfree zero rates
survProb     = survProb; % probabilities of survival

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

benefitNPV = 0.*lapseT;
revenueNPV = 0.*lapseT;
expenseNPV = 0.*lapseT;

for ii=1:numel(benefitNPV)
    
    % LAPSE
    % note: years with death+lapse are counted as lapse
    if (lapseT(ii) <= deathT(ii)) && (lapseT(ii) <= size(F,2))
        % lapse benefit = fund - cost
        benefitNPV(ii) = (F(ii, lapseT(ii)) - benefit_cost)* discounts(lapseT(ii));
        
        % revenues and operating expenses
        revenueNPV(ii) = sum(P(ii,1:lapseT(ii)).*discounts(1:lapseT(ii))) ...
                         + benefit_cost*discounts(lapseT(ii));
        expenseNPV(ii) = sum(fixedFees .* discounts(1:lapseT(ii)) .* (1 + inflation).^(1:lapseT(ii)));
    
    % DEATH
    elseif (deathT(ii) < lapseT(ii)) && (deathT(ii) <= size(F,2))
        % death benefit = fund (with guarantee) - cost
        benefitNPV(ii) = (max(guarantee*F0, F(ii, deathT(ii))) - benefit_cost)* discounts(deathT(ii));
        
        % revenues and operating expenses
        revenueNPV(ii) = sum(P(ii,1:deathT(ii)).*discounts(1:deathT(ii))) ...
                         + benefit_cost*discounts(deathT(ii));
        expenseNPV(ii) = sum(fixedFees .* discounts(1:deathT(ii)) .* (1 + inflation).^(1:deathT(ii)));
    
    % NEITHER
    else
        % assume that all remaining policyholders lapse at the end of
        % the time horizon
        benefitNPV(ii) = (F(ii,end)-benefit_cost)*discounts(end);
                
        % revenues and operating expenses
        revenueNPV(ii) = sum(P(ii,1:M).*discounts(1:M)) ...
                         + benefit_cost*discounts(M);
        expenseNPV(ii) = sum(fixedFees .* discounts(1:M) .* (1 + inflation).^(1:M));
    end
end

profitNPV = revenueNPV - expenseNPV;
mean(benefitNPV);
mean(profitNPV);

BEL = mean(benefitNPV) - mean(profitNPV);