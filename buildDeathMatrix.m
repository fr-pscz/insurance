function deathMat = buildDeathMatrix(simMat,surv)
A = repmat(surv,size(simMat,1),1);
deathMat = simMat >= A;
end

