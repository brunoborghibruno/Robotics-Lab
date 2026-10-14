%% BRUNO BORGHI  -  Meals Signal Analysis

function     [effective_acc_raw, acc_x_direction, acc_y_direction, acc_z_direction]  =  mealsSignalAnalysis(acc_raw, acc_raw_normalized, marker)

mealMarkers              =  [marker(4):marker(5), marker(6):marker(7), marker(8):marker(9), marker(13):marker(14), marker(17):marker(18), marker(19):marker(20), marker(26):marker(27)];
effective_acc_raw_meals  =  acc_raw_normalized(mealMarkers);
acc_x_direction_meals    =  acc_raw(mealMarkers, 1);
acc_y_direction_meals    =  acc_raw(mealMarkers, 2);
acc_z_direction_meals    =  acc_raw(mealMarkers, 3);
effective_markers        =  [marker(5)-marker(4), marker(7)-marker(6), marker(9)-marker(8), marker(14)-marker(13), marker(18)-marker(17), marker(20)-marker(19), marker(27)-marker(26)];
effective_meals_marker   =  effective_markers(1);

for count = 2:length(effective_markers)
    effective_meals_marker  =  [effective_meals_marker, effective_meals_marker(end) + effective_markers(count)];
end



% OVERWRITE HERE FOR "effective_acc_raw" etc..
effective_acc_raw  =  effective_acc_raw_bathing;
acc_x_direction    =  acc_x_direction_bathing;
acc_y_direction    =  acc_y_direction_bathing;
acc_z_direction    =  acc_z_direction_bathing;

end