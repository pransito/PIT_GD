% deleting PhysioVP7777 and PhysioVP8888 from physio_data
cd(['E:\Google Drive\Promotion\VPPG\VPPG_Exchange' ...
    '\Experimente\PDT\Daten\pilot'])
des_dat  = {'physio_data_median.mat','physio_data_max.mat', ...
    'physio_data_auc.mat'};
del_subs = {'PhysioVP7777','PhysioVP8888'};

for ii = 1:length(des_dat)
    load(des_dat{ii})
    mff = {};
    for jj = 1:length(del_subs)
        m       = physio_data(:,1);
        mf      = cellfun(@strfind, m,cellstr(repmat(del_subs{jj},length(m),1)), ...
            'UniformOutput',false);
        mff{jj} = not(cellfun(@isempty,mf));
    end
    mffl = [];
    mffl = mff{1};
    for jj = 2:length(mff) 
        mffl = mffl + mff{jj};
    end
    mffl = not(mffl);
    physio_data = physio_data(mffl,:);
    save(des_dat{ii},'physio_data');
end




physio_data = physio_data(mff,:);