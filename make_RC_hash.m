function [RC_hash_idx, RC_hash] = make_RC_hash( nr, nc, pts, bin_width )
%
%   make a hash table of point locations.
%
% pts are assumed not to have r or c value of 0.
%
% copyright d sinclair 2020
% 

num_binsR = ceil(nr/bin_width +1);
num_binsC = ceil(nc/bin_width +1);

RC_hash_idx = zeros(num_binsR, num_binsC);

idx = 0;
RC_hash = [];
RC_hash.n = 0;
RC_hash.ids = zeros(0,1);

nump = size(pts,1);

for p=1:nump
    r = pts(p,1);
    c = pts(p,2);
    
    R = ceil(r/bin_width);
    C = ceil(c/bin_width);
    id = RC_hash_idx(R,C);
    if id == 0
       idx = idx+1;
       RC_hash_idx(R,C) = idx;
       RC_hash(idx).n = 1;
       RC_hash(idx).ids(1) = p;
    else
       n = RC_hash(id).n+1;
       RC_hash(id).ids(n,1) = p;
       RC_hash(id).n = n;
    end
    
end