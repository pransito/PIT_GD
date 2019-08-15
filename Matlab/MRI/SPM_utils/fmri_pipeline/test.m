function test
%%
% load('F:\fMRI\DataMaria\results_2nd_level\twottest\groupstats_1lvl_iwelcheResults_grp12__AgeSexEdu_con_0002\matlabbatch.mat');
% jpa_addCovariates(matlabbatch,[1 2 3 4],'test',1,1)
%jpa_eval_results('E:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\ttest\groupstats_results_abs_loss_3_noacc_grp1_noCov_con_0002\', 'C:\rogram Files\spm12\tpm\labels_Neuromorphometrics.xml', 0.99 ,10)
% load('covariates4EachGoup.mat')
% x = [17 19 12];
% jpa_reassembleCell(covariates4EachGoup,x);
% [x y] = jpa_resizeColumsOfMat([1 2 3 4], 1);
% x
% y
%x = jpa_loadTxtToArray('F:\PIT_imaging_FP1\P2\VDdata\exclude_no_1stLevel.txt')
% stringArr = {'line1' 'line2', 'line3' ; 'line4', 'line5', 'line6'}
% jpa_writeArrayToTxt('G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\test1.txt', stringArr, 'v')
% jpa_writeArrayToTxt('G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\test2.txt', stringArr, 'h')
load('F:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\ttest\ttest_all_sig_resultsWB');
jpa_dispResults(ttest_all_sig_resultsWB, 'F:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\ttest\test.txt')
%par.a.b.egh = 11;
%par.a.c = 2;
%par.b.gg = 3;
%x = jpa_getSubstruct(par,'gg');
%x = jpa_getDirs('G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\', 'results_abs_loss_2_noacc\con_0001.nii')
% load('G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\ttest\ttest_all_sig_resultsROI')
% jpa_dispResults(ttest_all_sig_resultsROI, 'G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\ttest\outfile.txt');
% jpa_addTContrast('F:\fMRI\DataMaria\2003\job_pit_5_2_1_2003.mat', 'test', [0 0 1] , 'none');
% 
%  x = jpa_depthSearch('G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\','results_abs_loss_2_acc\con_0002.nii');
% %  x
% %a = jpa_build2Permutation([1 2 3 4 5 6])
% base_dir_pl = 'G:\fMRI\Preprocessed_on_Windows_Machine_swuaf_VBM8\';
% res.type = 'ttest'
% jpa_eval_results(res, base_dir_pl)
% 
% str = {'hallo', 'du' ;'schoene', 'Welt'};
% x = jpa_getInitialienOfSting(str)
% x
% matlabbatch = jpa_initialFmriEst(matlabbatch);
% factorial_design.dir = {'E:\fMRI\LibaryP'};
% x = jpa_initialFactorialDesign(struct.empty,factorial_design);
% save([pwd,'\','matlabbatch.mat'],'matlabbatch');
%twottest;
%load('all_sig_res.mat')
%cur_coord = all_sig_results(2).peak_coord{2}'
%cur_coord = [55 40 -35]
%cur_coord(1,3)
%cur_name  = cellstr('test')
%contrast.type = 'test';
% jpa_addContrast('G:\fMRI\try\SPM.mat',contrast)
% plot_pic.path = 'G:\fMRI\LibaryP\';
% % set MaxCollum per Page
% plot_pic.settings.maxCols = 4;
% % set MaxRows per Page
% plot_pic.settings.maxRows = 1;
% % specify exactly the number of Pictures per Page
% plot_pic.settings.exakt = [5 7];

% colorbar coords (left, top , right, botton)
% use 0.93,0.1,0.95,0.9 for a small color bar on the right
% use 0.1,0.9,0.12,0.1 for the same color bar on the left
% use 0.1,0.92,0.9,0.9 for the same color bar on the top
% use 0.9,0.12,0.1,0.1 for the same color bar on the botton

%jpa_removeColorBar('G:\fMRI\LibaryP\pic1.png', '0,0,0', '0.93,0.1,0.95,0.9')
% disp('aha')
% a = imread('G:\fMRI\LibaryP\pic1.png');
% b = image(a);
% set(b,'CDataMapping','scaled');
% set(gca,'clim',[1 5]);
% mapr = []
% map1 = linspace(3/255,255/255,95)
% map2 = linspace(0,0,95)
% map3 = linspace(0,0,95)
% for i=1:1:95
%     line = [map1(i),map2(i),map3(i)];
%     mapr = [mapr ; line];
% end
% map1 = linspace(1,255/255,(191-95))
% map2 = linspace(0,1,(191-95))
% map3 = linspace(0,0,(191-95))
% for i=1:1:(191-95)
%     line = [map1(i),map2(i),map3(i)];
%     mapr = [mapr ; line];
% end
% map1 = linspace(1,1,(255-191))
% map2 = linspace(1,1,(255-191))
% map3 = linspace(0,1,(255-191))
% for i=1:1:(255-191)
%     line = [map1(i),map2(i),map3(i)];
%     mapr = [mapr ; line];
% end
%
% colormap(mapr)  truesize(1,[h w])
% %  colorbar
% plot.img = 'pic1.png';
% plot.path = '';
%  plot.titel.text = '';
%  plot.titel.position = [];
%  plot.bgcolor =  [];
%  plot.titel.FontSize ='' ;
%  if ~isfield(plot.titel,'dfgh') 
%      display('aha')
%  end
%jpa_addColorBar(plot);
%jpa_addTitel(plot);




% S = subplot(plot_pic.settings.maxRows,plot_pic.settings.maxCols,1);
% A = imread('G:\fMRI\LibaryP\pic1.png');
% image(A)
% p = get(S, 'pos');
%             p(1) = 0;
%             p(2) = 0;
%             p(3) = (1/plot_pic.settings.maxCols);
%             p(4) = (1/plot_pic.settings.maxRows);
%             % set new position
%             set(S, 'pos', p);
% S = subplot(plot_pic.settings.maxRows,plot_pic.settings.maxCols,2);
% A = imread('G:\fMRI\LibaryP\pic2.png');
% image(A)
%             p(1) = 0.1667;
%             p(2) = 0;
%             p(3) = (1/plot_pic.settings.maxCols);
%             p(4) = (1/plot_pic.settings.maxRows);
%             % set new position
%             set(S, 'pos', p);
% S = subplot(plot_pic.settings.maxRows,plot_pic.settings.maxCols,3);
% A = imread('G:\fMRI\LibaryP\pic3.png');
% image(A)
%             p(1) = 0.3333;
%             p(2) = 0;
%             p(3) = (1/plot_pic.settings.maxCols);
%             p(4) = (1/plot_pic.settings.maxRows);
%             % set new position
%             set(S, 'pos', p);
% S = subplot(plot_pic.settings.maxRows,plot_pic.settings.maxCols,4);
% A = imread('G:\fMRI\LibaryP\pic4.png');
% image(A)
%             p(1) =  0.5000;
%             p(2) = 0;
%             p(3) = (1/plot_pic.settings.maxCols);
%             p(4) = (1/plot_pic.settings.maxRows);
%             % set new position
%             set(S, 'pos', p);
% S = subplot(plot_pic.settings.maxRows,plot_pic.settings.maxCols,5);
% A = imread('G:\fMRI\LibaryP\pic5.png');
% image(A)
%             p(1) =  0.6667;
%             p(2) = 0;
%             p(3) = (1/plot_pic.settings.maxCols);
%             p(4) = (1/plot_pic.settings.maxRows);
%             % set new position
%             set(S, 'pos', p);
% S = subplot(plot_pic.settings.maxRows,plot_pic.settings.maxCols,6);
% A = imread('G:\fMRI\LibaryP\pic6.png');
% image(A)
%             p(1) = 0.8333;
%             p(2) = 0;
%             p(3) = (1/plot_pic.settings.maxCols);
%             p(4) = (1/plot_pic.settings.maxRows);
%             % set new position
%             set(S, 'pos', p);

%jpa_plotMriCro(plot_pic)
%
%  y = spm_vol('T:\Dokumente\Downloads\test_mask.nii')
%  whos('y')
%  [x,yxs]  = spm_read_vols(y);
%  whos('x')
%  whos('yxs')
%  [M,I] = max(x(:))
%  num2str(M)
%  num2str(I)
%  A = x.mat

%create_sphere_image(cur_SPM,cur_coord,cur_name,repmat(8,3,1));
% starting position, do not change
% calculate z-axis-rotation:


% %
% cur_coord =
%
%    48    49     5 (vx)
%   13.0 51.0 23.0  (mm)

%    53 63 53       (vx)
%   -92.0 91.0 110.0 (mm)

%    0   0   0      (vx)
%    93.5 -129.5 -75.5 (mm)




%       V.mat   - a 4x4 affine transformation matrix mapping from
%                 voxel coordinates to real world coordinates.
%rot_zooms_shears = A(1:3,1:3)
%translations = A(1:3,4);
%transformed_P = rot_zooms_shears * transpose(cur_coord)
%transformed_P + repmat(translations, 1, 1)



%bb = [93.5 91.0 110.0;-92.0 -129.5 -75.5]
%vx = [-1 1 1] .* abs(cur_coord);
%mn = vx .* min(bb ./ repmat(vx, 2, 1))
%mx = vx .* round(max(bb ./ repmat(vx, 2, 1)))
%mat = spm_matrix([mn 0 0 0 vx]) * spm_matrix([-1 -1 -1])

%dim = mat \ [mx 1]'
%dim = round(dim(1:3)')

end