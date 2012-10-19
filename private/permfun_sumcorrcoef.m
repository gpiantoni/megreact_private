function [val1 val2] = permfun_sumcorrcoef(cfg, corrmat)
%PERMFUN_SUMCORRCOEF sum correlation coefficient of all the scores
%
% CFG

% sum of the upper triangular
val1 = sum(sum(triu(sum(corrmat(:,:,:,1), 3), 1), 2), 1);
val2 = sum(sum(triu(sum(corrmat(:,:,:,2), 3), 1), 2), 1);