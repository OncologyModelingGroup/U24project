%% pre-clinical
clear all; close all; clc;
load('test_pre_clinical_data');
clinical = 0; % set to 0 for pre-clinical, 1 for clinical

% (1) Headr information common accross scans
res = data.dce.method.PVM_SpatResol;
study_UID = dicomuid;
specs.PatientID = pid;
specs.StudyInstanceUID = study_UID;
specs.PatientName = pid;
specs.res = res;
specs.StudyDate = datestr(data.date,'YYYYmmdd');
specs.StudyDescription = 'U24UTBS_preclinical_pdx';
specs.birth = datestr(data.date-90,'YYYYmmdd');

% (2a) Ktrans
specs.SeriesDescription = 'ktrans (1/min)';
specs.study_time = datestr(data.dce.params.ACQ_time,'HHMMSS.FFF');
specs.orient = data.dce.visu.VisuCoreOrientation(1:6);
specs.position= data.dce.visu.VisuCorePosition;            
specs.SeriesInstance = dicomuid;
ktrans = data.results.DCE.ktrans(:,:,:,1);
save_loc = [pwd '/pDCM/' pid '/v' datestr(data.date,'YYYYmmdd') '/ktrans/'];
mkdir(save_loc)
dicomwriter_u24_v1(ktrans,specs,data.tumor,save_loc,[],clinical)

% (2b) ve
specs.SeriesDescription = 've';
specs.study_time = datestr(data.dce.params.ACQ_time,'HHMMSS.FFF');
specs.orient = data.dce.visu.VisuCoreOrientation(1:6);
specs.position = data.dce.visu.VisuCorePosition;
specs.SeriesInstance = dicomuid;
ve = data.results.DCE.ve(:,:,:,1);
save_loc = [pwd '/pDCM/' pid '/v' datestr(data.date,'YYYYmmdd') '/ve/'];
mkdir(save_loc)
dicomwriter_u24_v1(ve,specs,data.tumor,save_loc,[],clinical)

% (2c) T1 map
specs.SeriesDescription = 'T1m (ms)';
specs.study_time = datestr(data.dce.params.ACQ_time,'HHMMSS.FFF');
specs.orient = data.dce.visu.VisuCoreOrientation(1:6);
specs.position = data.dce.visu.VisuCorePosition;
specs.SeriesInstance = dicomuid;
T1m = data.results.T1pre(:,:,:,1,1);
save_loc = [pwd '/pDCM/' pid '/v' datestr(data.date,'YYYYmmdd') '/T1map/'];
mkdir(save_loc)
dicomwriter_u24_v1(T1m,specs,data.tumor,save_loc,[],clinical)


% (2d) dynamic
specs.SeriesDescription = 'T1wDCE';
specs.study_time = datestr(data.dce.params.ACQ_time,'HHMMSS.FFF');
specs.orient = data.dce.visu.VisuCoreOrientation(1:6);
specs.position = data.dce.visu.VisuCorePosition;
specs.SeriesInstance = dicomuid;
T1w = mean(data.dce.im(:,:,:,:),4);
T1w = 1000*T1w/10^(floor(log10(mean(T1w(:)))));
save_loc = [pwd '/pDCM/' pid '/v' datestr(data.date,'YYYYmmdd') '/T1w/'];
mkdir(save_loc)
dicomwriter_u24_v1(T1w,specs,data.tumor,save_loc,[],clinical)












