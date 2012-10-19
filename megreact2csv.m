function [output] = megreact2csv(cfg)
%MEGREACT2CSV function to read results from

%-------------------------------------%
%'gclean
if strcmp(cfg.dataorig, 'gclean')
  output = sprintf('%d,%d,%d,%d,', ...
    cfg.gtool.bad_samples.MADs, ...
    cfg.gtool.bad_channels.MADs, ...
    cfg.gtool.eog.correction, ...
    cfg.gtool.emg.correction);
  
  if cfg.sortscore
    output = [output 'sorted,'];
  else
    output = [output 'unsorted,'];
  end
  
else
  output = '';
  
end
%-------------------------------------%

%-------------------------------------%
%-manual ICA
output = [output sprintf('%d,%d,%d,', ...
  cfg.ntrial.task, cfg.ntrial.sleep, cfg.newtrl)];

output = [output cfg.megreact.fun ','];

output = [output sprintf('%1.2f,%s,', ...
  cfg.megreact.cfg.threshold, cfg.megreact.cfg.ttest)];
%-------------------------------------%

%-------------------------------------%
%-read results
fid = fopen([cfg.log filesep 'megresults.csv'], 'r');
output = [output fgetl(fid)];
fclose(fid);
%-------------------------------------%

