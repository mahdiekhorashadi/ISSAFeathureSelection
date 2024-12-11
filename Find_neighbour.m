function [neigh] = Find_neighbour(pop)

individual.index = [];
neigh = individual;

% Sizeneigh = 8;
Sizeneigh = 3;
dim = size(pop,1);

dist = zeros(dim,dim);

for i =1:dim
    for j =1:dim
        dist(i,j) = sum(pop(i).Position == pop(j).Position);
    end
end

for ii = 1:dim

    [~, sortedIndices] = sort(dist(ii,:), 'descend');

    neigh(ii).index = sortedIndices(1:Sizeneigh);

end
end
