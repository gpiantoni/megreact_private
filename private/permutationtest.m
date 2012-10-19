function [pvalue, over] = permutationtest(cfg, corrmat)
%POWERPOWERPERM do the permutation test on the t-statistic matrix
% Use as:
% [pvalue, val] = permutationtest(cfg, corrmat)
%
% CFG
%  .fun: function to evaluate data, you'll pass the cfg to the function
%  the function returns two values, one for each condition. The higher the
%  value, the better. Then, this function calculates the value based on the
%  distribution. 
% 
% CORRMAT: a matrix, the third dimension is subj, it'll swap the fourth
%          dimension and create distribution based on the output of your function

nsubj = size(corrmat, 3);
cond1 = [];
cond2 = [];
for i1 = 0:nsubj
  
  perm = nchoosek(1:nsubj, i1);
  
  for i2 = 1:size(perm,1)
    if isempty(perm)
      corrperm = corrmat;
    else
      corrperm = corrmat;
      corrperm(:, :, perm(i2,:), [1 2]) = corrmat(:, :, perm(i2,:), [2 1]);
    end
    
    [val1 val2] = feval(cfg.fun, cfg, corrperm);
    cond1 = [cond1 val1];
    cond2 = [cond2 val2];
  end
end

testcond1   = cond1(1);
testcond2   = cond2(1);

% The P-value is the proportion of the permutation distribution greater
% than or equal to T. Here the actual labeling (no. 6 with t6 = +9.45)
% gives the largest mean difference of all the possible labeling, so the
% P-value is 1/20 = 0.05. For a test at given alp1.ha level, we reject the null
% hypothesis if the P-value is less than alpha, so we conclude that there is
% significant evidence against the null hypothesis of no activation at this
% voxel at level alpha = 0.05. (Nichols & Holmes, 2002, Hum Brain Mapp).

pvalue(1) = numel(find(cond1 >= testcond1)) / numel(cond1);
pvalue(2) = numel(find(cond2 >= testcond2)) / numel(cond2);

over.cond1 = cond1;
over.cond2 = cond2;



