%myupdate updates an excell file with a new array given the file name, the
%old array, and the new variables (fuel name, fuel density, fuel burnrate,
%and fuel isp). It first error chekcs the data to make sure they are
%positive numbers and tries to find the name in the old array, if a
%matching name is not found, then it adds the new data to the end of the
%array.
%
%By:Jared Herron

function new_fuel_data=myupdate(file_name,fuel_data,fuel_name,fuel_density,fuel_burnrate,fuel_isp)
%<SM:PDF>
if isempty(char(fuel_name))||isempty(char(fuel_density))||isempty(char(fuel_burnrate))||isempty(char(fuel_isp))%if any text field is empty
    errordlg('All text field must be filled out.','Missing Input','modal');
    %<SM:BOP>
elseif isnan(str2double((char(fuel_density))))||isnan(str2double((char(fuel_burnrate))))||isnan(str2double((char(fuel_isp))))%if any number input has not a number
    errordlg('Density, Burnrate, and Specific Impulse must be numerical','Non-Number Input','modal');
    
elseif str2double(fuel_density)<=0||str2double(fuel_burnrate)<=0||str2double(fuel_isp)<=0%if any number input has a non positive number
    errordlg('Please enter positive numbers','Negitive Number Input','modal');
    
elseif sum(strcmpi(fuel_name,fuel_data(2:end,1)))%if everything before passed and it found a fuel with the same name
    %<SM:FOR>
    %<SM:NEST>
    for counter=2:size(fuel_data,1)%for all rows but the first
        %<SM:REF>
        %<SM:SEARCH>
        if strcmpi(fuel_name,fuel_data(counter,1))%if the name matches
            location=counter;%set location to the row it matched on
        end
    end
    fuel_data(location,:)=cellstr([fuel_name,fuel_density,fuel_burnrate,fuel_isp]);%replace old data with new inputs
    
else%if nothing hit
    fuel_data=[fuel_data;cellstr(fuel_name),fuel_density,fuel_burnrate,fuel_isp];%add the input as a new fuel
end

xlswrite(file_name,fuel_data);%write the new data to the excel file
[~,~,new_fuel_data]=xlsread(file_name);%read the new excel file (written and read for formating porpuses to keep everything as cells)
end