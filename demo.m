function  matches = demo( fname, fname2)
%
% corner matching demo.
%
%
%
%
% demo( 'img001874.jpeg', 'img001874.jpeg')
%
% copyright d.sinclar 2020
%


% load images.

im = double(rgb2gray( imread(fname)));
im2 = double(rgb2gray( imread(fname2)));

% find Steve Harris style corners.

pts  = Harris(im,  2.0, 0.04);
pts2 = Harris(im2, 2.0, 0.04);

pflag = 100;

% display corners on images
if( pflag )

    figure(pflag )
    imagesc( im )
    nump = size(pts,1);
    colormap gray

    ['Harris corrners ', int2str(nump), ' from image ', fname] 

    hold on
    if( nump > 2000 )
        nump = 2000;
    end
    plot( pts(1:nump,2), pts(1:nump,1), 'rx')
    hold off
    
    
    figure(pflag+1 )
    imagesc( im2 )
    nump = size(pts2,1);
    hold on
    if( nump > 2000 )
        nump = 2000;
    end
    plot( pts2(1:nump,2), pts2(1:nump,1), 'gx')
    hold off
    
    
end


% make a 2D hash table of point locations for image2

[nr,nc] = size(im2);
bin_width = 10;
[RC_hash_idx, RC_hash] = make_RC_hash( nr, nc, pts2, bin_width );

% for each corner in pts find candidate match  points in image2

nump = size(pts,1);
br = nr - 10;
bc = nc - 10;
mm = 0;
matches = zeros(0,3);
[NR,NC] = size(RC_hash_idx);

for p=1:nump
    r = pts(p,1);
    c = pts(p,2);

    if( r > 10 & r < br & c<bc &c>10 )
        candidates = zeros(0,1);
    
        % find central hash bucket.
        
        Rx = ceil( r/bin_width );
        Cx = ceil( c/bin_width );
        
        % need to take in the bins round bin (R,C)
        for R = Rx-1:Rx+1
            if( R > 0 )
                for C = Cx-3:Cx+3
                    if (C > 0 && C <= NC )
                        hidx = RC_hash_idx(R,C);
                        if( hidx > 0 )
                            
                            candidates = [candidates; RC_hash(hidx).ids];
                        end
                    end
                end
            end
        end

    
        % filter candidates by distance to r,c
    
        numc = size(candidates,1);
        % use an 11x11 image patch for matching.
        m = im(r-5:r+5, c-5:c+5);
        muc = 0.3;
        mid2 = -1;
        
        for q=1:numc
            p2 = candidates(q);
            r2 = pts2(p2,1);
            c2 = pts2(p2,2);
        
            if( abs(r-r2) < 10 && abs(c-c2) < 30 )
                m2 = im2( r2-5:r2+5, c2-5:c2+5);
                
                % dave's fave metric in mutlab.
                s1 = sum( abs( m(:)-m2(:)));
                s2 = sum( min( m(:), m2(:)));
                erx = s1/(s2+20);
                if( erx < muc)
                    muc = erx;
                    mid2 = p2;
                end
            end
        end
                    
        if( mid2 > 0 )
            mm = mm+1;
            matches(mm,:) = [ p,mid2,erx];
            
        end
    end
end

% display some of the unfiltered matches
['matched points ', int2str(mm), ' from ', int2str(nump), '  points '] 

if( mm > 0 )
    
    if(0)
        imx = [im,im2];
        figure( pflag +2 );
        imagesc( imx )
        colormap gray
        hold on
        nu = min(mm,50);
        for z=1:nu
            rc1 = pts(matches(z,1),1:2);
            rc2 = pts2(matches(z,2),1:2);
            
            plot( [rc1(2);rc2(2)+nc], [rc1(1);rc2(1)],'b' );
        end
        hold off
    end
    
    cim = uint8(zeros(nr,nc,3));
    cim(:,:,1) = im(:,:);
    cim(:,:,2) = im2(:,:);
    
    
        figure( pflag +3 ); 
        imagesc( cim )
        colormap gray
        hold on
        nu = min(mm,4000);
        for z=1:nu
            rc1 = pts(matches(z,1),1:2);
            rc2 = pts2(matches(z,2),1:2);
            
            plot( [rc1(2);rc2(2)], [rc1(1);rc2(1)],'b' );
            
            plot( rc1(2), rc1(1),'rx' );
        end
        
        plot( pts2(:,2), pts2(:,1),'g+' );
        
        
        hold off
    
    
end
