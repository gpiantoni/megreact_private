function [pairplot tstatV] = sel_tstat(cfg, cmat1, cmat2)
%SEL_TSTAT select more extreme values
%based on powerpowerstat
%
% CFG
%  .threshold = .05 (valid for both methods)
%  .neighbourdist = if specified, don't consider neighbouring sens (4cm)
%  
% Output (optional) is
%  1. the matrix with 1 for thresholded MTT pairs, and 3 for FNA pairs
%  2. the matrix with tvalues for each pair
%
% Note on the method: 'ttest' is the method we discussed with Eus, Ole and
% had significant results. However, connections are relevative to the other
% task. With 'corr' you just get the sensor pairs that have the highest
% correlation coefficient (mean over the subjects). Only with 'corr' you
% get reject the neighbouring sensors (but no significant results)
%
% See also SPAGHETTIPLOT, POWERPOWERCORR, POWERPOWERPERM

%-----------------%
%-check input
if ~isfield(cfg, 'threshold');  cfg.threshold      = .05; end
if ~isfield(cfg, 'ttest');      cfg.ttest      = 'fasterttest2'; end
nsubj = size(cmat1,3);
%-----------------%

%-------------------------------------%
%-t-test method (comparison of the two tasks)

% %-----------------%
% %-get the t-values (version 1)
% [h, p, ci, stats]  = ttest2(corrmat1, corrmat2, [], [], [], 3);
% tstat    = stats.tstat;
% tstat(isnan(tstat))= 0;
% tstatV   = squareform(tstat); % it's a vector
% %-----------------%

%-----------------%
% get the t-values (version 2), faster (half time), attention to transpose
%-------%
%-diagonal
cmat1(cmat1 == 1) = 0;
cmat2(cmat2 == 1) = 0;

%-NaN
cmat1(isnan(cmat1)) = 0;
cmat2(isnan(cmat2)) = 0;
%-------%

%-------%
%-convert to vector
npairs    = @(x) (size(x,1) ^2 - size(x,1))/2;
sqcmat1 = zeros( npairs(cmat1), nsubj);
sqcmat2 = zeros( npairs(cmat1), nsubj);
for k = 1:nsubj
  sqcmat1(:,k) = squareform(cmat1(:,:,k));
  sqcmat2(:,k) = squareform(cmat2(:,:,k));
end
clear cmat1 cmat2
%-------%

[tstatV] = feval(cfg.ttest, sqcmat1', sqcmat2'); % be careful for the transpose!!!
%-----------------%
%-------------------------------------%

% select sensor pairs of interest
allpairs = size(tstatV, 2);
nsens    = round(allpairs * cfg.threshold); % how many sensor pairs

if any(isnan(tstatV))
  allpairs = size(tstatV, 2) - numel(find(isnan(tstatV)));
  nsens    = round(allpairs * cfg.threshold);
  tstatV( isnan( tstatV)) = 0;
end

sort_tstat         = sort(tstatV);

sel1 = allpairs-nsens : allpairs; % channels at the end (high tstat)
sel2 = 1 : nsens+1; % channels at the beginning (low tstat)

[~, pairs1]  = intersect(tstatV, sort_tstat(sel1));
[~, pairs2]  = intersect(tstatV, sort_tstat(sel2));

pairplot = zeros(size(tstatV));
pairplot(pairs1) = pairplot(pairs1) + 1;
pairplot(pairs2) = pairplot(pairs2) + 3;

pairplot = squareform(pairplot);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FASTERTTEST2
function [ratio] = fasterttest2(x, y)
% I just copied the relevant piece of code from ttest2,
% this is the only part we need

nx = size(x,1);
ny = size(y,1);

s2x = var(x);
s2y = var(y);
difference = mean(x) - mean(y);
dfe = nx + ny - 2;
sPooled = sqrt(((nx-1) .* s2x + (ny-1) .* s2y) ./ dfe);
se = sPooled .* sqrt(1./nx + 1./ny);
ratio = difference ./ se;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MEANR1
function [ratio] = meanr1(x, y)
ratio = nanmean(x - y,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MEANR2
function [ratio] = meanr2(x, y)
ratio = nanmean(x,1) - mean(y,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FASTERTTEST
function [ratio] = fasterttest(x, y)
% I just copied the relevant piece of code from ttest,
% this is the only part we need

x = x - y;

samplesize = size(x,1);

xmean = nanmean(x,1);
sdpop = nanstd(x,[],1);
ser = sdpop ./ sqrt(samplesize);
ratio = xmean ./ ser;
end
