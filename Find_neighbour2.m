function [neigh] = Find_neighbour2(popSize)

col_neigh = 10;
RowMat = floor(popSize/col_neigh);
mat_pop = zeros(RowMat,col_neigh);

individual.index = [];
neigh = individual;

ind = 1:popSize;
k=1;

for i = 1:RowMat
    for j = 1:col_neigh
        mat_pop (i,j) = ind(k);
        k = k+1;
    end
end

for i = 1:RowMat
    for j = 1:col_neigh
        kk =1;
        l = mat_pop(i,j);
        if j+1<=col_neigh
            neigh(l).index(kk) = mat_pop(i,j+1);
            kk = kk+1;
        end
        
        if i+1 <= RowMat
            neigh(l).index(kk) = mat_pop(i+1,j);
            kk = kk+1;
        end
        
        if j+1<=col_neigh && i+1<=RowMat
            neigh(l).index(kk) = mat_pop(i+1,j+1);
            kk = kk+1;
        end
        
        if j-1~=0
            neigh(l).index(kk) = mat_pop(i,j-1);
            kk = kk+1;
        end
        
        if j-1~=0 && i+1<=RowMat
            neigh(l).index(kk) = mat_pop(i+1,j-1);
            kk = kk+1;
        end
        
        if i-1~=0
            neigh(l).index(kk) = mat_pop(i-1,j);
            kk = kk+1;
        end
        
        if i-1~=0 && j-1~=0
            neigh(l).index(kk) = mat_pop(i-1,j-1);
            kk = kk+1;
        end
        if i-1~=0 && j+1<=col_neigh
            neigh(l).index(kk) = mat_pop(i-1,j+1);
            %             kk = kk+1;
        end
    end
end

end