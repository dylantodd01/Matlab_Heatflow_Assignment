function scangraphs
%SCANGRAPHS Function to get data from the graph images
%   This function scans the 8 JPG graph images for each tile 
%   and saves the timeData and tempData from each graph in a 
%   .mat file with the naming convention temp{tile_number}.JPG
%
% RUN THIS FUNCTION BEFORE ANYTHING ELSE

tile_numbers = [468, 480, 502, 590, 597, 711, 730, 850];

if ~exist('tile_data', 'dir')
    mkdir tile_data
end

for tile_number = tile_numbers
    % Read the image file and flip to format correctly
    filename = sprintf("graph_images/temp%d.jpg", tile_number);
    image = imread(filename);
    image = flip(image, 1);

    % Find image dimensions
    image_H = size(image, 1);
    image_W = size(image, 2);

    % Initialise vector to store data about each pixel
    % (pre-allocated for speed)
    pixels = zeros(image_H, image_W);
    % Create a RGB threshold value XX such that if all of the
    % RGB values fall below this threshold, the pixel will be
    % denoted black
    RGB_threshold = 90;

    % Loop through each pixel in the image and check for black
    % pixels (low RGB values) 
    % A black pixel is represented by a 1, a non-black pixel
    % a 0
    for y = 1:image_H
        for x = 1:image_W
            if (image(y,x,1) < RGB_threshold && image(y,x,2) ...
                < RGB_threshold && image(y,x,3) < RGB_threshold)
                pixels(y, x) = 1;
            else
                pixels(y, x) = 0;
            end
        end
    end


    % To find the x and y origins, we loop through each column/row
    % and count the number of black pixels. If this number is greater
    % than min_num_pixels, the loop is exited at the x_origin value
    min_num_pixels = 100;
    
    for x_origin = 1:image_W
        num_black_pixels_x = sum(pixels(:, x_origin));
        if num_black_pixels_x > min_num_pixels
            break
        end
    end

    for y_origin = 1:image_H
        num_black_pixels_y = sum(pixels(y_origin, :));
        if num_black_pixels_y > min_num_pixels
            break
        end
    end

    % To find the end of the x and y axis, we found the first instance
    % of 5 consecutive white pixels by summing the next 5 pixel 
    % values (1 for black and 0 for white/colour)
    for x_end = x_origin:image_W
        if sum(pixels(y_origin, x_end+1:x_end+6)) == 0
            break
        end
    end
    
    for y_end = y_origin:image_H
        if sum(pixels(y_end+1:y_end+6, x_origin)) == 0
            break
        end
    end
    
    % Initialise time and temperature vectors
    timeData = [];
    tempData = [];

    % Scan the image for high R values and low G and B values
    R_thresh = 150;
    G_thresh = 100;
    B_thresh = 100;
    for x = x_origin:x_end
        red_pixels = find(image(:, x, 1) > R_thresh & image(:, x, 2) ...
            < G_thresh & image(:, x, 3) < B_thresh);
        
        % If a red pixel is found, save the x and y coordinates
        if ~isnan(red_pixels)
            timeData(end+1) = x;
            % There are multiple red pixels in the y direction so 
            % the mean position is found
            tempData(end+1) = mean(red_pixels);
        end
    end


    % Zero our datapoints to the x and y origins
    tempData = tempData-y_origin;
    timeData = timeData-x_origin;

    % Scale the data to the axis
    timeData = (2000 /(x_end - x_origin)) * timeData;
    tempData = (2000 / (y_end - y_origin)) * tempData;
    
    % Add final values (temp is constant from t = 2000s to 4000s)
    % and remove duplicate datapoints
    tempData(end+1) = tempData(end);
    timeData(end+1) = 4000;
    [timeData, index] = unique(timeData);
    tempData = tempData(index);

    %Save data to .mat file with correct tile number
    save(sprintf('tile_data/temp%d', tile_number), 'timeData', 'tempData')

end

