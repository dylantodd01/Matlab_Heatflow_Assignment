function minTileThickness = getMinTileThickness(maxAllowableTemp)
%MINTILETHICKNESS Calculates the minimum tile thickness for any tile on the
%   space shuttle, given a maximum allowable temperature
%   
%   maxAllowableTemp = the melting point of the space shuttle 
%   (must be <~ 1100 K)
%   tileThickness = the minimum required tile thickness

tile_numbers = [468, 480, 502, 590, 597, 711, 730, 850];
min_thicknesses = [];
for tile_number = tile_numbers
    min_thicknesses(end+1) = shootingMethod(maxAllowableTemp, tile_number);
end    

minTileThickness = max(min_thicknesses);

end

