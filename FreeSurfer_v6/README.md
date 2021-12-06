# FreeSurfer Pipeline Overview
This pipeline processes T1-weighted MRI to obtain anatomical labels and regional metrics (volume, cortical thickness) from each subject.

![git_fig_fs pipeline overview_0](https://user-images.githubusercontent.com/46069735/144862145-32c93dbb-dcd2-405b-baf6-cb67dc1b01c6.PNG)

![git_fig_fs pipeline overview](https://user-images.githubusercontent.com/46069735/144862159-3134eed2-f6cc-4757-8071-4c367a20ef60.PNG)


## Directions
Run files step-by-step in the following order:
* 0_download_T1
* 1_convert_to_isonii_and_upload_to_server
* 2_reconall_parallel_gtmseg  (run _1 to _6 at same time)
* 3_upload_fsresults_to_server
* 4_Extract_FS_Masks
* 5_Extract_FS_stats

Only edit paths and subject info.

No need to make changes to code below ######## line

Check outputs in between steps.
