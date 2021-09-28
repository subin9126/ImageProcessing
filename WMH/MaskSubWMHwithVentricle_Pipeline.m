function [ SubMask ] = MaskSubWMHwithVentricle_Pipeline(WMHMask, VNII, ROItype)
    SizeX = VNII.hdr.dime.pixdim(2);
    SizeY = VNII.hdr.dime.pixdim(3);
    SizeZ = VNII.hdr.dime.pixdim(4);
    [WMHMask_CCL, WMHNum] = bwlabeln(WMHMask>0);
    SubMask = WMHMask_CCL;
    DistanceMap = bwdistsc((VNII.img>0), [SizeX SizeY SizeZ]);
    DistanceMap = DistanceMap * norm([SizeX SizeY SizeZ]);
    
    if strcmp(ROItype, 'PVvsD')        
        % for each WMH component
        for idxWMH = 1:WMHNum
            % Find WMH voxel indexes, to access as WMH.img(WMHX, WMHY, WMZ)
            VoxelIndexes = find(WMHMask_CCL==idxWMH);
            VoxelNum = size(VoxelIndexes, 1);
            [WMHX, WMHY, WMHZ] = ind2sub(size(WMHMask), VoxelIndexes);
            clear VoxelIndexes;
            
            DistVector = zeros(VoxelNum, 1);
            for i=1:VoxelNum
                DistVector(i) = DistanceMap(WMHX(i), WMHY(i), WMHZ(i));
            end
            MinDistance = min(DistVector);
            clear DistVector;
            
            if MinDistance < 4  % Periventricular WMH
                for i=1:VoxelNum
                    SubMask(WMHX(i), WMHY(i), WMHZ(i)) = 1;
                end                
            else                 % Deep WMH
                for i=1:VoxelNum
                    SubMask(WMHX(i), WMHY(i), WMHZ(i)) = 2;
                end                      
            end
        end
    elseif strcmp(ROItype, 'JVvsPVvsD')
        VoxelIndexes = find(WMHMask>0);
        VoxelNum = size(VoxelIndexes, 1);
        [WMHX, WMHY, WMHZ] = ind2sub(size(WMHMask), VoxelIndexes);
        clear VoxelIndexes;
        
        DistanceMask = WMHMask .* DistanceMap;
        for i=1:VoxelNum
            if DistanceMask(WMHX(i), WMHY(i), WMHZ(i)) < 4          % Juxtaventricular WMH
                SubMask(WMHX(i), WMHY(i), WMHZ(i)) = 1;
            elseif DistanceMask(WMHX(i), WMHY(i), WMHZ(i)) < 14     % Periventricular WMH
                SubMask(WMHX(i), WMHY(i), WMHZ(i)) = 2;
            else
                SubMask(WMHX(i), WMHY(i), WMHZ(i)) = 3;             % Deep WMH
            end
        end
    end
end

