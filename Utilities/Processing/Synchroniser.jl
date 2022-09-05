# --------------------------- #
#  S Y N C   F U N C T I O N  #
# --------------------------- #

# Find the position of the pulse (where the max value sits)
function get_sync_index(signal::Vector, meta_data::Meta_Data; pulses_to_search::Number = 2)
    return argmax(abs.(signal[1:1:meta_data.pulse_sample_count*pulses_to_search]))
end

# Sync the signal.
function sync_signal(signal::Vector, sync_index::Number, meta_data::Meta_Data)
    synced_signal = signal[sync_index:1:end]
    total_pulses = floor(Int, length(synced_signal)/meta_data.pulse_sample_count)
    return synced_signal[1:1:total_pulses*meta_data.pulse_sample_count]
end

# ------- #
#  E O F  #
# ------- #
