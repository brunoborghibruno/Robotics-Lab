%%  BRUNO BORGHI    - remove outliers and normalize by keeping the correspondance in the indexes

function [normalizedError, normalizedSpeed] = filterAndNormalize(errorToFilter, errorMin, errorMax, speedToFilter, speedMin, speedMax, error_lower_bound, error_upper_bound, speed_lower_bound, speed_upper_bound)

    % Identify outliers for error
    is_outlier_error = (errorToFilter < error_lower_bound) | (errorToFilter > error_upper_bound);

    % Identify outliers for speed
    is_outlier_speed = (speedToFilter < speed_lower_bound) | (speedToFilter > speed_upper_bound);

    % Combine masks -> remove if it's an outlier in EITHER vector
    is_outlier = is_outlier_error | is_outlier_speed;

    % Apply mask
    filteredError = errorToFilter(~is_outlier);
    filteredSpeed = speedToFilter(~is_outlier);

    % Normalize
    % normalizedError = normalizeData(filteredError, errorMin, errorMax);
    % normalizedSpeed = normalizeData(filteredSpeed, speedMin, speedMax);
    normalizedError = filteredError;
    normalizedSpeed = filteredSpeed;
end
