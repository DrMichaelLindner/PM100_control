% This Class of functions is designed to control the TMS device Powermag
% 100 via Matlab. 
%
% USAGE
% Setup the TMS device Powermag 100 for external use:
% 1. Connect the Powermag 100 via the USB PC interface to the stimulation
%       computer
% 2. Boot stimulation computer and start Matlab
% 3. Switch on the Powermag 100 TMS device (button on the back)
% 4. Switch to "External" (button on the front panel - bottom left)
% 5. Adjust Frequency to "max" (button on the front panel - top left)
%
% To make the functions available in Matlab, add the path of the 
% PM100_Class.m file (e.g. addpath(<path>) and then simply load the class 
% into an object (from a script or from then command line) like:
%       MyObject=PM100_Class.m;
%
% Now, you can call the functions of the object via:
%       output = MyObject.FunctionName(input);
%
% For the functions you need to specify the following inputs
%       device      - device numbers. If you have only on PM100 the device
%                       number is normally 0.
%       pulse_shape - 0=half wave or 1=full wave
%       pulse_time  - Vector of onsets of pulses. First entry 0 when the
%                       pulses should start immediatly. The following
%                       entries are the distance in time to the previous 
%                       pulse.
%                       (e.g. [0 200 200]) will give you three pulses every
%                       200 ms.
%       intensity   - Either a vector with the same length of pulse time
%                       specifying the intensity for each pulse, or a
%                       scalar if all pulses should have the same
%                       intensity.
%       display     - some of the functions can produce an output to the
%                       command window. By default display is switched off.
%                       If you want to see the output, specifiy display=1;
%       port        - only needed if teh USB is not COM3 in your system
%                       (see function create_COM_object)
%
%
% The following functions are available in the PM100_Class:
%
%  example              - displays a working example script (setup for the
%                          configuration in G11 in the CINN). You also can  
%                          save the script to run it. For this example
%                          function you not need to be connected to the TMS
%                          device.
%                          e.g.
%                          MyObject.example
%  create_COM_object    - Setting up a COM port for the USB commaction
%                          to the PM 100 device (default=COM3. If it is
%                          not COM3 in your system, then specify the
%                          input port with the appropriate number (e.g. 1
%                          for COM1)
%                          e.g.
%                          COM=MyObject.create_COM_object(display,port)
%  reset                - reset the TMS device (Important e.g. when
%                          commands were send in wrong order)
%                          e.g.
%                          MyObject.reset(MyObject)
%  get_id               - get the firmware ID of the PM100 device
%                          e.g.
%                          ID=MyObject.get_ID(COM,device,display)
%  get_status           - get the status of the PM100 device. See in manual
%                           for the meanings of the codes.
%                           e.g.
%                           STATUS=MyObject.get_status(COM,device,display)
%  get_coil_temperature - get the coil temprature
%                          e.g.
%                      [CT,coil_temp]=MyObject.get_coil_temperature(COM,...
%                          device,display)
%  get_infos            - get ID, status and coil temperature together in
%                          one go
%                          e.g.
%                       [ID,STATUS,CT,coil_temp]=MyObject.get_infos(COM,...
%                          device,display)
%  activate             - activate the TMS device to setup and run
%                          protocols
%                          e.g.
%                          MyObject.activate(COM,device)
%  setup_protocoll      - setup a stimulation protocol depending on the
%                          values in pulse_time and intensity
%                          e.g.
%                           setup_protocoll(COM,device,pulse_shape,...
%                               intensity,pulse_time,display);
%  start_stimulation    - start the protocol
%                          e.g.
%                          MyObject.start_stimulation(COM,device)
%  stop_stimulation     - stop a running protocol
%                          e.g.
%                          MyObject.stop_stimulation(COM,device)
%                          e.g.
%  deactivate           - deactivate the TMS device
%                          e.g.
%                          MyObject.deactivate(COM,device)
%
% Some of the functions needs to be in the correct order in relation to
% each other. For more information use the function MyObject.example to get
% a working example script (setup for the configuration in G11 in the
% CINN).
%
% TIP: If you set up and test new protcols and you produced an error or
% something is not working as expected, then at least send a reset and 
% empty the USB buffer (flushinput(COM) - use your COM object that you
% specified as output of the function MyObject.create_COM_object!) before 
% you try it again. But most of the time it is better to close and restart
% Matlab before trying it again!
%
% LICENSE
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License (GPLv3) as published
% by the Free Software Foundation;
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY;
%
% AUTHOR
% Version 1.0 by Michael Lindner m.lindner@reading.ac.uk
% University of Reading, 2018
% School of PSychology and Clinical Language Sciences
% Center for Integrative Neuroscience and Neurodynamics
%


classdef PM100_Class
    methods (Static)
        
        function obj=create_COM_object(varargin)
            
            % check input
            if nargin<1
                d=0;
                port=3;
            elseif nargin<2
                d=varargin{1};
                port=3;
            else
                d=varargin{1};
                port=varargin{2};
            end
            
            % close COM port if still open
            try %#ok<*TRYNC>
                fclose(obj); %#ok<*NODEF>
            end
            
            %create COM object
            obj=serial(['COM',num2str(port)]);
            % set COM parameters
            obj.Baudrate=115200;
            obj.DataBits=8;
            obj.StopBits=1;
            obj.Parity='no';
            obj.Terminator={'LF' 'CR'};
            
            % display COM parameters in command window
            if d==1
                instrfind('Type', 'serial', 'Port', ['COM',num2str(port)], 'Tag', '')
            end
            
            % empty buffer
            flushinput(obj)
            
            % open COM port
            fopen(obj);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function ID=get_ID(obj,device,varargin)
            
            % check input
            if nargin<1
                d=0;
            else
                d=varargin{1};
            end
            
            % empty buffer
            flushinput(obj)
            % send request
            fprintf(obj, ['MS',num2str(device),' ID', char(13)]);
            % id=fscanf(obj);
            id=fscanf(obj,[char(13), '%s%s%f%f',char(10) ] ); %#ok<*CHARTEN>
            % cut feedback
            ID=[char(id(1:2))',' ',char(id(3:5))', ' ', num2str(id(6)),' ', num2str(id(6))];
            
            % display ID in command window
            if d==1
                disp(ID)
            end
            
            % empty buffer
            flushinput(obj)
            pause(1)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [CT,coil_temp]=get_coil_temperature(obj,device,varargin)
            
            % check input
            if nargin<3
                d=0;
            else
                d=varargin{1};
            end
            
            % empty buffer
            flushinput(obj)
            % send request
            fprintf(obj, ['MS',num2str(device),' GT',char(13)]) ;
            % get feedback as one string
            ct=fscanf(obj,[char(13), '%s',char(10) ] );
            % get coil temperature in C
            coil_temp=str2num(ct(6:end)) * 50 / 255; %#ok<*ST2NM>
            % cut feedback
            CT=[ct(1:2),' ',ct(3:5),' ',ct(6:end),' --> ',num2str(coil_temp), char(176),'C' ];
            
            % display ID in command window
            if d==1
                disp(CT)
            end
            
            % empty buffer
            flushinput(obj)
            pause(1)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function STATUS=get_status(obj,device,varargin)
            
            % check input
            if nargin<3
                d=0;
            else
                d=varargin{1};
            end
            
            % empty buffer
            flushinput(obj)
            % send request
            fprintf(obj, ['MS',num2str(device),' GS' char(13)])   ;
            % get feedback as one string
            status=fscanf(obj,[char(13), '%s',char(10) ] );
            % cut feedback
            STATUS=[ status(1:2),' ',status(3:5),' ',status(6),' ',status(7:8),' ',status(9:10),' ',status(11:end)];
            
            % display ID in command window
            if d==1
                disp(STATUS)
            end
            
            % empty buffer
            flushinput(obj)
            
            pause(1)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [ID,STATUS,CT,coil_temp]=get_infos(obj,device,varargin)
            
            % check input
            if nargin<3
                d=0;
            else
                d=varargin{1};
            end
            
            % empty buffer
            flushinput(obj)
            % send request
            fprintf(obj, ['MS',num2str(device),' ID', char(13)]);
            % id=fscanf(obj);
            id=fscanf(obj,[char(13), '%s%s%f%f',char(10) ] );
            % cut feedback
            ID=[char(id(1:2))',' ',char(id(3:5))', ' ', num2str(id(6)),' ', num2str(id(6))];
            % display ID in command window
            if d==1
                disp(ID)
            end
            pause(1)
            
            % empty buffer
            flushinput(obj)
            % send request
            fprintf(obj, ['MS',num2str(device),' GS' char(13)])   ;
            % get feedback as one string
            status=fscanf(obj,[char(13), '%s',char(10) ] );
            % cut feedback
            STATUS=[ status(1:2),' ',status(3:5),' ',status(6),' ',status(7:8),' ',status(9:10),' ',status(11:end)];
            % display ID in command window
            if d==1
                disp(STATUS)
            end
            pause(1)
            
            % empty buffer
            flushinput(obj)
            % send request
            fprintf(obj, ['MS',num2str(device),' GT',char(13)]) ;
            % get feedback as one string
            ct=fscanf(obj,[char(13), '%s',char(10) ] );
            % get coil temperature in C
            coil_temp=str2num(ct(6:end)) * 50 / 255;
            % cut feedback
            CT=[ct(1:2),' ',ct(3:5),' ',ct(6:end),' --> ',num2str(coil_temp), char(176),'C' ];
            % display ID in command window
            if d==1
                disp(CT)
            end
            pause(1)
            
            % empty buffer
            flushinput(obj)
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setup_protocoll(obj,device,pulse_shape,intensity,pulse_time,varargin)
            
            % check input
            if length(intensity)==1
                % if intensity is a a scalar create a vector of same length as pulse_time
                intensity=repmat(intensity,size(pulse_time));
            elseif length(intensity)~=length(pulse_time)
                errordlg('Intensity and pulse_time vector must have the same length. (Or intensity must be a scalar if all pulses should have the same intensity)','Input Error')
            end
            if nargin<6
                d=0;
            else
                d=varargin{1};
            end
            
            
            
            fprintf(obj, ['MS',num2str(device),' ST 1']);     % start Create and transfer script
            pause(0.1)
            % display protocol in command window
            if d==1
                fprintf('\nPROTOCOL:')
            end
            
            for ii=1:length(pulse_time)
                % add zeros intensity as less than 3 digits
                IN=num2str(intensity(ii));
                for nn=1:3-length(IN)
                    IN=['0',IN]; %#ok<AGROW>
                end
                
                % add zeros to pulse_time if pulse_time in microsec has less than 16 digits
                TI=num2str(pulse_time(ii));
                for nn=1:16-length(TI)
                    TI=['0',TI]; %#ok<AGROW>
                end
                
                % create command string without checksum
                x=[num2str(device),' ',num2str(pulse_shape),' ',IN,' ',TI,' '];
                
                % calculate checksum
                hs=dec2hex(sum(double(x)));
                CS=num2str(hs(end-1:end));
                
                % add checksum to command
                COMMAND=[x,CS];
                
                % send command
                fprintf(obj,COMMAND);
                
                % display protocol in command window
                if d==1
                    fprintf(['\n',COMMAND])
                end
                pause(0.1)
            end
            
            fprintf(obj, ['MS',num2str(device),' ST 0']);     % Stop Creating script
            pause(0.1)
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function reset(obj)
            fprintf(obj, char(27));
            pause(3) % wait for 3 seconds, until stimulator is ready again
        end
        
        function activate(obj,device)
            fprintf(obj, ['MS',num2str(device),' SE 1']);     % Activate stimulator
        end
        
        function start_stimulation(obj,device)
            fprintf(obj, ['MS',num2str(device),' RS 1']);     % Start stimulation
        end
        
        function stop_stimulation(obj,device)
            fprintf(obj, ['MS',num2str(device),' RS 0']);     % Stop stimulation
        end
        
        function deactivate(obj,device)
            fprintf(obj, ['MS',num2str(device),' SE 0']);     % Deactivate stimulator
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function example

            example_text={'% Example script for running a pulse protocol on the',...
                '% PM100 TMS device via Matlab.','','device=0;','pulse_shape=1;','',...
                'pulse_time=[0 1000 200 200 800 800 200 200 200 200 200 200];',...
                'intensity=[100 80 60 100 60 0 40 60 40 60 40 30];','',...
                'display=1;','','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
                '','PM100=PM100_Class;','','% create COM port object','obj=PM100.create_COM_object(display);',...
                '','% reset stimulator interface','PM100.reset(obj);','','% get ID',...
                'ID=PM100.get_ID(obj,device,display);','','% get status','STATUS=PM100.get_status(obj,device,display);','',...
                '% get coil temperature','[CT,coil_temp]=PM100.get_coil_temperature(obj,device,display);','',...
                '% activate stimulator','PM100.activate(obj,device)','','% setup stimulation protocol',...
                'PM100.setup_protocoll(obj,device,pulse_shape,intensity,pulse_time,1)','',...
                '% start stimulation (run protocol)','PM100.start_stimulation(obj,device)','',...
                'pause(6)','','% deactivate stimulator','PM100.deactivate(obj,device)','',...
                '% Do you know the rythm? ;)','','% Version 1.01 by Michael Lindner ','% University of Reading, 2015',...
                '% Center for Integratgive Neuroscience and Neurodynamics',...
                '% https://www.reading.ac.uk/cinn/cinn-home.aspx'};
            
            f=figure('menu','none','toolbar','none','name',...
                'Example script','NumberTitle','Off');
            hPan = uipanel(f,'Units','normalized');
            uicontrol(hPan, 'Style','listbox', ...
            'HorizontalAlignment','left', ...
            'Units','normalized', 'Position',[0 .2 1 .8], ...
            'String',example_text);

            
            btn=uicontrol('Style','pushbutton','String','Save script',...
                'position',[10 10 200 20],...
                'Callback',{@save_script,example_text}); %#ok<NASGU>
                
            function save_script(hObject,callbackdata,x) %#ok<INUSD>
                fid=fopen('example_script.m','w');
                formatspec='%s\n';
                for ii=1:length(example_text)
                    fprintf(fid,formatspec,example_text{:,ii});
                end
                fclose(fid);
                edit example_script;
            end
        end
        
        
    end
end
