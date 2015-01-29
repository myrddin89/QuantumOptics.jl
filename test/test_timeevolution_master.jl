using quantumoptics

ωc = 1.2
ωa = 0.9
g = 1.0
γ = 0.5
κ = 1.1

T = Float64[0.,1.]


fockbasis = FockBasis(10)
basis = compose(spinbasis, fockbasis)

Ha = embed(basis, 1, 0.5*ωa*sigmaz)
Hc = embed(basis, 2, ωc*number(fockbasis))
Hint = sigmam ⊗ create(fockbasis) + sigmap ⊗ destroy(fockbasis)
H = Ha + Hc + Hint
Hsparse = SparseOperator(H)

Ja = embed(basis, 1, sqrt(γ)*sigmam)
Jc = embed(basis, 2, sqrt(κ)*destroy(fockbasis))
J = [Ja, Jc]
Jsparse = map(SparseOperator, J)

Ψ₀ = basis_ket(spinbasis, 2) ⊗ basis_ket(fockbasis, 1)
ρ₀ = Ψ₀⊗dagger(Ψ₀)


# Test master
tout, ρt = timeevolution.master(T, ρ₀, H, J; reltol=1e-7)
ρ = ρt[end]

tout, ρt = timeevolution.master(T, ρ₀, Hsparse, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5


# Test master_h
tout, ρt = timeevolution.master_h(T, ρ₀, H, J; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_h(T, ρ₀, Hsparse, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_h(T, ρ₀, Hsparse, J; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_h(T, ρ₀, H, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5


# Test master_nh
Hnh = H - 0.5im*sum([dagger(J[i])*J[i] for i=1:length(J)])
Hnh_sparse = SparseOperator(Hnh)

tout, ρt = timeevolution.master_nh(T, ρ₀, Hnh_sparse, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_nh(T, ρ₀, Hnh, J; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_nh(T, ρ₀, Hnh_sparse, J; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_nh(T, ρ₀, Hnh, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5


# Test simple timeevolution
tout, ρt = timeevolution_simple.master(T, ρ₀, H, J; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution_simple.master(T, ρ₀, Hsparse, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution_simple.master(T, ρ₀, Hsparse, J; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution_simple.master(T, ρ₀, H, Jsparse; reltol=1e-6)
@assert tracedistance(ρt[end], ρ) < 1e-5


# Test special cases
tout, ρt = timeevolution.master(T, ρ₀, H, []; reltol=1e-7)
ρ = ρt[end]

tout, ρt = timeevolution.master_h(T, ρ₀, H, []; reltol=1e-7)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution.master_nh(T, ρ₀, H, []; reltol=1e-7)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, ρt = timeevolution_simple.master(T, ρ₀, H, []; reltol=1e-7)
@assert tracedistance(ρt[end], ρ) < 1e-5

tout, Ψket_t = timeevolution_simple.schroedinger(T, Ψ₀, H; reltol=1.e-7)
tout, Ψbra_t = timeevolution_simple.schroedinger(T, dagger(Ψ₀), H; reltol=1.e-7)
@assert tracedistance(Ψket_t[end]⊗Ψbra_t[end], ρ) < 1e-5