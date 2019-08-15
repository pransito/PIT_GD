% -----------------------------------------------------------------------
% DCM SCRalze for Pavlov Data Juniorgroup02
% last update 05-08-2016
%% ----------------------------------------------------------------------



%%% --------------
clear;   warning off;
%addpath('S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-01\scripts\functs');

%%% --------------
% model CS as FIXED response?
fix=1; % else fix=0
%%% --------------------

    paEDAin='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA';  %folder: RAWDATA
  %  paEDAout='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM';  %folder: OUTPUT
  
   paEDAout ='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM\input_2fixed_responses';
    [fpfiles  files]=p_getsubfolderfiles(paEDAin, '','*s1_EDA_exp.mat') ;
% end
    
    % ==================================================================================================
    % =========================================================================
    
    for i=1:length(fpfiles)
        [pathstr, name, ext, versn] = fileparts(fpfiles{i}) ;
        load(fpfiles{i} )
        name2=fpfiles{i};
        data=double(s.d); % data
        infod.sf    =s.sf;
        infod.onsets='DCM; defined in SECONDS' ;
        infod.day=s.session;
        
        % condfile
      
           m2find=[4 8 40];

        %%CODE CS
        [names onsets ]=deal({});
        for j=1:length(m2find)
            ix=find(s.mrk(:,2)==m2find(j))';
            names{1,j} =[ 'cond-' num2str(m2find(j))];
            events=double(s.mrk(ix,1)');
            if ~isempty(events)
            onsets{1,j}=events;
            end
        end
        
        
      if infod.day==1
        usdelay= s.sf*3  ;
        
        %namesorig=names;
        onsetsorig=onsets;
        names={'cs+' 'cs-' 'us'};
        usonsets={};
        for j=1:2
            usonsets(1,j)= {cell2mat(onsets(:,j))+usdelay};
        end
        onsets=[ onsets(1:2) usonsets];
        
        
        %% prepare for DCM
        
        onsets2=[cell2mat(onsets')]'; 
        eventcs=onsets2(:,1:2);
        codecs=repmat([4,8],[size(eventcs,1) 1]);
        eventus=onsets2(:,3:4);
        codesus=repmat(80, [size(eventus,1)*2 1]); % code omitted US!
        codes2=sortrows([eventus(:) codesus(:)],1);
        
        re=onsetsorig{3};
        for m=1:length(re)
           codes2(codes2(:,1)==re(m),2)=40 ;
        end
        event=[eventcs(:); eventus(:)]; code=[codecs(:); codes2(:,2)];
        temp=[codes2;eventcs(:),codecs(:) ];
        infod.events=sortrows(temp,1);%events for contrasts
       
        conds=s.mrk(:,2); conds(conds==40)=999;
        idx= find(conds==999);
        conds(idx-1)=40; conds(conds==999)=[];
        infod.conds=conds;
      
      
        cs    =onsets2(:,1:2); cs=sort(cs(:));
        
        if fix==0
            cs=[cs cs+3*s.sf];
        end
 
        us=onsets2(:,3:4); us=sort(us(:));
      
 epochs={};
        %% convert so seconds from spoints
        epochs{1,1} =[cs]/s.sf;
        epochs{1,2} =[us]/s.sf;
        events=epochs;
        
      elseif infod.day==2
         epochs{1,1}=[s.mrk(:,1) s.mrk(:,1)+3*s.sf]/s.sf;
      events=epochs;

         names={'cs+' 'cs-' };
      infod.events=s.mrk;%events for contrasts
      infod.conds=s.mrk(:,2);
      
      
      elseif infod.day==4
     onsets=s.mrk;
     onsets(onsets(:,2)==40,1)=-1; % exclude reinstatement trials from model by specifiying neg onset
     
     epochs{1,1}=[onsets(:,1) onsets(:,1)+3*s.sf];
     epochs{1,1}(epochs{1,1}(:,1)==-1,2)=-1;
     events=epochs;
     names={'cs+' 'cs-' };
     infod.events=s.mrk;%events for contrasts
      infod.conds=s.mrk(:,2);
      end
      

       % name=regexprep(name, '_artef', '');
      

        if 1%•SAVE FILES
            mkdir(paEDAout);
            save(fullfile(paEDAout, [name '_DATA'] ), 'data' ,'infod');
            save(fullfile(paEDAout, [name '_EPOCHS'] ), 'events' );
        end
        
        cprintf([0,0,1], ['finished ' name '\n' ]);
    end
    

