function [xx] = Mappingg(x)

xx = tanh(x);
[~,c] = size(xx);

for i=1:c
    if rand<xx(i)
        xx(i) = 1;
    else
        xx(i) = 0;
    end
end
end

% % function [xx] = Mappingg(x)
% %     probability = (tanh(x) + 1) / 2;
% %    
% %     xx = rand(size(x)) <= probability;
% % end
