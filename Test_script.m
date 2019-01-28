
% device number (0 if only one PM100 is connected to the PC
device=0;
%
pulse_shape=1;

% pulse onest timing (relative to previsou pulse)
pulse_time=[0 200 200];

% intensity of each pulse
intensity=[100 80 100];

% Diplay out output of functions in MATLAB command window
display=1;

% COM port number of your USB 
port=2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    
    PM100=PM100_Class;
    
    % create COM port object
    obj=PM100.create_COM_object(display,port);
    
    % reset stimulator interface
    PM100.reset(obj);
    
    % get ID
    ID=PM100.get_ID(obj,device,display);
    
    % get status
    STATUS=PM100.get_status(obj,device,display);
    
    % get coil temperature
    [CT,coil_temp]=PM100.get_coil_temperature(obj,device,display);
    
    % activate stimulator
    PM100.activate(obj,device)
    
    % setup stimulation protocol
    PM100.setup_protocol(obj,device,pulse_shape,intensity,pulse_time,1)
    
    
    for ii=1:5
        
        % start stimulation (run protocol)
        PM100.start_stimulation(obj,device)
        
        pause(1)
        
    end
    
    % deactivate stimulator
    PM100.deactivate(obj,device)
    
    s=instrfind;
    fclose(s) % close serial port
    delete(s) % delete serial port object
    clear obj % clear PM100 obejct
    
catch
    
    s=instrfind;
    fclose(s)
    delete(s)
    clear all
    
end