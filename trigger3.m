%clear a:
%{
Matlab script to program an arduino controlling valves on an odor delivery system.
The arduino must be programmed with  Odor_Deliver3.ino.
Step summary
1. setup serial communication with arduino
2. send odor protocol
3. confirm odor protocol has been properly recieved
4. trigger odor delivery and scanimage imaging
5. place arduino back in mode to receive protocol
6. close serial communication to arduino
%}

% Setup serial communication with arduino
ser=serial('COM4','BaudRate', 9600);
fopen(ser);
pause(2)
%{ 
2. Send arduino the odor protocol
Communications to arduino
The first communication sends the '<' array length (n) followed by # char (<n#). This
triggers receiving on arduino end.
The pins and time array have to be the same length.
The pin indicates the valve while the time indicates length in ms for the
period.


Two arrays are being sent. One array contains the pins. A pin=0 means that all valves are closed except the pass through chamber
(pin=9, board=5). The second array contains the time in ms. Both arrays must be the same length.
%}

%pins = [0,    4,   0,   5,   0,   6,   0,   7,    0]
%time = [3000, 3000,3000,1000,2000,4000,1000,90000, 2000];
pins = [0,    7,   0,   ]
time = [5000, 5000,3000,];
array_len = ['<' num2str(length(time)) '#']

fwrite(ser, array_len, 'char');



for i = 1:length(pins)
    fwrite(ser, strcat(num2str(pins(i)), ','), 'char');
end
pins_out = zeros(length(pins),1)
for i = 1:length(pins)
    pins_out(i) =str2num(fscanf(ser))
end


for i = 1:length(time)
    fwrite(ser, strcat(num2str(time(i)), ','), 'char');
end
time_out = zeros(length(time),1)
for i = 1:length(time)
    time_out(i)=str2num(fscanf(ser))
end


%4. Triggering the odor delivery
%sending character 1 is the trigger
job = batch(@recordSensors4, 1, {'test8.mat'})
pause(12)
start =1
fwrite(ser,  num2str(start), 'char');

%5. Place arduino back into mode to receive odor protocol
a = '>'
fwrite(ser, a, 'char');
load('test8.mat')

figure
plot(sensor.PID)
hold on
plot(sensor.MiCEbay)
plot(sensor.trigger)

%6. Close serial communication to arduino
fclose(ser)
