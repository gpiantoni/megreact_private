function megreact_stat(cfg)
%MEGREACT_STAT does statistics on meg data

%---------------------------%
%-start log
output = sprintf('%s began at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%-------------------------------------%
%-load data
task = {'MT-' 'FN-'};

clear corrmat
for t = 1:numel(cfg.megreact.comp.time)
  for i = 1:numel(task)
    cond = [task{i} cfg.megreact.comp.time{t}];
    load([cfg.dcon 'conn_' cond], 'conn')
    ifreq = cellfun(@(x)x(1), conn.freq) == cfg.megreact.comp.freq(t);
    corrmat(:,:,:,t,i) = squeeze(conn.mat(:,:,1,ifreq,:));
  end
end
%-------------------------------------%

%-------------------------------------%
%-run subfunctions
tmpcfg = [];
switch cfg.megreact.fun
  
  case 'permfun_overlap'
    tmpcfg.threshold = cfg.megreact.cfg.threshold;
    pair1 = sel_tstat(tmpcfg, corrmat(:,:,:,1,1), corrmat(:,:,:,1,2));
    
    tmpcfg = cfg.megreact.cfg;
    tmpcfg.pair1 = pair1;
    
  case 'permfun_sumcorrcoef';

end

tmpcfg.fun = cfg.megreact.fun;
[pval perm] = permutationtest(tmpcfg, squeeze(corrmat(:,:,:,2,:)));

outtmp = sprintf(['cond1:% 6.3f value% 6.3f (against mean% 6.3f)\n' ...
  'cond2:% 6.3f value% 6.3f (against mean% 6.3f)\n'], ...
  pval(1), perm.cond1(1), mean(perm.cond1), ...
  pval(2), perm.cond2(1), mean(perm.cond2));

output = [output outtmp];
%-------------------------------------%

%---------------------------%
%-write csv
fid = fopen([cfg.log filesep 'megresults.csv'], 'w');
fprintf(fid, '%6.3f,%6.3f,%6.3f,%6.3f,%6.3f,%6.3f', ...
  pval(1), pval(2), perm.cond1(1), perm.cond2(1), ...
  mean(perm.cond1), mean(perm.cond2));
fclose(fid);
%---------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s ended at %s on %s after %s\n\n', ...
  mfilename, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%