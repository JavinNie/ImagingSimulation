# Optical aberrations Correction in Postprocessing using Imaging Simulation
The code is under reviewing by the First Party. 

Thanks for your waiting!

Our code will open source by April!

## 1¡¢PSF generation based ZOS-API
I¡¢zemax preparation
	a¡¢run zemax£¬open a imaging system
	b¡¢please set field 2: X=0,Y=2; field 3: X=2,Y=0; and the field 1 could be set randomly, it will be iterated.
	c¡¢please set only 1 wavelength. 
	d¡¢click-programming-Interactive Extansion
II¡¢Huygen_PSF genneration
	a¡¢enter ImagingSimulation-master\PSF_generation\ZOS_MATLAB
	
	b¡¢run "PSF_data_transfer_kenvin_lastest.m"
	
	*note: the sample setting of pupil and image could be reset. and the "imagedelta" presents the sample space which decides the PSF area can also be reset.

	then the "Interactive Extension" window in zemax jump up and show connected
and the PSF of each field and wavelength will be save to "PSF_info"
	
	c¡¢copy the "ImagingSimulation-master\PSF_generation\ZOS_MATLAB\PSF_info" into  "ImagingSimulation-master\PSF_generation\PSF_info"
	
	d¡¢run "PSF_coherent_superposition.m"
	*note: in the function "judge_main_wav.m" the wavelength of main light should be reset depends on the specific camera structure.
 
III¡¢imaging_simulation
	a¡¢set the WB and CCM coefficient
	b¡¢set the specific path of dataset image in code imaging_simulation
	c¡¢run imaging_simulation

IV¡¢fov_deformable_net
	a¡¢run the "image_transform_tiff.py" to transfer the processed image into .tiff format
	b¡¢ run the "dataset_generator.py"
the dataset would be packed in .h5py
	c¡¢after compiled the DCN£¬just carefully check the args in option.py
  then run the train.py
