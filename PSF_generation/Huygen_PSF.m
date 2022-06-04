TheApplication = MATLABZOSConnection1;
TheSystem = TheApplication.PrimarySystem;

local='E:\OXAI\ImagingSimulation-master\PSF_generation\ZOS_MATLAB\';

% % Aperture
TheSystemData = TheSystem.SystemData;
TheSystemData.Aperture.ApertureValue = 20;
% % Fields
% Field_1 = TheSystemData.Fields.GetField(1);
% NewField_2 = TheSystemData.Fields.AddField(0,5.0,1.0);
% % Wavelength preset
% slPreset = TheSystemData.Wavelengths.SelectWavelengthPreset(ZOSAPI.SystemData.WavelengthPreset.d_0p587);

%% Change sysWavelength 1 to 0.55um
sysWavelength1 = TheSystemData.Wavelengths.GetWavelength(1);
sysWavelength1.Wavelength = 0.40;

%% Change field 1 to be X=1.0 and Y=2.0
sysField1=TheSystemData.Fields.GetField(1);
sysField1.X = 0.0;
sysField1.Y = 2.0;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open the Huygen's PSF. We will use the default settings for now    
huygensPSF = TheSystem.Analyses.New_HuygensPsf(); 
huygensPSF.ApplyAndWaitForCompletion();   
huygensSettings =huygensPSF.GetSettings();

%% huygensPSF.
% for field=[0,2:6]
tic
% huygensSettings.Field.SetFieldNumber(1)
huygensSettings.Wavelength.SetWavelengthNumber(1);
huygensSettings.PupilSampleSize=ZOSAPI.Analysis.SampleSizes.S_128x128;
huygensSettings.ImageSampleSize=ZOSAPI.Analysis.SampleSizes.S_128x128;

huygensPSF.ApplyAndWaitForCompletion();   
% huygensSettings.GetType()
% Run the analysis with the current settings and pull the results 
huygensResults = huygensPSF.GetResults();
% 
% Rays = RayPath.GetResults();
% Rays.GetTextFile(System.String.Concat(TheApplication.SamplesDir, '\API\Matlab\e10_RayPathAnalysis.txt'));

huygensResults.GetTextFile([local, 'PSF.txt']);
PSFdata=importdata([local, 'PSF.txt']);
wav_PSF=PSFdata.data;
wav_txt=PSFdata.textdata;

% xlswrite('psf.xlsx', PSFdata);
% The results will be split into multiple data structures    
% One structure will house the header information    
% Another structure will house the relative intensity values    
% Pull the structure with the intensity values    
% matrixData = huygensResults.DataGrids(1).Values.double;        

% OpticStudio has pixel (1,1) in the top left of the matrix    
% Matlab places the (1,1) at the bottom so we need to flip the matrix    
huygensData = flipud(matrixData);        

toc
% end

% Use pixel data to create a figure    
% The jet colormap will match closely with the False Color plot    
% figure
imagesc(huygensData)    
% imshow(huygensData)  
% colormap jet;    
axis square;        
title(["Field: " num2str(1)]);

% Close the Huygen's plot    
huygensPSF.Close();