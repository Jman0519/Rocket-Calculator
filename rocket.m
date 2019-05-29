%{
Jared Herron
email: herronj4@my.erau.edu
date: April 25, 2019
EGR 115 - Section 9
Assignment: Final Project
Program Description: This program is a user interface data base which is
split into two main parts: fuel and rocket motors. In the fuel section, the
user can add fuels too the data base, change existing fuels in the data
base, and delete old fuel from the data base given that they are not being
used the calculate a rocket that is stored in the rocket section. In the
rocket section of the program, the user can calculate rockets based on
their dimensions, store rockets they have calculated, and delete rockets
from the data base. More documentation is provided in the accompanning text
documents and commented through out the code.

%The goal of this project is to make a program that is accurate enough to
model and display the proformance of multiple amature style rockets from
case bonded to baits grains and sugar fuel to APCB fuels to black powder
fuels. I plan on using this and know of many people who would share a need
for a very simple yet mildly accurate program for designing small amature
rockets.
Worked with: Raju Ramlall, Jack Birchler, Cody Richman
%}
% g=9.8066;
% %rocket paramater equations
% Isp=Ve/g;
% Thrust=mdot*Ve+(Pexhaust-Poutside)*nozzle_area;
% wdot=mdot*g;
% Isp=Thrust/wdot;
% Veq=Thrust/mdot;
% Veq=Ve+((Pexhaust-Poutside)/mdot)*nozzle_area;
% Specific_fuel_consumption=101972/Isp;
% mdot=propellent_mass/burntime;
% Thrust=Veq*mdot;
% burntime=Impulse/Thrust;
% rocket preformance equations
% All of my calculations have been based off of data from nasa's website
% such as this link (mostly used in calculatedim.m)
% https://www.grc.nasa.gov/www/k-12/airplane/specimp.html

clc%clear command window (no output should display to command window anyways)
clear%clear the worspace of variables
close all%close all figures (how this code communicates to the user)

f=figure('units','normalized','menubar','none','dockcontrols','off','windowstate','maximized');%the window that all of the controls are displayed in, open right away

%initial imports
[~,~,fuel_data]=xlsread('FuelData.xlsx');
[~,~,rocket_data]=xlsread('RocketList.xlsx');
rocket_vector={zeros(1,22)};%incase if they hit store before any rocket has been stored to this variable (will be explained further in document)
thrust_axes=axes('visible','off');%needs to be made so calculate button can delete them because it deletes old axes before making a new one (will be explained further in document)
pressure_axes=axes('visible','off');%same as above
Kn_axes=axes('visible','off');%same as above
%<SM:RANDGEN>
mynum=ceil(rand*20)/1000;%one random number, representing 1-20 mm, to base all dimensions off of (will be explained further in document)
%all random numbers generated at code startup are within common amature
%rocketry values

%main menu UI
%<SM:NEWFUN>
%all ui controls not disscuessed in class
question1=uicontrol(f,'style','text','fontsize',24,'units','normalized','position',[.0,.6,1,.1],'string','Would you like to look at fuels or rocket motors?');%main text on the opening menu
goto_fueltypes=uicontrol(f,'style','pushbutton','fontsize',24,'units','normalized','position',[.1,.5,.8,.1],'string','Fuels','callback','set(fueltypesui,''visible'',''on'');set(mainmenuui,''visible'',''off'');');%button that takes user to fuel types
goto_rocketcalc=uicontrol(f,'style','pushbutton','fontsize',24,'units','normalized','position',[.1,.38,.8,.1],'string','Rocker Motors','callback','set(mainmenuui,''visible'',''off'');set(rocketcalcui,''visible'',''on'');');%button that takes user to rocket calculator

%fuel types UI
fuel_type_inst=uicontrol(f,'fontsize',12,'visible','off','style','text','units','normalized','position',[.0,.95,1,.05],'string','IF YOU WOULD LIKE TO CHANGE A FUEL TYPE, SELECT IT AND EDIT THE TEXT BOXES.');%instructions/warnings
fuel_type_inst2=uicontrol(f,'fontsize',12,'visible','off','style','text','units','normalized','position',[.0,.93,1,.05],'string','IF YOU WOULD LIKE TO ADD A FUEL, TYPE A NEW NAME AND ENTER ITS VALUES');%same as above

fuel_name_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.88,.05,.02],'string','Name');
fuel_name=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.85,.05,.03]);

fuel_density_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.78,.05,.02],'string','Density (kg/m^3)');
fuel_density=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.75,.05,.03],'string',num2str(round(rand*2000)));

fuel_burnrate_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.68,.05,.02],'string','Burnrate (m/s)');
fuel_burnrate=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.65,.05,.03],'string',num2str(rand*.015));

fuel_isp_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.58,.05,.02],'string','Specific Impulse');
fuel_isp=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.55,.05,.03],'string',num2str(round(rand*120)+100));
%<SM:PDF_PARAM>
%<SM:PDF_RETURN>
%these are in the callbacks of add_update
add_update=uicontrol(f,'visible','off','string','Add/Update','style','pushbutton','units','normalized','position',[.875,.03,.1,.03],'callback','fuel_data=myupdate(''FuelData.xlsx'',fuel_data,get(fuel_name,''string''),get(fuel_density,''string''),get(fuel_burnrate,''string''),get(fuel_isp,''string''));set(popup_for_fuel_names,''string'',fuel_data(2:end,1));');%updates the fuel_data variable with either one line replaced or one new line representing an updated fuel or a new fuel respectivly
delete_button=uicontrol(f,'visible','off','string','Delete','style','pushbutton','units','normalized','position',[.875,0,.1,.03],'callback','set(popup_for_fuel_names,''value'',1);fuel_data=mydelete(''FuelData.xlsx'',fuel_data,get(fuel_name,''string''));set(popup_for_fuel_names,''string'',fuel_data(2:end,1));');%ruturns the same array or an array with one less row representing no fuel found or one deleted fuel type respectivly

%shared UI
popup_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.475,.93,.05,.02],'string','Select Fuel');
popup_for_fuel_names=uicontrol(f,'visible','off','style','popupmenu','units','normalized','position',[.475,.90,.05,.03],'string',fuel_data(2:end,1),'callback','set(fuel_density,''string'',fuel_data(get(popup_for_fuel_names,''value'')+1,2));set(fuel_burnrate,''string'',fuel_data(get(popup_for_fuel_names,''value'')+1,3));set(fuel_isp,''string'',fuel_data(get(popup_for_fuel_names,''value'')+1,4));set(fuel_name,''string'',fuel_data(get(popup_for_fuel_names,''value'')+1,1));');%the call back simply takes the data from the fuel data arrays and puts it into the text fields to show the user some data on the fuel

goback=uicontrol(f,'visible','off','style','pushbutton','units','normalized','position',[.875,.06,.1,.03],'string','Go Back','callback','set([fueltypesui,rocketcalcui],''visible'',''off'');set(mainmenuui,''visible'',''on'');');%turns off visible for the fuel section and rocket section (only one would ever be set to on but never sure which one is one) and turns the main menu ui visible on

%rocket calculator UI
rocketcalc_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.25,.95,.5,.05],'string','ALL NUMBERS IN SI UNITS (KILOGRAM METER SECOND)');%basic insturction for the rocket calc section

the_calculate_button=uicontrol(f,'visible','off','style','pushbutton','units','normalized','position',[.025,0,.1,.09],'string','Calculate Preformance','callback','delete([thrust_axes,pressure_axes,Kn_axes]);[thrust_axes,pressure_axes,Kn_axes,thrust_plot,pressure_plot,Kn_plot,rocket_vector]=calculatedim(get(rocket_name,''string''),fuel_data(get(popup_for_fuel_names,''value'')+1,1),fuel_data(get(popup_for_fuel_names,''value'')+1,2),fuel_data(get(popup_for_fuel_names,''value'')+1,3),fuel_data(get(popup_for_fuel_names,''value'')+1,4),get(core_diameter,''string''),get(grain_diameter,''string''),get(grain_length,''string''),get(grain_num,''string''),get(chamber_mass,''string''),get(nozzle_area,''string''),get(inhibited_ends,''value''));set(takeoff_thrust,''string'',rocket_vector(1,13));set(takeoff_TTW,''string'',rocket_vector(1,14));set(takeoff_pressure,''string'',sprintf(''%.1f'',cell2mat(rocket_vector(1,15))));set(thrust,''string'',rocket_vector(1,16));set(impluse,''string'',rocket_vector(1,17));set(fuel_mass,''string'',rocket_vector(1,18));set(burntime,''string'',rocket_vector(1,19));set(deltav,''string'',rocket_vector(1,20));set(end_pressure,''string'',sprintf(''%.1f'',cell2mat(rocket_vector(1,21))));set(end_thrust,''string'',rocket_vector(1,22));set(thrust_axes,''position'',[.15,.1,.2,.75]);set(pressure_axes,''position'',[.4,.1,.2,.75]);set(Kn_axes,''position'',[.65,.1,.2,.75]);rocketcalcui=[popup_for_rocket,popup_for_rocket_inst,delete_rocket,rocket_name_inst,rocket_name,store_rocket,thrust_axes,pressure_axes,Kn_axes,thrust_plot,pressure_plot,Kn_plot,end_thrust_inst,end_thrust,end_pressure_inst,end_pressure,deltav_inst,deltav,burntime_inst,burntime,fuel_mass_inst,fuel_mass,impluse_inst,impluse,thrust_inst,thrust,takeoff_pressure_inst,takeoff_pressure,takeoff_TTW_inst,takeoff_TTW,takeoff_thrust_inst,takeoff_thrust,nozzle_area_inst,nozzle_area,inhibited_ends_inst,inhibited_ends,chamber_mass_inst,chamber_mass,grain_num_inst,grain_num,grain_length_inst,grain_length,grain_diameter_inst,grain_diameter,popup_inst,popup_for_fuel_names,goback,the_calculate_button,core_diameter,rocketcalc_inst,core_diameter_inst];');%probably the hardest callback, simplys gathers data from all inputs and then rutrns the calculated data by callng calculatedim, finally it displays the calculed data in the disabled ui text fields (will be explained further in document)
store_rocket=uicontrol(f,'visible','off','style','pushbutton','units','normalized','position',[.875,0,.1,.03],'string','Store Rocket','callback','rocket_data=addrocket(rocket_vector);set(popup_for_rocket,''string'',rocket_data(2:end,1));');%calls the addrocket function and reutns a new rocket data array
delete_rocket=uicontrol(f,'visible','off','style','pushbutton','units','normalized','position',[.875,.03,.1,.03],'string','Delete Rocket','callback','rocket_data=deleterocket(rocket_data,get(rocket_name,''string''));set(popup_for_rocket,''string'',rocket_data(2:end,1));set(popup_for_rocket,''value'',1);');%calls deleterocket function which tries to find a rocket with that name in the array and delete it if possible, if not it displays error and makes no change

popup_for_rocket_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.225,.97,.05,.02],'string','Select Rocket');
popup_for_rocket=uicontrol(f,'visible','off','style','popupmenu','units','normalized','position',[.2,.94,.1,.03],'string',rocket_data(2:end,1),'callback','set(rocket_name,''string'',rocket_data(get(popup_for_rocket,''value'')+1,1));set(popup_for_fuel_names,''value'',find(strcmp(fuel_data(2:end,1),rocket_data(get(popup_for_rocket,''value'')+1,2))));set(core_diameter,''string'',rocket_data(get(popup_for_rocket,''value'')+1,6));set(grain_diameter,''string'',rocket_data(get(popup_for_rocket,''value'')+1,7));set(grain_length,''string'',rocket_data(get(popup_for_rocket,''value'')+1,8));set(grain_num,''string'',rocket_data(get(popup_for_rocket,''value'')+1,9));set(chamber_mass,''string'',rocket_data(get(popup_for_rocket,''value'')+1,10));set(nozzle_area,''string'',rocket_data(get(popup_for_rocket,''value'')+1,11));set(inhibited_ends,''value'',cell2mat(rocket_data(get(popup_for_rocket,''value'')+1,12)));evalin(''base'',get(the_calculate_button,''callback''));');%finds all data associated with that rocket, displays it in the ui text fields, then simulates the press of the_calculate_button so get the graphs and any new data that would be due to an update of its fuel properties. using evalin to simulate button press was found here https://www.mathworks.com/matlabcentral/answers/275495-press-button-automatically-click

rocket_name_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.075,.97,.05,.02],'string','Rocket Name');
rocket_name=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.94,.1,.03],'string','Random Rocket (RR)');

core_diameter_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.88,.05,.02],'string','Core Diameter');
%<SM:RANDUSE>
%these are on almost every string for uicontrols with type ;edit'
core_diameter=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.85,.05,.03],'string',num2str(mynum));

grain_diameter_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.78,.05,.02],'string','Grain Diameter');
grain_diameter=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.75,.05,.03],'string',num2str(mynum*((rand*3)+1)));

grain_length_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.68,.05,.02],'string','Grain Length');
grain_length=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.65,.05,.03],'string',num2str(mynum*(ceil(rand*2)-.5)));

grain_num_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.58,.05,.02],'string','Number of Grains');
grain_num=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.55,.05,.03],'string',num2str(ceil(rand*6)));

chamber_mass_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.48,.05,.02],'string','Chamber Mass');
chamber_mass=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.45,.05,.03],'string',num2str((rand*.09)+.01));

nozzle_area_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.05,.38,.05,.02],'string','Nozzle Area');
nozzle_area=uicontrol(f,'visible','off','style','edit','units','normalized','position',[.05,.35,.05,.03],'string',sprintf('%.8f',((mynum/2)^2)*pi));%sprintf needs to be used to keep it from using scientific notation

inhibited_ends_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.03,.28,.09,.02],'string','Check if Ends are Inhibited');
inhibited_ends=uicontrol(f,'visible','off','style','radiobutton','units','normalized','position',[.07,.25,.05,.03],'value',round(rand));

%Return Text Boxes

%these are set enable to off becuase I do not want the user to be inputting
%values here, this is only for the program to display to the user (will be
%explained further in document).

takeoff_thrust_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.88,.05,.02],'string','Takeoff Thrust');
takeoff_thrust=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.85,.05,.03]);

takeoff_TTW_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.8,.05,.02],'string','Takeoff TTW');
takeoff_TTW=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.77,.05,.03]);

takeoff_pressure_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.72,.05,.02],'string','Takeoff Pressure');
takeoff_pressure=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.69,.05,.03]);

thrust_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.64,.05,.02],'string','Average Thrust');
thrust=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.61,.05,.03]);

impluse_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.56,.05,.02],'string','Total Impluse');
impluse=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.53,.05,.03]);

fuel_mass_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.48,.05,.02],'string','Fuel Mass');
fuel_mass=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.45,.05,.03]);

burntime_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.40,.05,.02],'string','Burn Time');
burntime=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.37,.05,.03]);

deltav_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.32,.05,.02],'string','Delta V');
deltav=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.29,.05,.03]);

end_pressure_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.24,.05,.02],'string','End Pressure');
end_pressure=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.21,.05,.03]);

end_thrust_inst=uicontrol(f,'visible','off','style','text','units','normalized','position',[.9,.16,.05,.02],'string','End Thrust');
end_thrust=uicontrol(f,'enable','off','visible','off','style','edit','units','normalized','position',[.9,.13,.05,.03]);

%arrays for turning menus on and off
mainmenuui=[question1,goto_fueltypes,goto_rocketcalc];%this is an array of all ui controls in the main menu which makes is easier to set visibile on and off
fueltypesui=[popup_inst,fuel_name_inst,fuel_density_inst,fuel_burnrate_inst,fuel_isp_inst,delete_button,add_update,fuel_type_inst,fuel_type_inst2,fuel_name_inst,fuel_name,fuel_density,fuel_burnrate,popup_for_fuel_names,fuel_isp,goback];%same as above but ui control for the fuel section
rocketcalcui=[delete_rocket,popup_for_rocket_inst,popup_for_rocket,rocket_name_inst,rocket_name,store_rocket,end_thrust_inst,end_thrust,end_pressure_inst,end_pressure,deltav_inst,deltav,burntime_inst,burntime,fuel_mass_inst,fuel_mass,impluse_inst,impluse,thrust_inst,thrust,takeoff_pressure_inst,takeoff_pressure,takeoff_TTW_inst,takeoff_TTW,takeoff_thrust_inst,takeoff_thrust,nozzle_area_inst,nozzle_area,inhibited_ends_inst,inhibited_ends,chamber_mass_inst,chamber_mass,grain_num_inst,grain_num,grain_length_inst,grain_length,grain_diameter_inst,grain_diameter,popup_inst,popup_for_fuel_names,goback,the_calculate_button,core_diameter,rocketcalc_inst,core_diameter_inst];%same as above but ui control for the rocket calculator section