files  = dir([[wdir filesep], '*_era.mat']); 
eraset = dataset;
for iFile = 1:length(files)
    % Get file name (without _era extension)
    filename_list{iFile} = files(iFile).name(1:end-8); 
    % Load single file
    load(fullfile(wdir,files(iFile).name));   
    
    results.CDAt.subject = repmat({['PhysioVP' filename_list{iFile}(end-3:end)]},length(results.CDA.SCR),1);
    results.CDAt.trial   = transpose(results.Event.nid);
    results.CDAt.onset   = results.Event.name(:);
    CDAvars              = fieldnames(results.CDA);
    for i = 1:numel(CDAvars)
      results.CDAt.(CDAvars{i}) = transpose(results.CDA.(CDAvars{i}));
    end
    
    eraset = [eraset; dataset(results.CDAt)];
end

% saving the ledalab result
export(eraset,'File',fullfile(base_dir,'ledalab_out.csv'),'Delimiter',',')
      