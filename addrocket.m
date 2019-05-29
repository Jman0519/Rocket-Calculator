%addrocket takes an input of a single rocket data vector and error checks
%the values to make sure that they are proper inputs and not empty or pre
%existing. If everythign passes it writes to the excel file where the
%rocket data is stored and returns a new array of the rocket data.
%
%By:Jared Herron
function rocket_data=addrocket(rocket_vector)

[~,~,rocket_data]=xlsread('RocketList.xlsx');
if size(rocket_vector,2)==1%user has not hit calculate yet
    errordlg('Please calculate a rocket before hitting store.','No rocket data to store','modal');
elseif any(strcmpi(rocket_vector(1,1),rocket_data(2:end,1)))%if the rocket name has already been taken
            errordlg('Sorry but that name is already taken. Please rename this rocket or delete that name from the database.','Name Taken','modal');
elseif isempty(rocket_vector{1,1})%if the rocket vector is empty
    errordlg('Make sure all fields are filled out and correct','Improper Input','modal')
else%all error chekcs passed
    rocket_data=[rocket_data;rocket_vector];%rocket data gets the new rocket added on to the end
    xlswrite('RocketList.xlsx',rocket_data);
    [~,~,rocket_data]=xlsread('RocketList.xlsx');
end