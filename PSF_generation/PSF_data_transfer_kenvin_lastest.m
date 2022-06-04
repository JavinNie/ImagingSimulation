clear
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variable declaration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% local_path='E:\OXAI\ImagingSimulation-master\PSF_generation';
local_path='E:\OXAI\ImagingSimulation-master\PSF_generation\ZOS_MATLAB';
% local_path='.';
% PSF data source path
PSF_data_folder = [local_path,'\PSF_data\'];
% PSF information save path
PSF_info_folder = [local_path,'\PSF_info\'];
% wave number to synthetic a three channel PSF, which is defined by  
% (wave distribution range)/(wave_interval)
wave_num = 340/10;
% sample interval of field in millimeters
fld_sample_interval = 0.02;
% the max field range and the min field range
fld_max_value = 4.00; fld_min_value = 0.00;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSF data transfer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up interface
TheApplication = MATLABZOSConnection1;
TheSystem = TheApplication.PrimarySystem;
%% Aperture
TheSystemData = TheSystem.SystemData;
TheSystemData.Aperture.ApertureValue = 20;

%% Change field 1 
sysField1=TheSystemData.Fields.GetField(1);
sysField1.X = 0.0;

%% Change sysWavelength 1 to 0.55um
sysWavelength1 = TheSystemData.Wavelengths.GetWavelength(1);

% Open the Huygen's PSF. We will use the default settings for now    
huygensPSF = TheSystem.Analyses.New_HuygensPsf(); 
huygensSettings =huygensPSF.GetSettings();
huygensSettings.PupilSampleSize=ZOSAPI.Analysis.SampleSizes.S_256x256;
huygensSettings.ImageSampleSize=ZOSAPI.Analysis.SampleSizes.S_128x128;
huygensSettings.Wavelength.SetWavelengthNumber(1);
huygensPSF.ApplyAndWaitForCompletion();    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSF data transfer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for fld_index = fld_min_value:fld_sample_interval:fld_max_value
    fld_index_str = num2str(round(fld_index * 100), '%03d');
    % convert the field information to string
    fld_index_str = strcat('PSF_info_fld_', fld_index_str);

    [status, msg, msgID] = mkdir(strcat(PSF_info_folder, fld_index_str));

    %% Change field 1 
    sysField1.Y = fld_index;
    

    % run every wave information
    for wave_index = 1:wave_num
        PSF_wav_tmp=0.74-wave_index*0.01;%um
        %% Change sysWavelength 1 to 0.55um
        sysWavelength1 = TheSystemData.Wavelengths.GetWavelength(1);
        sysWavelength1.Wavelength = PSF_wav_tmp;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % huygensSettings.Field.SetFieldNumber(1)
%         huygensSettings.Wavelength.SetWavelengthNumber(1);
        % Run the analysis with the current settings and pull the results 
        huygensPSF.ApplyAndWaitForCompletion();    
        huygensResults = huygensPSF.GetResults();
        huygensResults.GetTextFile([local_path, '\PSF.txt']);
      
        PSFdata=importdata([local_path, '\PSF.txt']);
        wav_PSF=PSFdata.data;
%         OpticStudio has pixel (1,1) in the top left of the matrix    
%         Matlab places the (1,1) at the bottom so we need to flip the matrix    
        wav_PSF = flipud(wav_PSF);  
%         wav_PSF=imresize(wav_PSF,[100,100]);
        wav_txt=PSFdata.textdata;

        PSF_wav_tmp_2 = round(100 * PSF_wav_tmp);
        % save the wave PSF and the wave txt information
        mat_path = strcat(PSF_info_folder, fld_index_str, '\wav_', num2str(PSF_wav_tmp_2, '%03d'), '.mat');
        save(mat_path, 'wav_PSF', 'wav_txt');

        % Run the analysis with the current settings and pull the results
%         huygensResults = huygensPSF.GetResults();     
        % The results will be split into multiple data structures    
        % One structure will house the header information    
        % Another structure will house the relative intensity values    
        % Pull the structure with the intensity values    
%         matrixData = huygensResults.DataGrids(1).Values.double;        
        % OpticStudio has pixel (1,1) in the top left of the matrix    
        % Matlab places the (1,1) at the bottom so we need to flip the matrix    
%         wav_PSF = flipud(matrixData);        

        imagesc(wav_PSF)     
        axis square;        
        title(["Field: " num2str(1)]);
        % imshow(huygensData)  
        % colormap jet;  
    end
    % print the mark information
    formatSpec = 'field of %02.2f is finished!\n';
    fprintf(formatSpec, fld_index);
end
% Close the Huygen's plot    
huygensPSF.Close();
toc