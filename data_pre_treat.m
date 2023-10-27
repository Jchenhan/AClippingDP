%read as a table, column names are Var1, Var2 ...
data = readtable('diabetes.txt', 'Delimiter', ' ', 'ReadVariableNames', false);
%remove the missing value
data = rmmissing(data);
varNames = data.Properties.VariableNames;
%data1 is the features
for i = 2:numel(varNames)
    temp = strrep(string(data.(varNames{i})),string((i-1))+':','');
    temp = str2double(temp);
    if i == 2
        X = temp;
    else
        X = [X, temp];
    end
end
%data_y is the lables
y = data.Var1;
%reconstruct the data
%data = struct('data_x', data1, 'data_y', data1_y);
%data = [data1, data_y]
%make mat file
save('diabetes.mat', 'X','y');
