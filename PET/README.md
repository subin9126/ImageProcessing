
# PET Pipeline Overview
This pipeline processes positron emission tomography (PET) scans with FreeSurfer output files to obtain partial volume-corrected standardized uptake values (pvcSUV) of each anatomical region. 

![git_fig_pet pipeline overview_0](https://user-images.githubusercontent.com/46069735/144858284-26ca0ded-979e-4125-bdc8-c44b29ff0dff.PNG)

![git_fig_pet pipeline overview](https://user-images.githubusercontent.com/46069735/144862077-d08ca864-a3cc-4b36-8e1f-8503a4d2f2c0.PNG)


## Directions
Run files step-by-step in following order:
* Rename_and_move_PETfiles.m
* Upload_files_to_server.m
* 0_download_PET
* 1_preprocess_pet
* 2_mri-pet_coreg
* 3_gtmpvc
* 4_upload_to_server
* 5_extract_PVCvalues

Only edit paths and subject info.

No need to make changes to code below ######## or %%%%%%%% line

Check outputs in between steps.
