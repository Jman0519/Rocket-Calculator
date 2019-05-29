%calculatedim calculates the preformance of a rocket moter in SI units given
%properties of the fuel (density, burnrate, and isp), as well as the
%dimensions of the rocket motor (core diameter, grain diameter, grain
%lenght, the number of grains, the mass of the combustion chamber, the
%cross-sectional area of the nozzle throat, and weather the top and bottom
%of the grains are inhibited or not (1 for yes 0 for no))
%
%It then returns the graphs for thrust, pressure and Kn
%(burning area to nozzle area), as well as a vector representing every
%paramater of the rocket: rocket name, fuel name, fuel density, fuel
%burntate, fuel isp, core diameter, grain diameter, grain length, number of
%cores, combustion chamber mass, nozzle area, wether it is inhibited,
%takeoff thrust, takeoff thrust to weight, takeoff pressure, average
%thrust, total impluse, fuel mass, burntime, deltav, end pressure, and end
%thrust)
%
%By:Jared Herron
function [thrust_axes,pressure_axes,Kn_axes,thrust_plot,pressure_plot,Kn_plot,rocket_vector]=calculatedim(rocket_name,fuel_name,fuel_density,fuel_burnrate,fuel_isp,core_diameter,grain_diameter,grain_length,num_grains,case_mass,nozzle_area,inhibited)

%incase an error check hits, it still needs to return these (will be explained further in document)
rocket_vector=cell(1,22);
%thrust plot
thrust_axes=axes;
thrust_plot=plot(0,0);
xlim([0,1])
ylim([0,1])
title('Thrust Vs. Time')
xlabel('Time (S)')
ylabel('Thrust (N)')

%pressure plot
pressure_axes=axes;
pressure_plot=plot(0,0);
xlim([0,1])
ylim([0,1])
title('Pressure Vs. Time')
xlabel('Time (S)')
ylabel('Pressure (Pa)')

%Kn plot
Kn_axes=axes;
Kn_plot=plot(0,0);
xlim([0,1])
ylim([0,1])
title('Kn Vs. Time')
xlabel('Time (S)')
ylabel('Kn (m^2/m^2)')

if isempty(core_diameter)||isempty(grain_diameter)||isempty(grain_length)||isempty(num_grains)||isempty(case_mass)||isempty(nozzle_area)%if any of the inputs are empty
    errordlg('All text fields must be filled out','Empty Text Field','modal');
elseif ~isreal(str2double(core_diameter))||~isreal(str2double(grain_diameter))||~isreal(str2double(grain_length))||~isreal(str2double(num_grains))||~isreal(str2double(case_mass))||~isreal(str2double(nozzle_area))||isnan(str2double(core_diameter))||isnan(str2double(grain_diameter))||isnan(str2double(grain_length))||isnan(str2double(num_grains))||isnan(str2double(case_mass))||isnan(str2double(nozzle_area))%if any of the inputs are not real or not a number
    errordlg('Please only put numbers in the input fields','Non-Number Input','modal')
elseif str2double(core_diameter)<=0||str2double(num_grains)<=0||str2double(case_mass)<=0||str2double(nozzle_area)<=0%check for special cases (will be explained further in document)
    errordlg('Values must be positive','Non-Positive Values','modal');
elseif str2double(grain_diameter)<=str2double(core_diameter)%special cases
    errordlg('Grain diameter must be bigger than core diameter.','Negitive Volume','modal');
elseif mod(str2double(num_grains),1)~=0%checks for whole number
    errordlg('Number of grains must be a whole number','Non-Integer','modal');
else%no error was hit then do this code
    %convert to doubles and error check
    fuel_density=cell2mat(fuel_density);%these three were already error checked by myupdate
    fuel_burnrate=cell2mat(fuel_burnrate);
    fuel_isp=cell2mat(fuel_isp);
    
    delete(thrust_axes)%these can be removed since they will get actual plots instead of being empty incase an error hit (will be explained further in document)
    delete(pressure_axes)
    delete(Kn_axes)
    
    core_diameter=str2double(core_diameter);%convert these to doubles to do calcualtions now that they've been error checked
    grain_diameter=str2double(grain_diameter);
    grain_length=str2double(grain_length);
    num_grains=str2double(num_grains);
    case_mass=str2double(case_mass);
    nozzle_area=str2double(nozzle_area);
    
    %average data
    grain_mass=fuel_density*pi*(((grain_diameter/2)^2)-(((core_diameter/2)^2)))*grain_length;
    fuel_mass=grain_mass*num_grains;
    motor_mass=fuel_mass+case_mass;
    %<SM:IF>
    %<SM:ROP>
    if grain_diameter-core_diameter>grain_length&&inhibited==0%if the grain_length limits burn time(will be explained further in document)
        burntime=(grain_length/2)/fuel_burnrate;
    else
        burntime=((grain_diameter/2)-(core_diameter/2))/fuel_burnrate;%if the web limits burn time(will be explained further in document)
    end
    mdot=fuel_mass/burntime;
    thrust=fuel_isp*9.8066*mdot;%averaged for the whole burntime, later calculated for start and end
    impluse=fuel_isp*fuel_mass*9.8066;
    veq=thrust/mdot;
    ve=9.8066*mdot;
    chamber_pressure=((thrust-(mdot*ve))/nozzle_area)+101000;
    deltav=veq*log(motor_mass/case_mass);%not a good indication of the motor unless the motor case is also assumed to be the payload (a large mass not a very small mass)
    
    %aprox data
    
    %Kn is a ratio of burning surface area to nozzle area, used to find scaling
    %factors for pressure and thrust.
    if inhibited==1%if tops and bottoms dont burn
        Kn=@(the_time) (pi.*(core_diameter+(fuel_burnrate.*the_time)).*grain_length.*num_grains./nozzle_area);%pi * diamater with respect to time (area of core with respect to time) 
        mdot=@(the_time) ((fuel_density*grain_length*pi*((core_diameter*fuel_burnrate)+(2*(fuel_burnrate^2)*the_time)))*num_grains);
    else%if the ends do burn
        Kn=@(the_time) (((pi.*(core_diameter+(fuel_burnrate.*the_time)).*num_grains.*(grain_length-(2.*(fuel_burnrate.*the_time))))+(2.*num_grains.*(pi.*((core_diameter+(fuel_burnrate.*the_time))./2).^2)))./nozzle_area);%pi * time diamater with respect to time * length with respect to time + pi * radius with respect to time^2 (area of core + area of tops and bottom of grains)
        mdot=@(the_time) ((-fuel_density*pi*( (-core_diameter*fuel_burnrate*grain_length) - (2*grain_length*(fuel_burnrate^2)*the_time) - ((grain_diameter^2)*fuel_burnrate) + (fuel_burnrate*(core_diameter^2)*.5) + (4*core_diameter*(fuel_burnrate^2)*the_time) + (6*(fuel_burnrate^3)*(the_time.^2))))*num_grains);
    end
    pressure=@(the_time) ((((fuel_isp*9.8066*mdot(the_time))-(9.8066*((mdot(the_time)).^2)))/(nozzle_area))+101000);%change in burn profile is accounted for with mdot, therefore pressure does not need to be defined with respect to inhibited
    
    the_time=0:.001:burntime;
    %thrust plot
    thrust_axes=axes;
    thrust_plot=plot(the_time,fuel_isp*9.8066*mdot(the_time));
    xlim([0,burntime])
    ylim([0,max(fuel_isp*9.8066*mdot(the_time))*1.1])
    title('Thrust Vs. Time')
    xlabel('Time (s)')
    ylabel('Thrust (N)')
    
    %pressure plot
    pressure_axes=axes;
    pressure_plot=plot(the_time,pressure(the_time));
    xlim([0,burntime])
    ylim([0,max((pressure(the_time)))*1.1])
    title('Pressure Vs. Time')
    xlabel('Time (s)')
    ylabel('Pressure (Pa)')
    
    %Kn plot
    Kn_axes=axes;
    Kn_plot=plot(the_time,Kn(the_time));
    xlim([0,burntime])
    ylim([0,max(Kn(the_time))*1.1])
    title('Kn Vs. Time')
    xlabel('Time (s)')
    ylabel('Kn (m^2/m^2)')
    
    thrust=mean(fuel_isp*9.8066*mdot(the_time));
    impluse=sum(fuel_isp*9.8066*mdot(the_time)*.001);
    deltav=fuel_isp*9.8066*log(motor_mass/case_mass);
    takeoff_thrust=fuel_isp*9.8066*mdot(0);
    takeoff_TTW=takeoff_thrust/(motor_mass*9.8066);%will be smaller (but should be greater than 4 or 5) because most of mass is fuel
    end_thrust=fuel_isp*9.8066*mdot(burntime);
    %end_TTW=end_thrust/(case_mass*9.8066);%will be massive cus only motor case is weight
    takeoff_pressure=pressure(0);
    end_pressure=pressure(burntime);
    
    %making rocket vector
    rocket_vector=[rocket_name,fuel_name,fuel_density,fuel_burnrate,fuel_isp,core_diameter,grain_diameter,grain_length,num_grains,case_mass,nozzle_area,inhibited,takeoff_thrust,takeoff_TTW,takeoff_pressure,thrust,impluse,fuel_mass,burntime,deltav,end_pressure,end_thrust];
    
    %testing and verfication
    
    %thrust_values=(thrust*Kn(the_time)/Kn(0))-thrust_correction;
    %remans=thrust_values*the_time(1,2);
    %test_impluse=sum(remans)
    
end