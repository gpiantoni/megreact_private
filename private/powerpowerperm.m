function [pvalue, over] = powerpowerperm(cfg, allcorr, pairtask)
%POWERPOWERPERM do the permutation test on the t-statistic matrix
% Use as:
% [pvalue, overlap] = powerpowerperm(cfg, ALLcorr, pairtask)
%
% Arguments:
%   cfg.threshold = the one used by powerpowerstat (default = .05)
%   cfg.plotperm = anything (apart from empty), will plot hist with distr
%   ALLcorr = output of powerpowercorr for all the subj/cond (150,150,8,2)
%             or (150,150,x,2), with x any number of subjects
%   pairtask = output of powerpowerstat on the task data.
%
% Output:
%   pvalue = the first for MTT, the second for FNA
%   overlap = the distribution for MTT, and for FNA
%
% See also POWERPOWERCORR, POWERPOWERSTAT

% 10/08/03 added time feedback
% 10/01/21 values are not encoded as 1,-1 but as 1 and 3 (and all possible combinations)
% 09/12/04 it works with any number of subjects (because AAT has only 7)
% 09/12/03 added comment from Nichols & Holmes (2002)
% 09/12/02 created

if size(allcorr,1)~= size(allcorr,2) || size(allcorr,4)~=2 % if the dimensions don't match
  error('dimensions are not consistent')
end
nsubj = size(allcorr, 3);

allcombi = combn([1 2], nsubj); % combn is from Matlab Exchange

for k = 1: size(allcombi,1)
  if mod(k, 50) == 0; fprintf('|'); 
  elseif mod(k, 10) == 0; fprintf('.'); end
  
  [data1, data2] = shuffle(allcorr, allcombi(k,:));
  
  pairsleep = sel_tstat(cfg, data1, data2);
  
  overlap = pairsleep + pairtask; % calculate overlap
  overlap = squareform(overlap); % squareform, otherwise they'll be counted twice
  
  over.MTT(k) = numel(find(overlap == 2 | overlap == 5 | overlap == 8));
  over.FNA(k) = numel(find(overlap == 6 | overlap == 7 | overlap == 8));
end

testMTT   = over.MTT(1);
testFNA   = over.FNA(1);

% The P-value is the proportion of the permutation distribution greater
% than or equal to T. Here the actual labeling (no. 6 with t6 = +9.45)
% gives the largest mean difference of all the possible labeling, so the
% P-value is 1/20 = 0.05. For a test at given alp1.ha level, we reject the null
% hypothesis if the P-value is less than alpha, so we conclude that there is
% significant evidence against the null hypothesis of no activation at this
% voxel at level alpha = 0.05. (Nichols & Holmes, 2002, Hum Brain Mapp).

% So, we use "greater than or equal to" and we don't subtract the
% statistic of interest itself from the distribution. This leads to the
% fact that we'll never be able to have a significant p-value after
% bonferroni correction if we do more than 13 test!
% So, even if it's extremely significant 1/256 = .0039, but we have 25
% comparisons, the p-value becomes p-value becomes .05/25 = .002

pvalue(1) = numel(find(over.MTT >= testMTT)) / size(allcombi,1);
pvalue(2) = numel(find(over.FNA >= testFNA)) / size(allcombi,1);

fprintf('\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHUFFLE: subfunction of POWERPOWERPERM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [corr1, corr2] = shuffle(corr, sel)
%SHUFFLE creates two matrices, made of parts from CORR, but depending on
%the selection given by allcombi

nsubj = size(corr, 3);

% it's not elegant, but it works well

sel1 =     sel;
sel2 = 3 - sel;

for k = 1:nsubj
  corrsub{k} = corr(:, :, k, :);
end

corr1 = [];
for k = 1:nsubj
  corr1 = cat(3, corr1, corrsub{k}(:,:,:, sel1(k)) );
end

corr2 = [];
for k = 1:nsubj
  corr2 = cat(3, corr2, corrsub{k}(:,:,:, sel2(k)) );
end
end