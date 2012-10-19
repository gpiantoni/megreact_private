function naming_megDS
%NAMING_MEGDS create RAW folder 
%
% It's not possible to rename the folders, because the name of the folder
% needs to be identical to the name of the files inside! So the fileformat
% does not follow the conventions used in RAW

%-------------------------------------%
%-info
%-----------------%
%-SomerenServer
proj = 'megreact';
rec  = 'msmf';
rawd = 'raw'; % name of the raw directory inside recordings

mod  = 'meg';
cond = 'FN';

base = ['/data1/projects/' proj filesep];
recd = [base 'recordings/' rec filesep];
recs = [recd 'subjects/'];

subjall = 1:11;
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-then move into raw folder
for subj = subjall
  
  %---------------------------%
  %-directory
  odir = sprintf('%s%04.f/%s/%s/%s/', recs, subj, mod, 'orig', cond); % orig dir
  odir_date = dir([odir '20*']);
  odir = [odir odir_date(1).name '/'];
  rdir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, rawd); % raw dir
  %---------------------------%
  
  %---------------------------%
  %-loop over files
  DSfile = dir([odir '*.ds']);
  
  for i = 1:numel(DSfile)
    
    %-----------------%
    %-prepare name
%     rawname = sprintf('%s_%04d_%s_%s_s%d.ds', ...
%       rec, subj, mod, cond, i);
    %-----------------%
    
    %-----------------%
    %-symbolic link
    system(['ln -s ' odir DSfile(i).name ' ' rdir DSfile(i).name]);
    %-----------------%
    
  end
  %---------------------------%
  
end
%-------------------------------------%