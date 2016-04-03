function povout(cellids,coords)

fid = fopen('cellinfo.inc', 'w');

%%%%%%% create and write colormap
ncelltypes=numel(union(cellids,cellids));
cmap=jet(ncelltypes);
fprintf(fid, '#declare MyColors = array[%d]{\n',ncelltypes);
for i=1:ncelltypes       
    fprintf(fid, '<%1.4f,%1.4f,%1.4f>',cmap(i,1),cmap(i,2),cmap(i,3));
    if i<ncelltypes
        fprintf(fid, ', ');
    end
end
fprintf(fid, ' }\n');
%%%%%%%%%%%%%%%%

%%%%%%%% write cell identities as vector
fprintf(fid, '#declare Cellids = array[%d]{\n',numel(cellids));
for i=1:numel(cellids)
    fprintf(fid, '%d',cellids(i));   
    if i<numel(cellids)
        fprintf(fid, ', ');
    end 
end
fprintf(fid, ' }\n');   
%%%%%%%%%%

%%%%%%%% write cell coordinates as 2 dimensional vector
scalingfactor=10000;
zspacing=0.01*scalingfactor;  % z-shift per layer
fprintf(fid, '#declare Coords = array[%d][%d]{\n',numel(coords),numel(cellids));
for k=1:numel(coords) % for each dimension
     mds=coords{k};     
     fprintf(fid, '{ ');
     for l=1:size(mds,1) 
        id=cellids(l);
        if id>ncelltypes
            disp('mismatch between cellids and coord length!')
        end               
        fprintf(fid,'<%4.2f,%4.2f,%4.2f>',mds(l,1)*scalingfactor,mds(l,2)*scalingfactor,k*zspacing);            
        if l<size(mds,1)
           fprintf(fid, ', ');
        end 
     end
     fprintf(fid, ' }');
     if k<numel(coords)
        fprintf(fid, ', ');
     end 
     fprintf(fid, '\n');
end
fprintf(fid, '}\n');
%%%%%%%%%%%


%%%%%%%%% write loop for rendering with given data
%%%%%%%%%

fclose(fid);

end

