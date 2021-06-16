% May03_SH_003_DSO_for_U24_Stanford.m
%
% Script to process data for U24 testing with Emel 
% 
% Julie DiCarlo
% May 3, 2021

clear; clc; close all;

% Load scan and parameter map data:

visit = 1;
patientID = 'SH_003';

% Edit this for location of output DICOM files:
savedir = 'Testing_UTA_Data/';

%save(fullfile(savedir,'SH_003_v1_DSO_matlabdata_try1.mat'),'DCE_struct','SER_struct','Tumor_ROI_struct','patientID','visit');
load('SH_003_v1_DSO_matlabdata_try1.mat');


%% for UT data dicom tags:

info1 = DCE_struct.dcm_header{1,1};
DCE_reg_ims = double(DCE_struct.DCEdyn);
approx_peak_index = 14;

study_UID = dicomuid();  % Generate DICOM Unique Identifier (matlab function)
specs.PatientID = patientID;
specs.StudyInstanceUID = info1.StudyInstanceUID;
specs.PatientName = patientID;
specs.StudyDate = info1.StudyDate;
specs.StudyDescription = info1.StudyDescription;
%specs.birth = info1.PatientBirthDate;
%%
%
% SER map:

specs.SeriesDescription = 'SER';
specs.study_time = info1.PerformedProcedureStepStartTime;
specs.orient = info1.ImageOrientationPatient';
specs.position = info1.ImagePositionPatient';
specs.patient_pos = info1.PatientPosition; %May 12, 2021 Emel, no transpose it is text
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
seg_mask = logical(Tumor_ROI_struct.fcm_ROI); %.*SER_struct.SER_fullsize;
specs.birth = '19990101';  % just set a date (needed by save function)
specs.res = [info1.PixelSpacing' info1.SliceThickness];  %UT data spacing same as thickness
specs.SeriesInstance = dicomuid();

% in the below for TCIA data the 3 is a time index:
% data = squeeze(DCE_reg.Data(:,:,3,:));
ims_one_timesample = squeeze(DCE_reg_ims(:,:,:,approx_peak_index));

seriesDir = savedir;

% dicomwriter_u24_v1(data,specs,seg_mask,savedir,info1);
% May 12, 2021 Emel added new parameter (true) at the end for clinical
dicomwriter_u24_v1(ims_one_timesample,specs,seg_mask,savedir,info1,true);

