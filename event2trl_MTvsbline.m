function [cond output] = event2trl_MTvsbline(cfg, event)
%EVENT2TRL_MTvsbline create trials based on events
%
% CFG
% all the values are in respect to the marker, in second
%   .time1.begin: beginning of the trial period (-10)
%   .time1.end: end of the trial period (10)

%-----------------%
%-create events
time_beg = [event.sample]' + cfg.time.begin * cfg.fsample;
time_end = [event.sample]' + cfg.time.end * cfg.fsample - 1;
time_off = ones(numel(event),1) * cfg.time.begin * cfg.fsample;
%-----------------%

%-----------------%
cond(1).name = 'trial';
cond(1).trl = [time_beg time_end time_off];
%-----------------%

%-----------------%
%-output
output = sprintf('N of Stim: % 3d\n', numel(event));
%-----------------%