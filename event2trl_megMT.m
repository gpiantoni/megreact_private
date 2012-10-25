function [cond output] = event2trl_megMT(cfg, event)
%EVENT2TRL_MEGMT create trials based on events
%
% CFG
% all the values are in respect to the marker, in second
%   .time1.begin: beginning of the baseline period (-10)
%   .time1.end: end of the baseline period (0)
%
%   .time2.begin: beginning of the tracing period (0)
%   .time2.end: end of the tracing period (10)

%-----------------%
%-create events
time1_beg = [event.sample]' + cfg.time1.begin * cfg.fsample;
time1_end = [event.sample]' + cfg.time1.end * cfg.fsample - 1;
time1_off = zeros(numel(event),1);

time2_beg = [event.sample]' + cfg.time2.begin * cfg.fsample;
time2_end = [event.sample]' + cfg.time2.end * cfg.fsample - 1;
time2_off = zeros(numel(event),1);
%-----------------%

%-----------------%
cond(1).name = 'baseline';
cond(1).trl = [time1_beg time1_end time1_off];

cond(2).name = 'execution';
cond(2).trl = [time2_beg time2_end time2_off];
%-----------------%

%-----------------%
%-output
output = sprintf('N of Stim: % 3d\n', numel(event));
%-----------------%