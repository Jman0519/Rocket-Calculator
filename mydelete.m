%mydelete take an input of the file to delete the data from, the old data,
%and the name of the data you want to delete. It first makes sure that the
%fuel is not being used by any of the rockets, then it takes the fuel name
%and tries to find it in the old data array, if it finds it it deletes it,
%and replaces the old excel file with a new one with the requested data now
%gone. If no matching name is found it returnes an error saying no matching
%name is found.
%
%By:Jared Herron
function fuel_data=mydelete(file_name,fuel_data,fuel_name)
%<SM:READ>
[~,~,rocket_data]=xlsread('RocketList.xlsx');%gets the rocket data
if size(fuel_data,1)==2%if there is only one fuel left
    errordlg('There must always be one fuel type. Please change the fuel instead of deleting it.','No Fuel Types','modal');%(will be explained further in document)
elseif any(strcmp(fuel_name,rocket_data(2:end,2)))%if the fuel is being used by a rocket
    errordlg('You cannot delete a fuel that is being used by a rocket.','Rockets Lack Fuel Data','modal')%(will be explained further in document)
elseif any(strcmpi(fuel_name,fuel_data(2:end,1)))==0
    %<SM:STRING>
    tell_user=sprintf('Fuel Type with the name %s not found.',char(fuel_name));
    errordlg(tell_user,'Fuel Name Error','modal');
else%error checks have passed
    running_total=2;%start on the second row
    %<SM:WHILE>
    while any(strcmpi(fuel_name,fuel_data(2:end,1)))%if the name matches
        if strcmpi(fuel_name,fuel_data(running_total,1))%if the name is found on this row/itteretion
            %<SM:DIM>
            fuel_data(running_total,:)=[];%delete that row
            delete(file_name);%remove old excel file (will not remove rows below the array being written to it)
            %<SM:WRITE>
            xlswrite(file_name,fuel_data);%write the updated array to excel file
            [~,~,fuel_data]=xlsread(file_name);%reread new data for formatting (keep everything as a uniform cell)
        end
        running_total=running_total+1;%move to the next row
    end
    
end
end