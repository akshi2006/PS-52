clc;
clear;
close all;

%% =========================================================
% PHASE 2
% DIGITAL COMMUNICATION USING BPSK
% NOISE + LPF + SPECTROGRAM ANALYSIS
%% =========================================================


%% =========================================================
% 1. SYSTEM PARAMETERS
%% =========================================================

Fs = 100000;              % Sampling frequency
Rb = 1000;                % Bit rate

Tb = 1/Rb;                % Bit duration

numBits = 100;            % Number of transmitted bits

samplesPerBit = Fs/Rb;    % Samples representing one bit

t = 0:1/Fs:(numBits*Tb - 1/Fs);


%% =========================================================
% 2. GENERATE RANDOM BINARY DATA
%% =========================================================

data = randi([0 1], 1, numBits);

disp('TRANSMITTED DATA:');
disp(data);


%% =========================================================
% 3. BPSK MODULATION
%
% Binary 1 = +1
% Binary 0 = -1
%% =========================================================

bpskSymbols = 2*data - 1;


% Convert each bit into multiple samples

txSignal = repelem(bpskSymbols, samplesPerBit);


%% =========================================================
% 4. ADD CARRIER FOR REAL PASSBAND SIGNAL
%% =========================================================

fc = 10000;               % Carrier frequency

carrier = cos(2*pi*fc*t);

txPassband = txSignal .* carrier;


%% =========================================================
% 5. ADD NOISE
%% =========================================================

% Gaussian noise

noiseAmplitude = 0.8;

noise = noiseAmplitude * randn(size(txPassband));


% Received noisy signal

rxNoisy = txPassband + noise;


%% =========================================================
% 6. TIME DOMAIN ANALYSIS
%% =========================================================

figure('Name','Digital Communication - Time Domain');

subplot(3,1,1);

plot(t(1:1000), txSignal(1:1000));

title('Original BPSK Baseband Signal');

xlabel('Time (seconds)');
ylabel('Amplitude');

grid on;


subplot(3,1,2);

plot(t(1:1000), txPassband(1:1000));

title('BPSK Modulated Passband Signal');

xlabel('Time (seconds)');
ylabel('Amplitude');

grid on;


subplot(3,1,3);

plot(t(1:1000), rxNoisy(1:1000));

title('Received Signal with Noise');

xlabel('Time (seconds)');
ylabel('Amplitude');

grid on;


%% =========================================================
% 7. FFT ANALYSIS
%% =========================================================

N = length(rxNoisy);

f = (-N/2:N/2-1)*(Fs/N);


TX_FFT = fftshift(fft(txPassband));

RX_FFT = fftshift(fft(rxNoisy));


figure('Name','Frequency Domain Analysis');

subplot(2,1,1);

plot(f, abs(TX_FFT)/N);

title('Spectrum of Transmitted BPSK Signal');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;

xlim([-20000 20000]);


subplot(2,1,2);

plot(f, abs(RX_FFT)/N);

title('Spectrum of Noisy Received Signal');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;

xlim([-20000 20000]);


%% =========================================================
% 8. SPECTROGRAM ANALYSIS
%% =========================================================

figure('Name','Spectrogram Analysis');

subplot(2,1,1);

spectrogram(txPassband,512,400,1024,Fs,'yaxis');

title('Spectrogram of Transmitted BPSK Signal');


subplot(2,1,2);

spectrogram(rxNoisy,512,400,1024,Fs,'yaxis');

title('Spectrogram of Noisy Received Signal');


%% =========================================================
% 9. COHERENT DEMODULATION
%
% Multiply received signal by carrier
%% =========================================================

mixedSignal = rxNoisy .* carrier * 2;


%% =========================================================
% 10. LOW PASS FILTER
%% =========================================================

cutoffFrequency = 2000;

filterOrder = 6;

Wn = cutoffFrequency/(Fs/2);

[b,a] = butter(filterOrder,Wn,'low');

filteredSignal = filtfilt(b,a,mixedSignal);


%% =========================================================
% 11. PLOT AFTER DEMODULATION
%% =========================================================

figure('Name','Demodulation Process');

subplot(2,1,1);

plot(t(1:1000), mixedSignal(1:1000));

title('Signal After Carrier Multiplication');

xlabel('Time (seconds)');
ylabel('Amplitude');

grid on;


subplot(2,1,2);

plot(t(1:1000), filteredSignal(1:1000));

title('Recovered Baseband Signal After LPF');

xlabel('Time (seconds)');
ylabel('Amplitude');

grid on;


%% =========================================================
% 12. BPSK DECISION MAKING
%% =========================================================

receivedData = zeros(1,numBits);


for k = 1:numBits

    startIndex = (k-1)*samplesPerBit + 1;

    endIndex = k*samplesPerBit;

    bitValue = mean(filteredSignal(startIndex:endIndex));


    if bitValue >= 0

        receivedData(k) = 1;

    else

        receivedData(k) = 0;

    end

end


%% =========================================================
% 13. CALCULATE BIT ERRORS
%% =========================================================

bitErrors = sum(data ~= receivedData);

BER = bitErrors / numBits;


%% =========================================================
% 14. DISPLAY RESULTS
%% =========================================================

disp('----------------------------------------');

disp('RECEIVED DATA:');

disp(receivedData);


fprintf('\n');

fprintf('Number of Bit Errors = %d\n', bitErrors);

fprintf('Bit Error Rate = %.6f\n', BER);

fprintf('----------------------------------------\n');


%% =========================================================
% 15. DATA COMPARISON PLOT
%% =========================================================

figure('Name','Transmitted vs Received Data');

subplot(2,1,1);

stairs(data,'LineWidth',1.5);

ylim([-0.2 1.2]);

title('Transmitted Binary Data');

xlabel('Bit Number');

ylabel('Bit Value');

grid on;


subplot(2,1,2);

stairs(receivedData,'LineWidth',1.5);

ylim([-0.2 1.2]);

title('Recovered Binary Data');

xlabel('Bit Number');

ylabel('Bit Value');

grid on;