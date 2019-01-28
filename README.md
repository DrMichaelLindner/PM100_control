# PM100 control MATLAB class
PM100_Class.m is a class of functions for Matlab designed to control the TMS device Powermag 100 via Matlab. 

## *Usage*

Setup the TMS device Powermag 100 for external use:


1. Connect the Powermag 100 via the USB PC interface to the stimulation
      computer
2. Boot stimulation computer and start Matlab
3. Switch on the Powermag 100 TMS device (button on the back)
4. Switch to "External" (button on the front panel - bottom left)
5. Adjust Frequency to "max" (button on the front panel - top left)


To make the functions available in Matlab, add the path of the 
PM100_Class.m file (e.g. addpath(<path>) and then simply load the class 
into an object (from a script or from then command line) like
'''
MyObject=PM100_Class.m;
'''

      
Now, you can call the functions of the object via:
'''
output = MyObject.FunctionName(input);
'''

      
## *Input*      
For the functions you need to specify the following inputs


### device 
device numbers. If you have only on PM100 the device number is normally 0.

### pulse_shape 
0=half wave or 1=full wave

### pulse_time  
Vector of onsets of pulses. First entry 0 when the pulses should start 
immediately. The following entries are the distance in time to the 
previous pulse. (e.g. [0 200 200]) will give you three pulses every 200 ms.

### intensity   
Either a vector with the same length of pulse time specifying the intensity 
for each pulse, or a scalar if all pulses should have the same intensity.

### display     
some of the functions can produce an output in the command window. By 
default display is switched off. If you want to see the output, specify 
'display=1'; 

###port        
only needed if the USB is not COM3 in your system  (see function create_COM_object)


## *Class functions*
The following functions are available in the PM100_Class:


### example          
displays a working example script (setup for the configuration in G11 in 
the CINN). You also can save the script to run it. For this example function 
you not need to be connected to the TMS device. e.g. 
'''
MyObject.example
'''

### create_COM_object
Setting up a COM port for the USB connection to the PM 100 device (default=COM3.
If it is not COM3 in your system, then specify the input port with the 
appropriate number (e.g. 1 for COM1). e.g.
'''
COM=MyObject.create_COM_object(display,port)
'''

### reset
reset the TMS device (Important e.g. when commands were send in wrong order)
e.g. 
'''
MyObject.reset(MyObject)
'''
after the reset you need to use the function get_ID to be able to send pulses 
(see below for further descriptions).

### get_id               
get the firmware ID of the PM100 device e.g. 
'''
ID=MyObject.get_ID(COM,device,display)
'''
This function also switches the status of the PC interface to active.

### get_status           
get the status of the PM100 device. See in manual for the meanings of the codes.
e.g. 
'''
STATUS=MyObject.get_status(COM,device,display)
'''

### get_coil_temperature
get the coil temprature e.g. 
'''
[CT,coil_temp]=MyObject.get_coil_temperature(COM,device,display)
'''

### get_infos            
get ID, status and coil temperature together in one go e.g.
'''
[ID,STATUS,CT,coil_temp]=MyObject.get_infos(COM,device,display)
'''

### activate
activate the TMS device to setup and run protocols e.g.
'''
MyObject.activate(COM,device)
'''

### setup_protocol       
setup a stimulation protocol depending on the values in pulse_time 
and intensity e.g.
'''
setup_protocol(COM,device,pulse_shape,intensity,pulse_time,display);
'''

### start_stimulation    
start the stimulation protocol e.g.
'''
MyObject.start_stimulation(COM,device)
'''

### stop_stimulation
stop a running protocol e.g.
'''
MyObject.stop_stimulation(COM,device)
'''

### deactivate           
deactivate the TMS device e.g.
'''
MyObject.deactivate(COM,device)
'''


Some of the functions needs to be in the correct order (in relation to
each other.) 
VERY IMPORTANT: After creating the COM object using the function 
create_COM_object, you should send a reset and afterwards a get_id!!!! 
If you do not send a get_ID the pulses where not send to the TMS device. 
You will hear a gentle clicking from the TMS device, when the pulses 
should occur, but they will have no intensity!. At the beginning and 
after each reset you need to send a get_ID! Check the PC interface: After
sending a reset the green status LED of the PC interface switches off. 
If the LED is off, the triggers were not sent. After sending a get_ID the
status of the PC interface is switched to active and the LED is green.
Use the function MyObject.example to get a working example script 
(setup for the configuration in G11 in the CINN).

TIP: If you set up and test new protocols and you produced an error or
something is not working as expected, then at least send a reset and 
empty the USB buffer (flushinput(COM) - use your COM object that you
specified as output of the function MyObject.create_COM_object!) before 
you try it again. But most of the time it is better to close and restart
Matlab before trying it again!


## *Install*  
Copy the PM100_Class.m in a folder of your choice on your system and add the directory to your MATLABPATH.


## *Dependencies*  
MATLAB 2015b or newer
USB connection to the PowerMag 100 TMS


## *License*  
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License (GPLv3) as published
by the Free Software Foundation;


This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  
  
## *Author*
Michael Lindner  
University of Reading, 2018  
School of Psychology and Clinical Language Sciences  
Centre for Integrative Neuroscience and Neurodynamics
