# WMH Pipeline Overview

This pipeline processes fluid attenuated inverse recovery (FLAIR) images to obtain segmentation of white matter hyperintensities (WMH) and their volumetrics (in mm^3)

The WMH are obtained in two types according to two different definitions:
* contunity-to-ventricle rule: 
  * WMH clusters bordering the ventricle in 3D space are pericentricular and those that do not are deep WMH.
  * mask contains labels of 1,2 which correspond to pericentricule and deep WMH segmentations respectively.
* distance from ventricle: 
  * <4mm: juxtaventricular, 4~14mm: periventricular, >14mm: deep WMH.
  * mask contains labels of 1,2,3 which correspond to juxta, periventricular, and deep WMH segmentations respectively. 

![git_fig_wmh pipeline overview](https://user-images.githubusercontent.com/46069735/138241103-d4391085-c831-46ba-8391-6b2e2617c27c.PNG)


## Directions
Run files step-by-step in the following order:
* 0_download_flair
* 1_download_fsmask_and_t1
* 2_3_4_5_biascorrect,makeWMHmasks
* 6_Upload_WMHfiles_to_server
* 7_Extract_WMH_Stats

Only edit paths and subject info.

No need to make changes to code below ######## line

Check outputs in between steps.
