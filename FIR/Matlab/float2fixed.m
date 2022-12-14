function fixed_point_val = float2fixed(float_in, num_frac)
% @param float_in = floating point input 
% @param num_frac = number of fractional bits

fixed_point_val = round((float_in*2^(num_frac)));

end
