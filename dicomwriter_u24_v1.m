function dicomwriter_u24_v1(data,specs,mask,save_loc,info1)
%{
data = image map you want to write as a dicom
specs = all of the dicomheader information that needs to be written
mask = mask of tumor
save_loc = directory where you want to save files
%}

% cb: David A Hormuth II
% co: 08/28/2020
% Purpose: For writing dicom images and contours for Epad

warning off
[sy,sx,sz] = size(data);

%(1) Select image type
if strcmp(specs.SeriesDescription,'ADC (um^2/ms)')
    SN = 1;
    data(data>3.5e-3) = 3.5e-3;
    data(data<0) = 0;
    data = data*(1e6);
    slope = 1e-3;
    intercept = 0;
    
    fn = 'ADC_';
    wc = 1.75;
    ww = 3.5;
    
    
elseif strcmp(specs.SeriesDescription,'T1m (ms)')
    SN = 2;
    data(data>4e3) = 4e3;
    data(data<0) = 0;
    slope = 1;
    intercept = 0;
    fn = 'T1_m';
    wc = 2122;
    ww = 4475;
    
elseif strcmp(specs.SeriesDescription,'ktrans (1/min)')
    SN = 3;
    data(data>1) = 1;
    data(data<0) = 0;
    data = data*1e4;
    slope = 1e-4;
    intercept = 0;
    fn = 'ktrans';
    wc = .2722;
    ww = 0.6691;
    
elseif strcmp(specs.SeriesDescription,'ve')
     SN = 4;
    data(data>1) = 1;
    data(data<0) = 0;
    data = data*1e5;
    slope = 1e-5;
    intercept = 0;
    fn = 've';
    wc = .2722;
    ww = 0.6691;   
    
elseif strcmp(specs.SeriesDescription,'kep (1/min)')
    SN = 5;
    data(data>1) = 1;
    data(data<0) = 0;
    slope = 1e-4;
    data = data*1e4;
    
    intercept = 0;
    fn = 'kep';
    wc = .2722;
    ww = 0.6691;
    
elseif strcmp(specs.SeriesDescription,'T1wDCE')
    SN = 6;
    %sz = size(data,3);
    %noise = data(1:10,1:10,ceil(sz/2)-1:ceil(sz/2)+1); noise = mean(noise(:));
    %d2 = data(:,:,ceil(sz/2)-1:ceil(sz/2)+1);
    %histogram(d2(d2(:)>5*noise))
    ww = max(data(:))-min(data(:));
    wc = (ww/2)+min(data(:));
    fn = 'T1wDCE';
    intercept = 0;
    slope = 1;
%end

elseif strcmp(specs.SeriesDescription,'SER')
    SN = 7;
    %sz = size(data,3);
    %noise = data(1:10,1:10,ceil(sz/2)-1:ceil(sz/2)+1); noise = mean(noise(:));
    %d2 = data(:,:,ceil(sz/2)-1:ceil(sz/2)+1);
    %histogram(d2(d2(:)>5*noise))
    ww = max(data(:))-min(data(:));
    wc = (ww/2)+min(data(:));
    fn = 'SER_';
    mask(isnan(mask)) = 0;
    slope = 1;
    intercept = 0;
    ww = max(data(:))-min(data(:));
    wc = (ww/2)+min(data(:));
end


% (2) Write out dicom images
for z = 1:size(data,3)
    dicomwrite(uint16(data(:,:,z)),[save_loc specs.PatientName '_' fn '_' num2str(z) '.dcm'],'PatientName',...
        specs.PatientName,'PatientID',specs.PatientID, 'StudyDate',specs.StudyDate,'StudyInstanceUID',specs.StudyInstanceUID...
        ,'Modality','MR','SeriesDescription',specs.SeriesDescription,...
        'StudyDescription',specs.StudyDescription,'SliceThickness',specs.res(3),'PixelSpacing',...
        specs.res(1:2),'SeriesInstanceUID',specs.SeriesInstance...
        ,'PatientBirthDate',specs.birth ,'WindowCenter',wc,'WindowWidth',ww,...
        'ImagesInAcquisition',sz,'InstanceNumber',z,...
        'SeriesNumber',SN,'SliceLocation',specs.position(3)+(z-1)*specs.res(3),'PatientPosition',specs.patient_pos,...
        'SOPClassUID','1.2.840.10008.5.1.4.1.1.4',...
        'ImageOrientationPatient',specs.orient,...
        'FrameOfReferenceUID',specs.SeriesInstance,...
        'ImagePositionPatient',[specs.position]+[0 0 (z-1)*specs.res(3)],...
        'CreateMode','Copy',...
        'PatientSex','F');     
end


% (3) Write out contours
segment_info.AlgorithmType='SEMIAUTOMATIC';
segment_info.AlgorithmName='UTA';
segment_info.AnatomicRegionSequence.CodeValue='T-D0050';
segment_info.AnatomicRegionSequence.CodingSchemeDesignator='SRT';
segment_info.AnatomicRegionSequence.CodeMeaning='Tissue';
segment_info.SegmentedPropertyCategoryCodeSequence.CodeValue='T-D0050';
segment_info.SegmentedPropertyCategoryCodeSequence.CodingSchemeDesignator='SRT';
segment_info.SegmentedPropertyCategoryCodeSequence.CodeMeaning='Tissue';
segment_info.SegmentedPropertyTypeCodeSequence.CodeValue='T-D0050';
segment_info.SegmentedPropertyTypeCodeSequence.CodingSchemeDesignator='SRT';
segment_info.SegmentedPropertyTypeCodeSequence.CodeMeaning='Tissue';


% clc
try  
    delete([save_loc specs.PatientName '_' fn '_tumor.dcm'])
end
write_seg_status = write_DSO(save_loc,[specs.PatientName fn '_tumor'], mask, save_loc, false, false, segment_info);

