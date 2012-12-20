function [cond output] = event2trl_10s(cfg, event)
%EVENT2TRL_10s make trials of 10s, very similar to original analysis

if ~isfield(cfg, 'trialdur');
  cfg.trialdur = 10;
end

if strcmp(event(1).type, 'STIM')
  
  %-------------------------------------%
  %-task
  %-----------------%
  %-create events
  time1_beg = [event.sample]';
  time1_end = [event.sample]' + cfg.trialdur * cfg.fsample - 1;
  time1_off = zeros(numel(event),1);
  %-----------------%
  
  %-----------------%
  cond(1).name = 'trial';
  cond(1).trl = [time1_beg time1_end time1_off];
  %-----------------%
  
  %-----------------%
  %-output
  output = sprintf('N of Stim: % 3d\n', numel(event));
  %-----------------%
  %-------------------------------------%
  
else
  
  %-------------------------------------%
  %-sleep
  %-----------------%
  %-stages
  stage(1).name = 'WA';
  stage(1).marker = [0 1 2]; % this only means that you should recordings from 0, if not enough then 1, if not enough then 2
  stage(2).name = 'N2';
  stage(2).marker = [2 3 4];
  %-----------------%
  
  for k = 1:numel(stage)
    
    %-----------------%
    %-all epochs
    begsess = event(1).sample;
    endsess = event(end).sample + event(end).duration;
    boundary = [begsess:(cfg.trialdur * cfg.fsample):endsess]';
    trlall = [boundary(1:end-1) boundary(2:end)-1];
    %-----------------%
    
    %-----------------%
    e = ismember([event.value], stage(k).marker);
    begepoch = [event(e).sample]';
    endepoch = [event(e).sample]' + [event(e).duration]';
    %-----------------%
    
    %-----------------%
    %-find which trials are in epochs
    itrl = zeros(size(trlall,1),1);
    for i = 1:size(trlall,1)
      oktrl = find(trlall(i,1) >= begepoch & trlall(i,2) <= endepoch); % index of the epoch it belongs to
      if ~isempty(oktrl)
        itrl(i) = oktrl;
      end
    end
    
    goodtrl = find(itrl);
    ntrl = numel(goodtrl);
    
    cond(k).name = stage(k).name;
    cond(k).trl = [trlall(goodtrl, :) zeros(ntrl,1) itrl(goodtrl)];
    %-----------------%
    
    marker = sprintf(' %d', stage(k).marker);
    output = sprintf('Stage %s (%s) with% 4d epochs, resulting in% 5d trials of% 3ds duration\n', ...
      stage(k).name, marker, numel(begepoch), ntrl, cfg.trialdur);
    
  end
  %-------------------------------------%
  
end