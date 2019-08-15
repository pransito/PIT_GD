all_files    = cellstr(ls());
all_TRs      = [];

for ii = 4:300
    disp(num2str(ii))
    previous_dcm  = spm_dicom_headers(all_files{ii-1});
    previous_time = previous_dcm{1}.AcquisitionTime;
    cur_dcm       = spm_dicom_headers(all_files{ii});
    cur_time      = cur_dcm{1}.AcquisitionTime;
    all_TRs(ii-3) = cur_time - previous_time;
end