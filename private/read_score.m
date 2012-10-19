function score = read_score(scorefile)
%READ_SCORE read score from somnologica

%-----------------%
%-init
fid = fopen(scorefile, 'r');
score = [];
toread = false;
%-----------------%

while 1
  
  line = fgetl(fid);
  if line == -1; break; end
  
  if toread
    
    %-----------------%
    %-contains scores (after "Time")
    time = datenum(line(1:8), 'HH:MM:SS');
    
    %-remove default date and add actual date
    time = time - floor(time) + day;
    %-----------------%
    
    %-----------------%
    %-score
    switch line(10:11)
      case {'Wa' 'Un'}
        epochscore = 0;
        
      case 'S1'
        epochscore = 1;
        
      case 'S2'
        epochscore = 2;
        
      case 'S3'
        epochscore = 3;
        
      case 'S4'
        epochscore = 4;

      case 'RE'
        epochscore = 5;
        
      case 'MT'
        epochscore = 6;

    end
    %-----------------%
    
    score(end+1,1:2) = [time epochscore];
    
  else
    
    %-----------------%
    %-get date info
    if numel(line) > 14 && ...
        strcmp(line(1:14), 'Recording Date')
      day = datenum(line(17:26), 'dd/mm/yyyy');
      
    elseif numel(line) > 4 && ...
        strcmp(line(1:4), 'Time')
      toread = true; % scoring starts after Time
      
    end
    %-----------------%
    
  end
  
end

fclose(fid);