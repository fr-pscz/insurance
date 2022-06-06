%% PARAMS : IR up

load('riskfreeUP.mat')
load('survProb.mat')

M            = 50;        % years of coverage
RD           = 2/100;     % regular deduction
COMM         = 1.4/100;   % commission fee
x            = 60;        % age of policyholder
fixedFees    = 50;        % yearly fees ex-inflation
inflation    = 2/100;     % yearly inflation
sigma        = 0.25;      % fund volatility
probLapse    = 0.15;      % yearly lapse rate
benefit_cost = 20;        % commission contingent on benefits
guarantee    = 110/100;   % guaranteed return on premium (case of death)
premium      = 100000;   % premium
F0           = premium;
riskfree     = riskfreeUP;% riskfree zero rates
survProb     = survProb;  % probabilities of survival