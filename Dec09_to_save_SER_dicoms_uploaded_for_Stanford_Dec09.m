% This is from
% Dec02_Nov12_used_to_save_SER_dicoms_uploaded_for_Stanford_Nov12.m,
%
% with feedback from Emel Alkim at Stanford on errors in loading the images to
% pyradiomics and changes to write_DSO in her email on 03-DEC-2020
%
% Trying to save SER Map as image DSO (DICOM segmentation object)
%
%
% took DH's script to call dicomwriter_u24_v1 with preclinical data:
% modifying to work with TCGA data for testing
%
% Julie DiCarlo
% updated 09-DEC-2020, used for images uploaded on 09-DEC-2020


clear; clc; close all;

visitname = 'v2_06192006';

% % DYN_eTHRIVEHRSENSE struct, and dicominfo struct info1:
% load('/Users/jd45888/data/TCIA/TCGA/TCGA-BRCA/TCGA-BRCA/TCGA-OL-A66N/Processed/case_06192006_scandata.mat'); 
% % registered image data struct DCE_reg:
% load('/Users/jd45888/data/TCIA/TCGA/TCGA-BRCA/TCGA-BRCA/TCGA-OL-A66N/Processed/case_06192006_DCE_RigReg.mat'); 
% % FCM selected struct TumorROI and drawn margin struct TumorMargin:
% load('/Users/jd45888/data/TCIA/TCGA/TCGA-BRCA/TCGA-BRCA/TCGA-OL-A66N/Processed/case_06192006_TumorROI_FCM_hs.mat');
% % SER: 
% load('/Users/jd45888/data/TCIA/TCGA/TCGA-BRCA/TCGA-BRCA/TCGA-OL-A66N/Processed/case_06192006_SER.mat');
% 
% save('/Users/jd45888/data/TCIA/TCGA/TCGA-BRCA/TCGA-BRCA/TCGA-OL-A66N/Processed/case_06192006_DCEMRI_SER_Structures',...
%     'DYN_eTHRIVEHRSENSE','info1','DCE_reg','TumorMargin_fullsize','TumorROI_fullsize','SER_struct','caseNum', '-v7.3');

% One file with DYN_eTHRIVEHRSENSE (original DCE-MRI) struct, and dicominfo
% struct info1, registered image data struct DCE_reg, FCM selected struct 
% TumorROI and drawn margin struct TumorMargin, and computed SER struct:
% load from current dir
load('case_06192006_DCEMRI_SER_Structures');

% Edit this for location of output DICOM files:
% folder needs to be created before
savedir = 'case_06192006_SER_DSO_emel/';


%%
%load('/Local/Users/dah3929/Documents/Datasets/U24 UTBS/Imaging/u24utbs_Black.mat')
% JCD: downloaded above file here to understand components:
% load('/Users/jd45888/data/Baylor_McNair_U24_development/u24utbs_Black.mat');
% data = scan_04_19_2017;
% pid = 'U24UTBS_black';

%%
% (1) Headr information common accross scans
%res = data.dce.method.PVM_SpatResol;  %JCD: why across all scans?  A: for preclinical,
                                      % resolution is often the same for
                                      % all sequences.
%study_UID = dicomuid;
%specs.PatientID = pid;
%specs.StudyInstanceUID = study_UID;
%specs.PatientName = pid;
%specs.res = res;
%specs.StudyDate = datestr(data.date,'YYYYmmdd');
%specs.StudyDescription = 'U24UTBS_preclinical_pdx';
%specs.birth = datestr(data.date-90,'YYYYmmdd');

% JCD: repeating above for TCGA data, using header in info1 from
% case_06192006_scandata.mat file:
study_UID = dicomuid();  % Generate DICOM Unique Identifier (matlab function)
specs.PatientID = info1.PatientID;
specs.StudyInstanceUID = info1.StudyInstanceUID;
specs.PatientName = info1.PatientID;
specs.StudyDate = info1.StudyDate;
specs.StudyDescription = info1.StudyDescription;
%specs.birth = info1.PatientBirthDate;


% SER map:

specs.SeriesDescription = 'SER';
specs.study_time = info1.PerformedProcedureStepStartTime;
specs.orient = info1.ImageOrientationPatient';
specs.position = info1.ImagePositionPatient';
specs.patient_pos = info1.PatientPosition';
%specs.SeriesInstance = dicomuid;
specs.SeriesInstance = info1.SeriesInstanceUID;
% ktrans = data.results.DCE.ktrans;
% save_loc = [pwd '/pDCM/' pid '/v' datestr(data.date,'YYYYmmdd') '/ktrans/'];
% mkdir(save_loc)
% dicomwriter_u24_v1(ktrans,specs,data.tumor,save_loc)
seg_name = [specs.PatientName '_ROI'];
% newPixelData = zeros(size(TumorROI_fullsize,1), size(TumorROI_fullsize,2), size(TumorROI_fullsize,3));
% for i = 1:size(TumorROI_fullsize,3)
%     voiSlice = squeeze(TumorROI_fullsize(:,:,i));
%     newVoiSlice = voiSlice - imerode(voiSlice, strel('disk',1));
%     newPixelData(:,:,i) = newVoiSlice;
% end
seg_mask = logical(TumorROI_fullsize); %.*SER_struct.SER_fullsize;
%addpath('/Users/jd45888/Documents/Lab_Notebook/September 2020/');
specs.birth = '19990101';  % just set a date (needed by save function)
specs.res = [info1.PixelSpacing' DCE_reg.slicespacing];
specs.SeriesInstance = dicomuid();

data = squeeze(DCE_reg.Data(:,:,3,:));

seriesDir = savedir;

dicomwriter_u24_v1(data,specs,seg_mask,savedir,info1,true);


%%  Now test loading and isdicom and load/display to compare:
clc;

% copied from the saved directory, take middle slice:
test_fn1 = 'TCGA-OL-A66N_SER__100.dcm';

isdicom(fullfile(savedir,test_fn1))

ser_im = squeeze(dicomread(fullfile(savedir,test_fn1)));
size(ser_im)

figure;
sl = 100;
map_disp_range = [0 3];
figure(1); set(gcf,'Position',[263         273        1200         450]);
sub1 = subplot(131); imagesc(ser_im); colormap(sub1,gray); axis('square'); title('read DICOM image slice 100');
sub2 = subplot(132); imagesc(data(:,:,sl)); colormap(sub2,gray); axis('square'); title('written DICOM image: DCE Frame 3'); 
sub3 = subplot(133); imagesc(seg_mask(:,:,sl)); axis('square');title('SER mask as DSO slice 100') 
colorbar; caxis(map_disp_range); colormap(sub3,jet); shg;  
