function matches = match_corners(im, pts, im2, pts2, dist, pflag)
%
% match corner interest points based on local image patch correlation.
% use Delaunay triangulation to give neighbourhood structure. 
% use media flow filter 
% images are assumed to be the sime size.
%
% find candidate matches within distance threshold dist.
%
% if(pflag) display results.
%
% do the matching from frame1 to frame2
%
% copyright d.sinclair 2020
%

matches = [];

num = size(pts,1);
num2 = size(pts2,1);

[nr,nc] = size(im2);

% make hash table of R and C  point location in image 2.

bin_width = 8;
[RC_hash_idx, RC_hash] = make_RC_hash( nr, nc, pts2, bin_width );   




