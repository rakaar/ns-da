function spikes = get_spikes_from_timings(stimulus_duration, spike_times)
    spikes = zeros(1, stimulus_duration);
    spike_times_length = length(spike_times);

    for i=1:spike_times_length
        time_in_ms_rounded = fix(spike_times(i)*1000) + 1;
        spikes(1, time_in_ms_rounded) = 1;
    end
end