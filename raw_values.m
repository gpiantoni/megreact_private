function raw_values(info, opt)
%RAW_VALUES calculate raw values
%
% INFO
%  .subjall
%  .info.dpow
%  .info.dcon
%
% CFG.OPT
%  .cond: conditions to make average over
%  .time: as SPAGHETTIPLOT, for significant sensors
%  .freq: as SPAGHETTIPLOT, for significant sensors

%---------------------------%
%-start log
output = sprintf('%s began at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------------------------------------%
%-loop over selection of channels, all or only reactivated

selchan{1} = logical(triu(ones(150), 1)); % all the non-identical pairs, once

%-------------------------------------%
%-only significant sensors
%----------------%
%-corrmat
task = {'MT-' 'FN-'};

clear corrmat
for t = 1:numel(opt.time)
  for i = 1:numel(task)
    cond = [task{i} opt.time{t}];
    if strcmp(cond, 'FN-pre-baseline')
      cond = 'FN-pre-trial';
    end
    load([info.dcon 'conn_' cond], 'conn')
    ifreq = nearest(cellfun(@(x)x(1), conn.freq), opt.freq(t));
    corrmat(:,:,:,t,i) = squeeze(conn.mat(:,:,1,ifreq,:));
  end
end
%----------------%

%----------------%
cfg = [];
cfg.threshold = 0.05;
pair_05_1 = sel_tstat(cfg, corrmat(:,:,:,1,1), corrmat(:,:,:,1,2));
pair_05_2 = sel_tstat(cfg, corrmat(:,:,:,2,1), corrmat(:,:,:,2,2));
pair_05_12 = triu((pair_05_1 + pair_05_2) == 2);
%----------------%

selchan{2} = pair_05_12;
%-------------------------------------%

for ch = 1:numel(selchan)
  
  %---------------------------%
  %-
  if ch == 1
    fprintf('\n\t\t\t\t\tAll sensors\n')
  else
    fprintf('\n\t\t\t\t\tOnly reactivated sensors\n')
  end
  %---------------------------%
  
  %-------------------------------------%
  for k = 1:numel(opt.cond)
    condname = regexprep(opt.cond{k}, '*', '');
    disp(condname)
    
    %---------------------------%
    %-select frequency of interest
    if strfind(condname, 'pre')
      freq = 4;
    else
      freq = [1 2 3];
    end
    %---------------------------%
    
    avgp = zeros(numel(info.subjall), numel(freq));
    avgc = zeros(numel(info.subjall), numel(freq));
    
    for subj = 1:numel(info.subjall)
      
      %---------------------------%
      %-load power
      if ch == 1
        dname = sprintf('pow_%04d_%s.mat', info.subjall(subj), condname);
        load([info.dpow dname]);
        for f = 1:numel(freq)
          avgp(subj, f) = nanmean(pow_s.powspctrm(:,freq(f)));
        end
      end
      %---------------------------%
      
      %---------------------------%
      %-load connectivity
      dname = sprintf('conn_%04d_%s.mat', info.subjall(subj), condname);
      load([info.dcon dname]);
      for f = 1:numel(freq)
        stattmp = conn_s.powcorrspctrm(:,:,freq(f));
        stattmp = stattmp(selchan{ch});
        avgc(subj, f) = nanmean(stattmp(:));
      end
      %---------------------------%
      
    end
    
    %---------------------------%
    %-more meaningful units
    if avgp(1) < 1e-8
      avgp = avgp * 1e30;
    else
      avgp = avgp * 1e6;
    end
    %---------------------------%
    
    for f = 1:numel(freq)
      if ch == 1
        fprintf('POW  freq % 2d: mean % 8.3f, std % 8.3f\n', freq(f), mean(avgp(:,f)), std(avgp(:,f)))
      end
      fprintf('CONN freq % 2d: mean % 8.3f, std % 8.3f\n', freq(f), mean(avgc(:,f)), std(avgc(:,f)))
    end
    
  end
  %-------------------------------------%
  
end
%---------------------------------------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s ended at %s on %s after %s\n\n', ...
  mfilename, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%