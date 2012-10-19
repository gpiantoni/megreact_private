function data = resizedata(cfg, data)
%resizedata(Savant) create smaller subtrials
% use as:
%   [data] = resizedata(cfg, data)
% in which cfg has the fields
%   .trldur: the duration of the trials now (optional)
%   .newtrl: the duration of the new trials (in seconds)
% You can also use the function as:
%   [data] = resizedata([], data)
% and then you'll be prompted to indicate the duration of the new trials.
% It does not work if the length of the new trials is not a divisor of the
% length of the old trials.

% 09/12/09 fixed small bug
% 09/12/02 corrected if the trials include both the first and the last sample
% 09/11/30 created, from previous code

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin ~= 2
  help('resizedata')
end

cfg.datalen  = size(data.trial{1},2);
if mod(cfg.datalen,data.fsample) ~= 0 % if the trials include both the first AND the last sample
  cfg.datalen = (size(data.trial{1},2)-1);
end

if ~isfield(cfg, 'trldur')
  cfg.trldur = cfg.datalen / data.fsample;
end

if ~isfield(cfg, 'newtrl')
  cfg.newtrl = input(['duration of the new trials in s (now it''s ' num2str(cfg.trldur) ' s): ']);
end

if cfg.trldur >= cfg.newtrl
  disp('original trials will be cut in pieces')

  if mod(cfg.trldur, cfg.newtrl) ~= 0
    error('untested if the new length is not a divisor of original length')
  end
  data     = cuttrials(cfg, data);

else
  disp('original trials will be concatenated')
  
  if mod(cfg.newtrl, cfg.trldur) ~= 0
    error('untested if the new length is not a multiplier of original length')
  end
  data     = concatenatetrials(cfg, data);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUTTRIALS: change trial duration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = cuttrials(cfg, data)

subtrial = cfg.trldur / cfg.newtrl; % create x substrials
dursub   = cfg.newtrl * data.fsample;

nchan    = size(data.trial{1},1);

newtrl   = [];
newtime  = [];

for k_t = 1:numel(data.trial)
  newtrl = [newtrl  mat2cell(data.trial{k_t}(1:nchan, 1:cfg.datalen), nchan, dursub*ones(1,subtrial) )];
  newtime= [newtime mat2cell(data.time{ k_t}(      1, 1:cfg.datalen),     1, dursub*ones(1,subtrial) )];
end

data.trial = newtrl;
data.time  = newtime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUTTRIALS: change trial duration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = concatenatetrials(cfg, data)

contrial = cfg.newdur / cfg.trldur; % concatenate x trials

newtrl   = [];
newtime  = [];

seltrl2  = 0;

for k_t = 1:numel(contrial)
  seltrl1  = seltrl2 + 1;
  seltrl2  = seltrl1 + contrial;
  
  newtrl{k_t}  = [data.trial{seltrl1:seltrl2}];
  newtime{k_t} = [data.time{ seltrl1:seltrl2}];
end

data.trial = newtrl;
data.time  = newtime;
