# FreeSurfer Pipeline Overview
This pipeline processes T1-weighted MRI to obtain anatomical labels and regional metrics (volume, cortical thickness) from each subject.

![git_fig_fs pipeline overview_0](https://user-images.githubusercontent.com/46069735/144740241-073badb3-931a-4eec-b236-705bf3ac236f.PNG)

![git_fig_fs pipeline overview](https://user-images.githubusercontent.com/46069735/144739957-d4d5f800-0528-42e4-a837-ad4e8858e3e7.PNG)

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
