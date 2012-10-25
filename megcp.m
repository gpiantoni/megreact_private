function megcp(info, opt, subj)
%MEGNAME cp data that were cleaned with ICA in 2009 from recording folder
%
% OPT
%   .ntrial.task: number of 10s epochs for the task (optional)
%   .ntrial.sleep: number of 30s epochs for the sleep (optional)
%   .newtrl: duration of the new trials
%   .dataorig: 'manualICA' or 'gclean'
%   if gclean, also opt.sleepscore (to sort sleep scores)
%
%   .trial.MT.begin: beginning of the baseline period (5)
%   .trial.MT.end: end of the baseline period (15)
%
%   .trial.FN.begin: beginning of the baseline period (0)
%   .trial.FN.end: end of the baseline period (10)

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

if ~isfield(opt, 'ntrial'); opt.ntrial = []; end
if ~isfield(opt.ntrial, 'task'); opt.ntrial.task = []; end
if ~isfield(opt.ntrial, 'sleep'); opt.ntrial.sleep = []; end

%---------------------------%
%-dir and files
rdir = sprintf('%s%04d/%s/%s/', info.recs, subj, info.mod, 'raw'); % data dir
ddir = sprintf('%s%04d/%s/%s/', info.data, subj, info.mod, info.nick); % data dir

if strcmp(opt.dataorig, 'manualICA')
%   if isdir(ddir); rmdir(ddir, 's'); end
%   mkdir(ddir)
end
%---------------------------%

%-----------------%
%-codes
%-------%
%-in recording
condcode{1} = {'L'};
condcode{2} = {'a' '1' '2'};
condcode{3} = {'2' '3' '4'};
taskcode = {'_a' '_b'};
%-------%

%-------%
%-data
cond = {'pre-trial' 'sleep-WA' 'sleep-N2'};
task = {'MT-' 'FN-'};
%-------%
%-----------------%

%---------------------------%
%-loop over condition
for i1 = 1:numel(cond)
  for i2 = 1:numel(task)
    
    %-----------------%
    %-outputfile
    dfile = sprintf('%s_%s_%04d_%s_%s%s%s', ...
      info.nick, info.rec, subj, info.mod, task{i2}, cond{i1}, '_A_B_C');
    
    outtmp = sprintf('\n%s\n%s %s\n', mfilename, cond{i1}, task{i2});
    output = [output outtmp];
    %-----------------%
    
    %-----------------%
    %-expected n of trials
    switch i1
      case 1
        ntrial = opt.ntrial.task;
      case {2 3}
        ntrial = opt.ntrial.sleep;
    end
    %-----------------%
    
    %-----------------%
    %-load data
    data = [];
    for d = 1:numel(condcode{i1})
      
      switch opt.dataorig
        
        case 'manualICA'
          [dat filename] = loadmeg(rdir, condcode{i1}{d}, taskcode{i2});
          
          %-----------------%
          %-check MT
          if strcmp(condcode{i1}{d}, 'L') && strcmp(taskcode{i2}, '_a') ... % it's learning MT
              && dat.time{1}(1) == -5 % MT, should be 5
            dat = ft_checkdata(dat, 'hassampleinfo', 'yes');
            dat = ft_selectdata(dat, 'toilim', [5 15]);
            dat = rmfield(dat, 'sampleinfo');
          end
          %-----------------%
          
        case 'gclean'
          opt.subj = subj;
          [dat filename] = loadgclean(ddir, cond{i1}, task{i2}, cfg);
          
      end
      
      output = sprintf('%s    loading: %s', output, filename);
      
      if isempty(ntrial)
        %-----------------%
        %- if empty, leave it alone
        data = dat;
        output = sprintf('%s (taking all% 4d trials)\n', output, numel(dat.trial));
        break
        %-----------------%
        
      else
        
        %-----------------%
        if numel(dat.trial) >= ntrial % too many trials, discard some
          output = sprintf('%s (taking% 4d out of% 4d trials)\n', output, ntrial, numel(dat.trial));
          
          dat.trial = dat.trial(1:ntrial);
          dat.time = dat.time(1:ntrial);
          enough = true;
          
          
        else % needs more trials, but concatenate now
          output = sprintf('%s (taking all% 4d trials)\n', output, numel(dat.trial));
          
          enough = false;
          
        end
        
        ntrial = ntrial - numel(dat.trial); % it'll need less trial next round
        
        if isempty(data) || isempty(data.trial)
          data = dat;
          
        else % concatenate
          
          data.trial = [data.trial dat.trial];
          data.time = [data.time dat.time];
          
        end
        
        if enough
          break
        end
        %-----------------%
        
      end
      
      clear dat
    end
    output = sprintf('%s    has% 5d trials (% 5d missing)\n', output, numel(data.trial), ntrial);
    %---------------------------%
    
    %-----------------%
    %-resize data
    cfg = [];
    cfg.newtrl = opt.newtrl;
    data = resizedata(cfg, data);
    %-----------------%
    
    %-----------------%
    %-reconstruct time
    % data already contains time, but it's always shifted and not
    % meaningful, so reconstruct it
    timetrl = 0:1/data.fsample:opt.newtrl-1/data.fsample;
    data.time = repmat({timetrl}, size(data.trial));
    %-----------------%
    
    %-----------------%
    %-save
    lendat1 = max(cellfun(@(x)size(x,2), data.trial));
    lendat2 = min(cellfun(@(x)size(x,2), data.trial));
    
    output = sprintf('%s    resized at% 3ds, now% 4d trials (length max% 5d, min% 5d)\n\n', ...
      output, opt.newtrl, numel(data.trial), lendat1, lendat2);
    save([ddir dfile], 'data')
    %-----------------%
    
  end
end
%-------------------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s (%04d) ended at %s on %s after %s\n\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%

%-------------------------------------%
function [data output] = loadmeg(rdir, cond, task)

%-----------------%
%-get file
allfile = dir([rdir '*' cond task '.mat']);
if numel(allfile) ~= 1
  output = sprintf('No file for %s, task %s in %s', cond, task, rdir);
  data.trial = [];
  data.time = [];
  return
end
output = allfile(1).name;
load([rdir allfile(1).name])
%-----------------%

%-----------------%
%-load var
filename = whos('*_*');
if numel(filename) ~= 1
  error('not only one variable with underscore')
end
data = eval(filename(1).name);
%-----------------%
%-------------------------------------%

%-------------------------------------%
function [data output] = loadgclean(ddir, cond, task, cfg)

%-----------------%
%-find the data
datname = cond(1:strfind(cond, '-')-1);

dname = sprintf('%s_%s_%04d_%s_*%s%s%s.mat', ...
      info.proj, info.rec, info.subj, info.mod, task, datname, '_A_B_C');
allfiles = dir([ddir dname]);
output = sprintf(' %s', allfiles.name);
%-----------------%

%-----------------%
%-load the data
if numel(allfiles) == 0
  error(sprintf('could not find data in %s matching %s', ddir, dname));
  
else
  
  %-------%
  %-use only first file for
  if strcmp(datname, 'pre') && strcmp(task, 'FN-')
    allfiles = allfiles(1);
  end
  %-------%
  
  %-------%
  %-concatenate
  dataall = [];
  for i = 1:numel(allfiles)
    
    load([ddir allfiles(i).name])
    data = createtrl(cfg, data, event, task);
    
    if i == 1
      grad = data.grad;
    end
    
    dataall{i} = data;
  end
  
  if numel(allfiles) == 1
    data = dataall{1};
  else
    data = ft_appenddata([], dataall{:});
    data.grad = grad;
  end
  clear dataall
  %-------%
  
end
%-----------------%

%-----------------%
%-
if strcmp(datname, 'sleep')
  
  %-------%
  %-remove rem and movement
  [nosleep] = ismember(data.trialinfo, [5 6]);
  data.trialinfo = data.trialinfo(~nosleep);
  data.trial = data.trial(~nosleep);
  data.time = data.time(~nosleep);
  %-------%
  
  %-------%
  %-sort score if necessary
  if opt.sortscore
    [~, iscore] = sort(data.trialinfo);
    data.trial = data.trial(iscore);
    data.trialinfo = data.trialinfo(iscore);
  end
  %-------%
  
  if strcmp(cond(strfind(cond, '-')+1:end), 'N2')
    [oksleep] = ismember(data.trialinfo, [2 3 4]);
    data.trialinfo = data.trialinfo(oksleep);
    data.trial = data.trial(oksleep);
    data.time = data.time(oksleep);
  end
  
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
function [data] = createtrl(cfg, data, event, task)

%-----------------%
%-create events
if strcmp(event(1).type, 'STIM')
  time1_beg = [event.sample]' + cfg.trial.(task(1:2)).begin * data.fsample;
  time1_end = [event.sample]' + cfg.trial.(task(1:2)).end * data.fsample - 1;
  time1_off = zeros(numel(event),1);
else
  time1_beg = [event.sample]';
  time1_end = [event.sample]' + [event.duration]' -1;
  time1_off = zeros(numel(event),1);
end
trl = [time1_beg time1_end time1_off [event.value]'];

%---------%
%-use only trials which are part of the data
goodtrl = false(size(trl,1), 1);
for t = 1:size(trl,1)
  goodtrl(t) = any(trl(t,1) >= data.sampleinfo(:,1) & trl(t,2) <= data.sampleinfo(:,2));
end
%---------%

tmpcfg = [];
tmpcfg.trl = trl(goodtrl,:);
data = ft_redefinetrial(tmpcfg, data);
%-----------------%
%-------------------------------------%
