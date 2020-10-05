# basic_vision_corner_matching
matlab for Harris corner matching example code.

includes a median flow filter for filtering out erroneous matches:
Delaunay triangulaiton is used to find nearest neighbours,
any match require 2 supporting matches similar to it 
to be considered a good match.

More efficient than RANSAC.
