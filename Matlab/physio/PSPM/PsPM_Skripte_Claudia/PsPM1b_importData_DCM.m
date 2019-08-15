%% PsPM import files for DCM
%---------------------------------------

clear;   warning off;


    paEDAin='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM\input_2fixed_responses';  %folder: RAWDATA

    [fpfiles  files]=p_getsubfolderfiles(paEDAin, '','*_DATA.mat') ;
    
    global settings
    
    for i=1:length(fpfiles)
        if isempty(settings), scr_init; end;
        D{1} =fpfiles{i};
        datatype = 'mat';
        import{1}.channel = 1;
        import{1}.type = 'scr';
        import{1}.sr = 250;
        import{1}.transfer = 'none';
        options.overwrite = 1;
        scr_import(D, datatype, import, options);
        
    end%pbn