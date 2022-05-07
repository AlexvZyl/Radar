# FFT based interpolation.
# Input:
#	x - input signal vector (even length).
#	N - integer oversampling factor.

# Author: J.E. Cilliers
# Update Record:
#	[2022-05-06] Started.
#	[2022-05-07] Problem with sample at F_s/2 - had to distribute to both sides.
# ToDo:
#	1. Write a test file for real signals.
#	2. Test for complex signals, and add tests.
#	3. Modify to allow for uneven lengths.

using FFTW

function FFT_interp(x::Vector,N::Integer)
    M = Integer(size(x,1)/2)

    f = fft(x)
    f1 = f[1:M]
    f_mid = f[M+1]/2
    f2 = f[M+2:end]
    f_in = [f1; f_mid; zeros(2*M*(N-1)-1); f_mid'; f2]
    ifft(f_in)*N
end

# END of FILE