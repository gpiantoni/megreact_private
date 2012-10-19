function [trl event] = trialfun_megsleep(cfg)
%TRIALFUN_MEGREACT create event and the whole recording for MT task of MEGREACT

%-------------------------------------%
%-read scoring
scoredir = '/data1/projects/megreact/recordings/msmf/doc/MEGscores/';
%-----------------%
%-get dataset code
code = cfg.dataset(end-8:end-6);
%-----------------%

%-----------------%
%-directory with score
subjdir = dir([scoredir '20060' code '*']);
if isempty(subjdir)
  error(['no score folder for code: ' code ]);
end
subjdir = [subjdir(1).name filesep];
%-----------------%

%-----------------%
%-scores
scoretxt = dir([scoredir subjdir '*.txt']);
if isempty(scoretxt)
  error(['no score in dir: ' scoredir subjdir ]);
end
%-----------------%

%-----------------%
%-read score from txt
for i = 1:numel(scoretxt)
  score{i} = read_score([scoredir subjdir scoretxt(i).name]);
  scorelim(i,:) = [score{i}(1,1) score{i}(end,1)]; % beginning and ending of scoring
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-read datafile
hdr = ft_read_header(cfg.headerfile);
datalim(1) = datenum([hdr.orig.res4.data_date(1:10) hdr.orig.res4.data_time(1:8)], 'dd/mm/yyyyHH:MM:SS');
datadur = hdr.nSamples * hdr.nTrials / hdr.Fs; % duration in seconds
datalim(2) = datalim(1) + datadur /24 /60 /60;
%-------------------------------------%

%-------------------------------------%
%-check if score is inside data window
iscore = find(datalim(1) <= scorelim(:,1) & ... % data begins before scoring
    scorelim(:,2) <= datalim(2)); % scoring ends before data
  
if iscore

  %-----------------%
  %-events
  event = [];
  for i = 1:size(score{iscore},1)
    offset = round((score{iscore}(i,1) - datalim(1)) * 24 * 60 * 60);  
    
    event(i).sample = offset * hdr.Fs + 1;
    event(i).duration = 30 * hdr.Fs;
    event(i).offset = 0;
    
    switch score{iscore}(i,2)
      case 0
        event(i).type = 'Wa';
      case 1
        event(i).type = 'S1';
      case 2
        event(i).type = 'S2';
      case 3
        event(i).type = 'S3';
      case 4
        event(i).type = 'S4';
      case 5
        event(i).type = 'RE';
      case 6
        event(i).type = 'MT';
    end
    event(i).value = score{iscore}(i,2);
    
  end
  %-----------------%
  
  %-----------------%
  %-trl
  trl = [event(1).sample event(end).sample+event(end).duration event(1).sample];
  %-----------------%
  
else
  trl = [0 0 0];
  event = [];
  
end
%-------------------------------------%
