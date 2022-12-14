function e = testAccuray(fixed_in, float_in, num_frac, round2)

convert = fixed_in/(2^num_frac);
e = float_in - round(convert, round2);
end