function sensor = recordSensor2(save_file);
% a = arduino('COM6')
%save('test1.mat')
%save_file = varargin{1}

s = daq.createSession('ni');
%devices = daq.getDevices
ch = addAnalogInputChannel(s,'Dev4', [0, 1, 2,3,5,6,7], 'Voltage');
ch2 = addAnalogInputChannel(s,'Dev5', [0,1], 'Voltage');
%dig = addDigitalChannel(s, 'Dev4', 'Port0/Line0:5', 'InputOnly')

acq_rate = 1000;        %Hz
s.Rate = acq_rate;

ch(1).TerminalConfig = 'SingleEnded';
ch(1).Range = [-5, 5]
ch(2).TerminalConfig = 'SingleEnded';
ch(2).Range = [-1, 1]
ch(3).TerminalConfig = 'SingleEnded';
ch(3).Range = [-1, 1]
ch(4).TerminalConfig = 'SingleEnded';
ch(4).Range = [-1, 1]
ch(5).TerminalConfig = 'SingleEnded'; %getting stop signal
ch(5).Range = [-1, 1]
ch(6).TerminalConfig = 'SingleEnded';
ch(6).Range = [-1, 1]
ch(5).TerminalConfig = 'SingleEnded';
ch(5).Range = [-1, 1]
ch(7).TerminalConfig = 'SingleEnded';
ch(7).Range = [-1, 1]

ch2(1).TerminalConfig = 'SingleEnded';
ch2(1).Range = [-1, 1]
ch2(2).TerminalConfig = 'SingleEnded';
ch2(2).Range = [-1, 1]

tic;
time1 = zeros(1);
MiCS = zeros(1);
PID = zeros(1);
Trigger = zeros(1);
Stop = zeros(1);
valve1 = zeros(1);
valve2 = zeros(1);
valve3 = zeros(1);
valve4 = zeros(1);
valve5 = zeros(1);

%save('test2.mat')
Trig_dif = 0
while Trig_dif > -4;
%for i=1:1000  
  %if rem(i, 100) == 0
  %    disp(i);
  %else
  %end
  time1(end+1) = toc;
  data = s.inputSingleScan;
  MiCS(end+1) = data(1, 8);
  PID(end+1) = data(1, 1);
  Trigger(end+1) = data(1, 9);
  Stop(end+1) = data(1, 5);
  valve1(end+1) = data(1,6);
  valve2(end+1) = data(1,7);
  valve3(end+1) = data(1,4);
  valve4(end+1) = data(1,8);
  valve5(end+1) = data(1,3)
  Trig_dif = Trigger(end) - Trigger(end-1)

  %fprintf('voltage on%.2f m\n', readVoltage(a,'A4'));

end
%{
figure
plot(time, MiCS, 'green')
hold on
plot(time, PID, 'blue')
plot(time, Trigger, 'red')
%}
%save('test3.mat')
sensor.MiCEbay = MiCS
sensor.PID = PID
sensor.time = time1
sensor.trigger = Trigger
sensor.valve1 = valve1
sensor.valve2 = valve2
sensor.valve3 = valve3
sensor.valve4 = valve4
sensor.valve5 = valve5
sensor.Stop = Stop
%save_file = 'test.mat'
%save('test4.mat')
save(save_file, 'sensor')

%job = batch(@recordSensors2, 1, {'test8.mat'})
end