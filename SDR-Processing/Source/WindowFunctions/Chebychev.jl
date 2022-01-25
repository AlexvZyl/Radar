include("../Processing/PowerSpectra.jl")

# ============ #
#  W I N D O W #
# ============ #

# SLL = SideLobeLevel, given in dBc, and has to be < 0.
function generateChebychevWindow(freq, SLL::Number)

    N = length(freq)

    ƞ = 10 ^ (-SLL / 20)

    A = acosh(ƞ) / pi

    W(f) =  (  φ(f, N) * cos( pi * sqrt(f^2 * A^2) )  )        /
          # --------------------------------------------
            (   cos(pi * sqrt(Complex(-1 * A^2)) )    )

    W.(freq)

end

# =============================== # 
#  S I G N   E X P R E S S I O N  #
# =============================== # 

function φ(f, N)

    isOdd = (N%2==1)
    if   (isOdd || f≥0) return 1
    else                return -1
    end

end

# ======= #
#  E O F  #
# ======= #