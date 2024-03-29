function spaghettiplot(info, opt)
%SPAGHETTIPLOT make spaghetti plot, similar input to megreact_stat
% INFO
%  .anly: for corrmat/grad
%  .log
%  .dcon: connectivity data
% 
% CFG.OPT
%  .time: cell with strings of the conditions to compare {'pre-trial'
%         'sleep-N2'}; Max two conditions.
%  .freq: two scalars for the average of the frequency to compare

%-------------------------------------%
%-layout
load([info.anly 'corrmat/grad_150VUmc.mat'])
cfg = [];
cfg.grad = grad;
layout = ft_prepare_layout(cfg);
layout.label = layout.label(1:150);
layout.pos = layout.pos(1:150,:);
%-------------------------------------%

%-------------------------------------%
task = {'MT-' 'FN-'};

clear corrmat
for t = 1:numel(opt.time)
  for i = 1:numel(task)
    cond = [task{i} opt.time{t}];
    if strcmp(cond, 'FN-pre-baseline')
      cond = 'FN-pre-trial';
    end
    load([info.dcon 'conn_' cond], 'conn')
    ifreq = nearest(cellfun(@(x)x(1), conn.freq), opt.freq(t));
    corrmat(:,:,:,t,i) = squeeze(conn.mat(:,:,1,ifreq,:));
  end
end
%-------------------------------------%

%-------------------------------------%
cfg = [];
cfg.threshold = 0.01;
pair_01_1 = sel_tstat(cfg, corrmat(:,:,:,1,1), corrmat(:,:,:,1,2));
pair_01_2 = sel_tstat(cfg, corrmat(:,:,:,2,1), corrmat(:,:,:,2,2));
pair_01_12 = pair_01_1 + pair_01_2;

cfg.threshold = 0.05;
pair_05_1 = sel_tstat(cfg, corrmat(:,:,:,1,1), corrmat(:,:,:,1,2));
pair_05_2 = sel_tstat(cfg, corrmat(:,:,:,2,1), corrmat(:,:,:,2,2));
pair_05_12 = pair_05_1 + pair_05_2;
%-------------------------------------%

%-------------------------------------%
%-plot task
pair_1 = double(pair_01_1 == 1) + double(pair_05_1 == 1);
h = plot_spaghetti(pair_1, layout, 1, 2);
saveas(h, [info.log filesep 'spaghetti_' opt.time{1} '.png'])
saveas(h, [info.log filesep 'spaghetti_' opt.time{1} '.pdf'])
delete(h)
%-------------------------------------%

%-------------------------------------%
%-plot sleep
pair_2 = double(pair_01_2 == 1) + double(pair_05_2 == 1);
h = plot_spaghetti(pair_2, layout, 1, 2);
saveas(h, [info.log filesep 'spaghetti_' opt.time{2} '.png'])
saveas(h, [info.log filesep 'spaghetti_' opt.time{2} '.pdf'])
delete(h)
%-------------------------------------%

%-------------------------------------%
%-plot task + sleep
pair_12 = double(pair_01_12 == 2) + double(pair_05_12 == 2);
h = plot_spaghetti(pair_12, layout, 1, 2);
saveas(h, [info.log filesep 'spaghetti_' opt.time{1} '_' opt.time{2} '.png'])
saveas(h, [info.log filesep 'spaghetti_' opt.time{1} '_' opt.time{2} '.pdf'])
delete(h)
%-------------------------------------%

%-------------------------------------%
function h = plot_spaghetti(pairplot, layout, plot1, plot2)

h = figure;
ft_plot_lay(layout, 'label', 0, 'box', 0, 'pointsymbol', '.', 'pointcolor', 'k', 'pointsize', 8)
hold on
for k1 = 1:size(pairplot,1)
  for k2 = 1:size(pairplot,2)
    if pairplot(k1,k2) == plot1
      plot( [layout.pos(k1, 1) layout.pos(k2, 1)], [layout.pos(k1, 2) layout.pos(k2, 2)], 'b')
    elseif pairplot(k1,k2) == plot2
      plot( [layout.pos(k1, 1) layout.pos(k2, 1)], [layout.pos(k1, 2) layout.pos(k2, 2)], 'r')
    end
  end
end


%-------------------------------------%