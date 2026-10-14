%% BRUNO BORGHI - Bathing signal analysis

function     [effective_acc_raw, acc_x_direction, acc_y_direction, acc_z_direction, effective_bathing_marker]  =  bathingSignalAnalysis(acc_raw, acc_raw_normalized, marker)

bathingMarkers             =  [marker(2):marker(3), marker(10):marker(12), marker(15):marker(16), marker(23):marker(24)];
effective_acc_raw_bathing  =  acc_raw_normalized(bathingMarkers);
acc_x_direction_bathing    =  acc_raw(bathingMarkers, 1);
acc_y_direction_bathing    =  acc_raw(bathingMarkers, 2);
acc_z_direction_bathing    =  acc_raw(bathingMarkers, 3);
effective_markers_2        =  [marker(3)-marker(2), marker(12)-marker(10), marker(16)-marker(15), marker(24)-marker(23)];
effective_bathing_marker   =  effective_markers_2(1);

for count = 2:length(effective_markers_2)
    effective_bathing_marker  =  [effective_bathing_marker, effective_bathing_marker(end) + effective_markers_2(count)];
end

% OVERWRITE HERE FOR "effective_acc_raw" etc..
effective_acc_raw  =  effective_acc_raw_bathing;
acc_x_direction    =  acc_x_direction_bathing;
acc_y_direction    =  acc_y_direction_bathing;
acc_z_direction    =  acc_z_direction_bathing;

end