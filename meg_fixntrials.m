function meg_fixntrials(cfg, subj)

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-dir and files
ddir = sprintf('%s%04d/%s/%s/', cfg.data, subj, cfg.mod, cfg.nick); % data dir
allfile = dir([ddir '*' cfg.endname '.mat']); % files matching a preprocessing
%---------------------------%

%-------------------------------------%
%-loop over files
for i = 1:numel(allfile)
  
  %-----------------%
  %-
  load([ddir allfile(i).name]) % to get the events
  output = sprintf('%s\n%s\n', output, allfile(i).name);
  
  if isempty(event)
    continue
  end
  %-----------------%
  
  %-----------------%
  %-preprocessing on the full file
  if isfield(cfg, 'preproc1') && ~isempty(cfg.preproc1)
    cfg1 = cfg.preproc1;
    cfg1.feedback = 'none';
    data = ft_preprocessing(cfg1, data);
  end
  %-----------------%
  
  %-----------------%
  %-define the new trl
  cfg.redef.fsample = data.fsample; % pass the sampling frequency as well
  [cond outtmp] = feval(cfg.redef.event2trl, cfg.redef, event);
  output = [output outtmp];
  %-----------------%
  
  %---------------------------%
  %-loop over condition
  dataorig = data;
  for c = 1:numel(cond)
    if ~isempty(cond(c).trl)
      
      %-----------------%
      %-redefine trials
      %---------%
      %-insert condition name into the condition field
      basicname = allfile(i).name(1:strfind(allfile(i).name, cfg.endname)-1); % name without cfg.endname
      outputfile = [basicname '-' cond(c).name cfg.endname '_' mfilename];
      %---------%
      
      %---------%
      %-use only trials which are part of the data
      goodtrl = false(size(cond(c).trl,1), 1);
      for t = 1:size(cond(c).trl,1)
        goodtrl(t) = any(cond(c).trl(t,1) >= dataorig.sampleinfo(:,1) & cond(c).trl(t,2) <= dataorig.sampleinfo(:,2));
      end
      trl = cond(c).trl(goodtrl,:);
      %---------%
      
      %---------%
      %-output
      if numel(find(goodtrl)) == 0
        outtmp = sprintf('   cond ''%s'', no trials left SKIP (total trials:% 4d, discarded: % 4d)\n', ...
          cond(c).name, size(cond(c).trl,1), numel(find(~goodtrl)));
        output = [output outtmp];
        continue
      else
        outtmp = sprintf('   cond ''%s'', final trials:% 4d (total trials:% 4d, discarded: % 4d))\n', ...
          cond(c).name, numel(find(goodtrl)), size(cond(c).trl,1), numel(find(~goodtrl)));
        output = [output outtmp];
      end
      %---------%
      
      cfg2 = [];
      cfg2.trl = trl; % <- after ft_rejectartifact
      data = ft_redefinetrial(cfg2, dataorig);
      
      if isfield(cond(c), 'trialinfo') && ~isempty(cond(c).trialinfo)
        data.trialinfo = cond(c).trialinfo(goodtrl,:);
      end
      
      save([ddir outputfile], 'data')
      %-----------------%
      
      %-----------------%
      %-preprocessing on the full file
      if isfield(cfg, 'preproc2') && ~isempty(cfg.preproc2)
        cfg1 = cfg.preproc2;
        cfg1.feedback = 'none';
        cfg1.inputfile = [ddir outputfile]; % it rewrites the same file
        cfg1.outputfile = [ddir outputfile];
        ft_preprocessing(cfg1);
      end
      %-----------------%
      
      %-----------------%
      %-scalp current density
      if isfield(cfg, 'csd') && isfield(cfg.csd, 'method') && ~isempty(cfg.csd.method)
        cfg1 = [];
        cfg1.method = cfg.csd.method;
        cfg1.elec = sens;
        cfg1.feedback = 'none';
        cfg1.inputfile = [ddir outputfile]; % it rewrites the same file
        cfg1.outputfile = [ddir outputfile];
        ft_scalpcurrentdensity(cfg1);
      end
      %-----------------%
      
    end
    
  end
  %---------------------------%
  
  %-----------------%
  %-clear
  previousstep = cfg.step{find(strcmp(cfg.step, mfilename))-1};
  if any(strcmp(cfg.clear, previousstep))
    delete([ddir allfile(i).name])
  end
  %-----------------%
  
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
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%