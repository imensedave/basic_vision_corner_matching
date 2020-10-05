function [good_pts] = median_flow_filter(matches, pts, pts2, pflag)
%
%  filter out outliers in the candidate point mathces.
%
%  this implementaiton just uses single forward matches.
%
%
%
% copyright d.sinclair 2020
%


num = size(matches,1);
muts = zeros(num,3);

ids0 = matches(:,1);
ptx = pts(ids0(:),1:2);  % could add extra-image point to reduce image boundary neighbouring point issues

matx = [(1:num)', matches(:,2)];

% find adjacencies based on delaunay triangles.

tris = delaunay(ptx(:,1), ptx(:,2));

if( pflag > 0 )
   figure(pflag + 10)
   plot( pts(:,2), -pts(:,1),'r+')
   hold on
   triplot(tris, ptx(:,2), -ptx(:,1))
   hold off
end



adjs = [];
adjs.ids = [];
adjs(num).ids = [];

numt = size( tris,1);
for k=1:numt
   tr = tris(k,:);
   a = tr(1);
   b = tr(2);
   c = tr(3);

   adjs(a).ids = [adjs(a).ids; b];
   adjs(b).ids = [adjs(b).ids; a];
   
   adjs(a).ids = [adjs(a).ids; c];
   adjs(c).ids = [adjs(c).ids; a];

   adjs(b).ids = [adjs(b).ids; c];
   adjs(c).ids = [adjs(c).ids; b];

end

for k=1:num
   ids = sort(adjs(k).ids);
   idx = [1; find( ids(1:end-1) ~= ids(2:end))+1];
   adjs(k).ids = ids(idx);
end



% for each match find surrounding matched points and do that medieval 
% flow thing with the bucket and the stick.

good_pts = zeros(0,1)';
numg = 0;


for k=1:num
    pt = ptx(k,:);
    ids = adjs(k).ids;
    ni = size(ids,1);
    for n=1:ni
        ids = [ids; adjs(ids(n)).ids];
    end
    ids = sort(ids);
    idx = [1; find( ids(1:end-1) ~= ids(2:end))+1];
    ids = ids(idx);
    
    % find closest seven points to pt 
    ptz =  ptx( ids(:), 1:2);
    nz = size(ptz,1);
    dx = ptz - ones(nz,1)*pt;
    DX = sum(dx.*dx,2);
    [DXs,DX_ord] = sort( DX,'ascend');
    
    % find number of points closer than 20 poxels
    idZ = find( DXs < 600 );
    nZ = size(idZ,1);

    if( nZ > 3)
        if( nZ > 10 )
            nZ = 8;
        end
        
        idz = ids(DX_ord(1:nZ));
        ptz8 = ptx(idz,1:2);
    
        midz = matx(idz,2);  % pts2 idx
        ptx2 = pts2(midz(:),1:2);
        
        dx2 = ptx2 - ptz8;
        DX2 = sum(dx2.*dx2,2);        
        [DX2s,DX2_ord] = sort( DX2,'ascend');
        
        
        if( 0 )
            figure(88)
            
            plot( pts(:,2), -pts(:,1), 'r.')
            hold on
            %plot( ptx(:,2), -ptx(:,1), 'g.')
            
            plot( ptz(:,2), -ptz(:,1), 'gx')
            
            plot( pt(2), -pt(1),'rx');
            
                        
            hold off
        end
        
        
        idZ2 = find( DX2s < 16 );
        nZ2 = size(idZ2,1);
        
        if( nZ2 >= 3 ) % keep point as a good point
            % could filter on direction of flow vector for longer flow:
            % vectors (sort in theta, find narrowest cluster of 5, measure distance to median of 5 ) 
            % but here we are just going to be cheap.
            numg = numg + 1;
            good_pts(numg,1) = ids0(k);
        end
           
    else
        % not sure what to do with points with no supportive neighbours.
        numg = numg + 1;
        good_pts(numg,1) = ids0(k);
        
    end
    
end
    

return;
   
   
   