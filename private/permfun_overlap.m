function [val1 val2] = permfun_overlap(cfg, corrmat)
%PERMFUN_OVERLAP function called by permutationtest
%
% CFG
%  .pair1: a chan X chan matrix with overlap values (1 or 3)

pairsleep = sel_tstat(cfg, corrmat(:,:,:,1), corrmat(:,:,:,2));

overlap = pairsleep + cfg.pair1; % calculate overlap
overlap = squareform(overlap); % squareform, otherwise they'll be counted twice

val1 = numel(find(overlap == 2 | overlap == 5 | overlap == 8));
val2 = numel(find(overlap == 6 | overlap == 7 | overlap == 8));