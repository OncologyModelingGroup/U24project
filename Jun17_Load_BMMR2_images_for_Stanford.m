% Jun17_Load_BMMR2_images_for_Stanford.m
% 
% Loading script to read in DICOM headers and images and UCSF provided masks for MIRACCL U24
% project demo and write them out using dicomwriter_u24_v1 / write_DSO
%
% Julie DiCarlo
% June 17, 2022
% 
% external dependencies: 
% - ReturnDCMSeriesFolders (JCD)
% - matchTwoStringsinCellArray (JCD)
clear; close all; clc;

patid = 'ACRIN-6698-774840';
patid_num = patid(end-5:end);

dir_Study = '/Users/jd45888/data/BMMR2/';
dir_Patient = patid;
dir_DCMfiles = fullfile(dir_Study,dir_Patient);

[series_folders, sub_folders, all_dcm_files, all_fnames, all_folders, inds_unique] = ReturnDCMSeriesFolders(dir_DCMfiles);
N_serfolders = size(series_folders,1);

vis_str = '6698ISPY2MRIT0';

savedir = ['/Users/jd45888/data/BMMR2/Processed_U24_ForStanford/' patid '/'];
if exist(savedir)~=7
    [status, msg, msgID] = mkdir(savedir);
else
    fprintf(sprintf('Make sure directory %s is empty then hit any key to continue...\n',savedir));
    pause
end


%% Load in the DCE, SER, and mask files then write U24 dicoms:

seq_str = 'uni-lateral cropped original DCE'; firstfile = matchTwoStringsinCellArray(all_dcm_files,vis_str,seq_str);
DCE_info = dicominfo(firstfile);
thisfolder = matchTwoStringsinCellArray(series_folders,vis_str,seq_str);
[DCE, DCE_spatial, DCE_dim] = dicomreadVolume(thisfolder);
DCE = double(squeeze(DCE));
DCE_slices = DCE_spatial.PatientPositions(:,3);

% in the below for TCIA data the 3 is a time index:
% data = squeeze(DCE_reg.Data(:,:,3,:));
% ims_one_timesample = squeeze(DCE_reg_ims(:,:,:,approx_peak_index));
% 3rd DCE timepoint (second post) for display purposes
DCE_3 = DCE(:,:,3:7:end);


seq_str = 'uni-lateral cropped SER'; firstfile = matchTwoStringsinCellArray(all_dcm_files,vis_str,seq_str);
SER_info = dicominfo(firstfile);
thisfolder = matchTwoStringsinCellArray(series_folders,vis_str,seq_str);
[SER, SER_spatial, SER_dim] = dicomreadVolume(thisfolder);
SER = double(squeeze(SER));
SER_slices = SER_spatial.PatientPositions(:,3);

seq_str = 'VOLSER uni-lateral cropped Analysis Mask'; firstfile = matchTwoStringsinCellArray(all_dcm_files,vis_str,seq_str);
SER_mask_info = dicominfo(firstfile);
thisfolder = matchTwoStringsinCellArray(series_folders,vis_str,seq_str);
[SER_mask, SER_mask_spatial, SER_mask_dim] = dicomreadVolume(thisfolder);
SER_mask = double(squeeze(SER_mask));
SER_mask_slices = SER_mask_spatial.PatientPositions(:,3);

[~, Locb] = ismember(SER_mask_slices,SER_slices);
SER_mask_samesize = SER.*0;
SER_mask_samesize(:,:,Locb) = SER_mask;

info1 = DCE_info;

specs.PatientID = info1.PatientID;
specs.StudyInstanceUID = info1.StudyInstanceUID;
specs.PatientName = info1.PatientID;
specs.SeriesDescription = 'SER';
specs.StudyDate = info1.StudyDate;
specs.StudyDescription = info1.StudyDescription;
% specs.study_time = info1.PerformedProcedureStepStartTime;
specs.study_time = info1.StudyTime;
specs.orient = info1.ImageOrientationPatient';
specs.position = info1.ImagePositionPatient';
specs.patient_pos = info1.PatientPosition';
%specs.SeriesInstance = info1.SeriesInstanceUID;
specs.SeriesInstance = dicomuid();
specs.birth = info1.PatientBirthDate;
specs.res = [info1.PixelSpacing' info1.SliceThickness];  %UT data spacing same as thickness

seg_name = [specs.PatientName '_DCE_ROI'];

save_loc = [savedir '/SER/'];
if exist(save_loc)~=7
    [status, msg, msgID] = mkdir(save_loc);
end

% dicomwriter_u24_v1(data,specs,seg_mask,savedir,info1,clinical); % new
% flag for clinical data
clinical = 1;
dicomwriter_u24_v1(SER,specs,SER_mask_samesize,save_loc,clinical); 

%% Load in the DWI and ADC images and mask files then write U24 dicoms:

seq_str = '6698 AX DWI 100'; firstfile = matchTwoStringsinCellArray(all_dcm_files,vis_str,seq_str);
DWI100_info = dicominfo(firstfile);
thisfolder = matchTwoStringsinCellArray(series_folders,vis_str,seq_str);
[DWI100, DWI100_spatial, DWI100_dim] = dicomreadVolume(thisfolder);
DWI100 = double(squeeze(DWI100));
DWI100_slices = DWI100_spatial.PatientPositions(:,3);


seq_str = 'DWI MASK'; firstfile = matchTwoStringsinCellArray(all_dcm_files,vis_str,seq_str);
DWI_mask_info = dicominfo(firstfile);
thisfolder = matchTwoStringsinCellArray(series_folders,vis_str,seq_str);
[DWI_mask, DWI_mask_spatial, DWI_mask_dim] = dicomreadVolume(thisfolder);
DWI_mask = double(squeeze(DWI_mask));
DWI_mask_slices = DWI_mask_spatial.PatientPositions(:,3);

seq_str = '6698 ADC'; firstfile = matchTwoStringsinCellArray(all_dcm_files,vis_str,seq_str);
ADC_info = dicominfo(firstfile);
thisfolder = matchTwoStringsinCellArray(series_folders,vis_str,seq_str);
[ADC, ADC_spatial, ADC_dim] = dicomreadVolume(thisfolder);
ADC = double(squeeze(ADC));
ADC_slices = ADC_spatial.PatientPositions(:,3);


[~, Locb] = ismember(DWI_mask_slices,ADC_slices);
ADC_mask_samesize = ADC.*0;
ADC_mask_samesize(:,:,Locb) = DWI_mask;

info1 = DWI100_info;

% JCD: code from loading TCIA data script as sent to Stanford July 26 2021
study_UID = dicomuid();  % Generate DICOM Unique Identifier (matlab function)
specs.PatientID = info1.PatientID;
specs.StudyInstanceUID = info1.StudyInstanceUID;
specs.PatientName = info1.PatientID;
specs.StudyDate = info1.StudyDate;
specs.StudyDescription = info1.StudyDescription;
specs.birth = info1.PatientBirthDate;
specs.res = [info1.PixelSpacing' info1.SliceThickness];  %UT data spacing same as thickness
% specs.SeriesInstance = dicomuid();

specs.SeriesDescription = 'ADC (um^2/ms)';
% specs.study_time = info1.PerformedProcedureStepStartTime;
specs.study_time = info1.StudyTime;
specs.orient = info1.ImageOrientationPatient';
specs.position = info1.ImagePositionPatient';
specs.patient_pos = info1.PatientPosition';
%specs.SeriesInstance = dicomuid;
specs.SeriesInstance = info1.SeriesInstanceUID;

save_loc = [savedir '/ADC/'];
if exist(save_loc)~=7
    [status, msg, msgID] = mkdir(save_loc);
end
clinical_flag = 1;
dicomwriter_u24_v1(ADC,specs,ADC_mask_samesize,save_loc,clinical_flag);

specs.SeriesDescription = 'DWI_0_or_100';
specs.SeriesInstance = dicomuid();
save_loc = [savedir '/DWI_100/'];
if exist(save_loc)~=7
    [status, msg, msgID] = mkdir(save_loc);
end
clinical_flag = 1;
dicomwriter_u24_v1(DWI100,specs,ones(size(DWI100)),save_loc,clinical_flag);

%% T2_FSE?




