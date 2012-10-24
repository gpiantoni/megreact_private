function [trl event] = trialfun_megtask(cfg)
%TRIALFUN_MEGTASK create event and the whole recording for MT and FN task of MEGREACT
%

%-----------------%
%-read info
hdr = ft_read_header(cfg.headerfile);
evt = ft_read_event(cfg.datafile);
%-----------------%

%-----------------%
%-read dataset
if numel(unique({evt.type})) == 1 ...
    || numel(find(strcmp({evt.type}, 'STIM'))) < 2 % subj 10 has one STIM in the first dataset
  
  if cfg.withsleep
    [trl event] = trialfun_megsleep(cfg); % check if it's sleep maybe
    
  else
    trl = [0 0 0];
    event = [];
    
  end
  
  return
end
%-----------------%

%-----------------%
%-create trl
i_stim = strcmp({evt.type}, 'STIM');

stim = [evt(i_stim).sample]; % location of STIM
timeinterval = -hdr.Fs * cfg.timearound:hdr.Fs * cfg.timearound; % time interval around STIM to read

smpl = repmat(timeinterval, numel(stim), 1) + repmat(stim', 1, numel(timeinterval)); % sample to read
smpl = unique(smpl(:));

if smpl(1) <= 0
  smpl(1) = 1;
end

if smpl(end) > hdr.nSamples * hdr.nTrials
  smpl(end) = hdr.nSamples * hdr.nTrials;
end

breaks = find(diff(smpl) > 1);
smpl1 = [smpl(1); smpl(breaks+1)];
smpl2 = [smpl(breaks); smpl(end)];

trl = [smpl1 smpl2 ones(numel(smpl1),1) * hdr.Fs * cfg.timearound];
%-----------------%

%-----------------%
%-clean up event
event = evt(i_stim);
%-----------------%
