function megname(info, opt, subj)
%MEGNAME rename the filenames after seldata because the filename of
% the recordings is not correct.
%
% CFG
%   .megscaling: scaling to move femto testa into a nicer number
%   .keeppost: keep post-sleep task
%   .keepsleep: keep sleep data

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-dir and files
ddir = sprintf('%s%04d/%s/%s/', info.data, subj, info.mod, info.nick); % data dir
post = '_A.mat';
%---------------------------%

if ~isfield(opt, 'keeppost'); opt.keeppost = true; end
if ~isfield(opt, 'keepsleep'); opt.keepsleep = true; end

%-------------------------------------%
%-rename each file: MT and FN
tasks = {'FN' 'MT'};

for j = 1:numel(tasks)
  
  %-----------------%
  %-load all files
  allfile = dir([ddir 'megreact_' tasks{j} '*_A.mat']); % files matching a preprocessing
  dataset = [];
  index_pre = [];
  
  for i = 1:numel(allfile)
    
    %-----------------%
    %-load and rescale
    load([ddir allfile(i).name])
    delete([ddir allfile(i).name])
    
    for t = 1:numel(data.trial)
      data.trial{t} = data.trial{t} * opt.megscaling;
    end
    %-----------------%
    
    %-----------------%
    %-assign condition
    dataset(i) = str2double(data.cfg.dataset(end-3));
    
    if isempty(event(1).duration)
      
      if isempty(index_pre) || ...
          index_pre == dataset(i) - 1% if consecutive
        cond = 'pre';
        index_pre = dataset(i);
        
      else
        cond = 'post';
        
        if ~opt.keeppost
          continue
        end
      end
      
    else
      cond = 'sleep';
        if ~opt.keepsleep
          continue
        end
     
    end
    %-----------------%
    
    %-----------------%
    %-rescale and save
    dfile = sprintf('%s_%s_%04d_%s_%d%s-%s%s', info.nick, info.rec, subj, info.mod, dataset(i), tasks{j}, cond, post);
    save([ddir dfile], 'data', 'event')
    %-----------------%
    
  end
  
  clear datall eventall
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