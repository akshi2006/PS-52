clc;
clear;
close all;

%% =========================================================
% INTELLIGENT ACOUSTIC PROTECTION SYSTEM
% BASIC SIGNAL + NOISE + LPF + SPECTROGRAM SIMULATION
%% =========================================================

%% 1. SIMULATION PARAMETERS

fs = 16000;              % Sampling frequency (Hz)
T = 2;                   % Duration in seconds

t = 0:1/fs:T-1/fs;       % Time vector

N = length(t);           % Number of samples


%% =========================================================
% 2. GENERATE ORIGINAL DESIRED SIGNAL
% Communication signal
%% =========================================================

f_signal = 1000;         % Desired signal frequency = 1 kHz

signal = sin(2*pi*f_signal*t);


%% =========================================================
% 3. GENERATE DIFFERENT TYPES OF NOISE
%% =========================================================

% ---------------------------------------------------------
% A. STATIONARY NOISE
% Constant frequency noise
% ---------------------------------------------------------

stationary_noise = 0.8*sin(2*pi*3000*t);


% ---------------------------------------------------------
% B. NON-STATIONARY NOISE
% Frequency changes with time
% ---------------------------------------------------------

nonstationary_noise = 0.6*chirp(t,200,T,6000);


% ---------------------------------------------------------
% C. IMPULSIVE NOISE
% Sudden noise bursts
% ---------------------------------------------------------

impulsive_noise = zeros(size(t));

impulsive_noise(round(0.4*fs)) = 4;
impulsive_noise(round(0.9*fs)) = 4;
impulsive_noise(round(1.4*fs)) = 4;


% ---------------------------------------------------------
% D. WHITE GAUSSIAN NOISE
% ---------------------------------------------------------

white_noise = 0.3*randn(size(t));


%% =========================================================
% 4. CREATE THE FINAL NOISY SIGNAL
%% =========================================================

noise = stationary_noise + ...
        nonstationary_noise + ...
        impulsive_noise + ...
        white_noise;

noisy_signal = signal + noise;


%% =========================================================
% 5. TIME DOMAIN PLOTS
%% =========================================================

figure('Name','Time Domain Analysis');

subplot(3,1,1);

plot(t,signal);

title('Original Desired Signal');

xlabel('Time (seconds)');

ylabel('Amplitude');

grid on;


subplot(3,1,2);

plot(t,noise);

title('Combined Noise');

xlabel('Time (seconds)');

ylabel('Amplitude');

grid on;


subplot(3,1,3);

plot(t,noisy_signal);

title('Noisy Signal');

xlabel('Time (seconds)');

ylabel('Amplitude');

grid on;


%% =========================================================
% 6. FFT ANALYSIS
%% =========================================================

Y_signal = fft(signal);

Y_noise = fft(noise);

Y_noisy = fft(noisy_signal);


% Frequency axis

f = (0:N-1)*(fs/N);


% Use only positive frequency

half_N = floor(N/2);

f_positive = f(1:half_N);


%% FFT of Original Signal

figure('Name','Frequency Spectrum');

subplot(3,1,1);

plot(f_positive,...
     abs(Y_signal(1:half_N))/N);

title('FFT - Original Signal');

xlabel('Frequency (Hz)');

ylabel('Magnitude');

xlim([0 8000]);

grid on;


%% FFT of Noise

subplot(3,1,2);

plot(f_positive,...
     abs(Y_noise(1:half_N))/N);

title('FFT - Noise');

xlabel('Frequency (Hz)');

ylabel('Magnitude');

xlim([0 8000]);

grid on;


%% FFT of Noisy Signal

subplot(3,1,3);

plot(f_positive,...
     abs(Y_noisy(1:half_N))/N);

title('FFT - Noisy Signal');

xlabel('Frequency (Hz)');

ylabel('Magnitude');

xlim([0 8000]);

grid on;


%% =========================================================
% 7. SPECTROGRAM ANALYSIS
%% =========================================================

figure('Name','Spectrogram Analysis');


subplot(3,1,1);

mySpectrogram(signal, fs, 256, 200, 512);

title('Spectrogram - Original Signal');


subplot(3,1,2);

mySpectrogram(noise, fs, 256, 200, 512);

title('Spectrogram - Noise');


subplot(3,1,3);

mySpectrogram(noisy_signal, fs, 256, 200, 512);

title('Spectrogram - Noisy Signal');


%% =========================================================
% 8. DESIGN LOW PASS FILTER
%% =========================================================

cutoff_frequency = 2000;

filter_order = 6;


% Normalized cutoff frequency

Wn = cutoff_frequency/(fs/2);


% Butterworth LPF

[b,a] = butter(filter_order,Wn,'low');


%% =========================================================
% 9. APPLY LOW PASS FILTER
%% =========================================================

filtered_signal = filtfilt(b,a,noisy_signal);


%% =========================================================
% 10. TIME DOMAIN COMPARISON
%% =========================================================

figure('Name','Before and After Filtering');


subplot(3,1,1);

plot(t,signal);

title('Original Signal');

xlabel('Time (seconds)');

ylabel('Amplitude');

grid on;


subplot(3,1,2);

plot(t,noisy_signal);

title('Noisy Signal Before LPF');

xlabel('Time (seconds)');

ylabel('Amplitude');

grid on;


subplot(3,1,3);

plot(t,filtered_signal);

title('Recovered Signal After LPF');

xlabel('Time (seconds)');

ylabel('Amplitude');

grid on;


%% =========================================================
% 11. FFT OF FILTERED SIGNAL
%% =========================================================

Y_filtered = fft(filtered_signal);


figure('Name','Frequency Comparison');


subplot(2,1,1);

plot(f_positive,...
     abs(Y_noisy(1:half_N))/N);

title('Frequency Spectrum Before Filtering');

xlabel('Frequency (Hz)');

ylabel('Magnitude');

xlim([0 8000]);

grid on;


subplot(2,1,2);

plot(f_positive,...
     abs(Y_filtered(1:half_N))/N);

title('Frequency Spectrum After LPF');

xlabel('Frequency (Hz)');

ylabel('Magnitude');

xlim([0 8000]);

grid on;


%% =========================================================
% 12. SPECTROGRAM AFTER FILTERING
%% =========================================================

figure('Name','Spectrogram Comparison');


subplot(2,1,1);

spectrogram(noisy_signal,256,200,512,fs,'yaxis');

title('Spectrogram Before Filtering');


subplot(2,1,2);

spectrogram(filtered_signal,256,200,512,fs,'yaxis');

title('Spectrogram After LPF');


%% =========================================================
% 13. SNR CALCULATION
%% =========================================================

signal_power = mean(signal.^2);

noise_before = noisy_signal - signal;

noise_power_before = mean(noise_before.^2);


SNR_before = 10*log10(signal_power/noise_power_before);


noise_after = filtered_signal - signal;

noise_power_after = mean(noise_after.^2);


SNR_after = 10*log10(signal_power/noise_power_after);


%% =========================================================
% 14. DISPLAY RESULTS
%% =========================================================

fprintf('\n');

fprintf('===============================================\n');

fprintf(' SIGNAL ANALYSIS RESULTS\n');

fprintf('===============================================\n');

fprintf('Sampling Frequency = %d Hz\n',fs);

fprintf('Signal Frequency = %d Hz\n',f_signal);

fprintf('LPF Cutoff Frequency = %d Hz\n',cutoff_frequency);

fprintf('\n');

fprintf('SNR BEFORE FILTERING = %.2f dB\n',SNR_before);

fprintf('SNR AFTER FILTERING  = %.2f dB\n',SNR_after);

fprintf('\n');

fprintf('SNR IMPROVEMENT      = %.2f dB\n',...
        SNR_after-SNR_before);

fprintf('===============================================\n');


%% =========================================================
% END OF PROGRAM
%% =========================================================

function mySpectrogram(x, fs, window_length, overlap, nfft)

    % Step size between frames
    step = window_length - overlap;

    % Number of frames
    num_frames = floor((length(x) - overlap) / step);

    % Frequency axis
    f = (0:nfft/2-1) * fs/nfft;

    % Time storage
    time = zeros(1, num_frames);

    % Spectrogram matrix
    S = zeros(nfft/2, num_frames);

    % Manual window
    window = ones(window_length, 1);

    % Process every frame
    for k = 1:num_frames

        % Starting sample
        start_index = (k-1)*step + 1;

        % Extract a small signal frame
        frame = x(start_index : start_index + window_length - 1);

        % Convert to column vector and apply window
        frame = frame(:) .* window;

        % FFT
        X = fft(frame, nfft);

        % Store positive frequency magnitude
        S(:, k) = abs(X(1:nfft/2));

        % Frame time
        time(k) = (start_index - 1) / fs;

    end

    % Convert magnitude to dB
    S_dB = 20 * log10(S + 1e-10);

    % Plot spectrogram
    imagesc(time, f, S_dB);

    axis xy;

    xlabel('Time (seconds)');
    ylabel('Frequency (Hz)');

    colorbar;

end