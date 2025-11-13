### Introducción a Convergencia de v.a's y Teoremas Límite
### Autor: David Reboyo
### Versión: 2024-10.12

#= ---------------------------------------------------------------------------------------------
Una aseguradora ofrece un solo producto, un seguro temporal a un año, i.e. una cartera homogénea de tamaño n (todos los asegurados son de 55 años) 
y su probabilidad de muerte es qx=0.01 la suma asegurada de cada póliza ese igual a c=100,000. Se considera independencia entre las pólizas y ausencia 
de gastos. La prima de cada póliza se fija en el monto total de reclamación esperado multiplicado (1+ϑ) donde ϑ representa únicamente utilidad.

Cartera: (mismo producto y edad x=55). Para cada póliza j, X_j es el monto reclamado en el año. Definimos:
  • S_n = Σ_{j=1}^n X_j  (Suma total de lo reclamado anual)
  • X̄_n = S_n / n        (reclamación promedio por póliza)
  • P(θ) = E[X_1](1+θ)    (prima por póliza con carga θ)
  • GN(θ) = n·P(θ) - S_n  (ganancia neta anual)
Parámetros x=55, q_x=0.01, c=1,000,000

Objetivo:
Hacer UNA simulación (“un universo”) y reportar:
  • B_n (número de siniestros), S_n, X̄_n, E[X] = c·q
  • Para cada θ: P(θ), TP(θ)=n·P(θ), GN(θ)=TP(θ)−S_n
--------------------------------------------------------------------------------------------- =#

begin
    using Distributions, Statistics, Plots, Printf
end

@doc Bernoulli   # Referencia rápida a la documentación de la distribución Bernoulli

# a) Si la aseguradora cobra sólo prima pura (ϑ=0) ¿qué tan probable es perder dinero durante el año cómo cambia esto cuando crece n?
# Simula **una sola realización** de la cartera:
function simulateClaims(; q=0.01,  c = 100_000, θ=[0.00, 0.05, 0.10, 0.15, 0.20], n=1_000_00,)
    B = Bernoulli(q)
    X = c * B
    Bj = rand(B, n)             # Indica vida/muerte par cada póliza
    Xj = c .* Bj                # Monto pagado por sinsietro a cada póliza: c si hay siniestro, 0 si no

    Bn   = sum(Bj)              # Número de siniestros reportados
    Sn   = sum(Xj)              # S_n (monto pagado total por siniestros reportados)
    Xbar = Sn / n               # X̄_n (monto promedio observado reclamado por cada póliza)

    EX   = mean(X)              # E[X] (prima pura individual, media teórica)
    VX   = var(X)               # V[X] (varianza teórica)

    # --- Totales con prima pura (θ = 0) (informativo) ---
    P_pura  = EX
    TP_pura = n * P_pura
    GN_pura = TP_pura - Sn

    # --- Reporte general ---
    println("─────────────────────────────────────────────")
    println(" Simulación de siniestros de la cartera (un solo universo)")
    println("─────────────────────────────────────────────")
    @printf("Probabilidad de siniestro (q): %.4f\n", q)
    println("Suma asegurada por póliza (c): $c")
    println("Tamaño de la cartera (n):      $n")
    println("─────────────────────────────────────────────")
    println("Total de siniestros reportados:  Bₙ = $(Bn)")
    @printf("Total pagado de reclamaciones:   Sₙ = %.2f\n", Sn)
    @printf("Media muestral observada:        X̄ₙ = Sₙ/n = %.6f\n", Xbar)
    @printf("Media teórica:                   E[X] = c·q = %.6f\n", EX)
    @printf("Varianza teórica:                V[X] = c^{2}·q·(1-q) = %.6f\n", VX)
    println("─────────────────────────────────────────────")

    # --- Tabla por carga θ: P(θ), TP(θ), GN(θ) ---
    println("Tabla por carga θ:")
    @printf("%8s  %14s  %14s  %14s\n", "θ", "P(θ)", "TP(θ)=n·P", "GN(θ)=TP−Sₙ")
    for th in θ
        Pθ  = EX * (1 + th)
        TPθ = n * Pθ
        GNθ = TPθ - Sn
        @printf("%8.2f  %14.2f  %14.2f  %14.2f\n", th, Pθ, TPθ, GNθ)
    end
    println("─────────────────────────────────────────────")

    return (q=q, c=c, n=n, EX=EX, Bn=Bn, Sn=Sn, Xbar=Xbar, θ=θ)
end

# Ejecución (n grande para ver desempeño)
@time simulateClaims(; q=0.01,  c = 100_000, n=1_000_000)
#------------------------------------------------------------------------------------------------

# b) Denota por X̄_n la reclamación promedio por póliza en la cartera, encuentra el valor al que converge cuando n aumenta.
function plotXbarTrajectory(; q=0.01, c=100_000, n=1_000_000)
    B  = Bernoulli(q)
    Bj = rand(B, n)
    Xj = c .* Bj

    k    = 1:n
    Xbar = cumsum(Xj) ./ k           # promedio muestral por póliza
    EX   = c * q                     # media teórica

    plt = plot(k, Xbar,
               xlabel = "n",
               ylabel = "Reclamación promedio por póliza (X̄ₙ)",
               label  = "X̄ₙ",
               title  = "Evolución de X̄ₙ (una trayectoria)",
               color  = :blue)        # línea muestral en azul
    hline!(plt, [EX],
           linestyle = :dash,
           label     = "E[X] = $(round(EX; digits=2))",
           color     = :red)          # media teórica en rojo
    display(plt)

    return (q=q, c=c, n=n, EX=EX, Xbar=Xbar)
end


@time plotXbarTrajectory(; q=0.01, c=100_000, n=1_000_000)
#------------------------------------------------------------------------------------------

#= c) Para un margen 0< ϑ =10% calcula la probabilidad aproximada de que la ganancia anual de la aseguradora supere un η=5% del total de primas 
      recaudadas si el total de pólizas vendidas es n=10000=# 
function simulateClaimsMC(; q=0.01, c=100_000, θ=[0.00, 0.05, 0.10, 0.15, 0.20],
                          n=1_000_00, m=10_000, η=0.05)

    # --- Parámetros base ---
    EX  = c * q                      # E[X] (prima pura por póliza)
    Pθ  = EX .* (1 .+ θ)             # P(θ)
    TPθ = n  .* Pθ                   # TP(θ) = n·P(θ)

    # --- m simulaciones del agregado S_n = c·K, K ~ Binomial(n,q) ---
    K = rand(Binomial(n, q), m)      # conteos de siniestros por corrida
    S = c .* K                       # S_n por corrida

    # --- Estimación de P(GN(θ) > η·TP(θ)) para cada θ ---
    p_above = similar(θ, Float64)
    for (i, th) in pairs(θ)
        GN = TPθ[i] .- S                         # vector GN_r(θ)
        threshold = η * TPθ[i]                   # η·TP(θ)
        p_above[i] = mean(GN .> threshold)       # proporción que supera el umbral
    end

    # --- Reporte general ---
    println("─────────────────────────────────────────────")
    println(" Estimación de P(GN(θ) > η·TP(θ))")
    println("─────────────────────────────────────────────")
    @printf("q = %.4f    c = %0.0f    n = %d    m = %d    η = %.2f\n", q, c, n, m, η)
    @printf("E[X] = c·q = %0.2f\n", EX)
    println("─────────────────────────────────────────────")
    println("Tabla por carga θ (probabilidad de GN por ENCIMA de η·TP):")
    @printf("%8s  %14s  %14s  %24s\n", "θ", "P(θ)", "TP(θ)=n·P", "p̂ = P(GN > η·TP)")
    for i in eachindex(θ)
        @printf("%8.4f  %14.2f  %14.2f  %24.6f\n", θ[i], Pθ[i], TPθ[i], p_above[i])
    end
    println("─────────────────────────────────────────────")

    return (q=q, c=c, n=n, m=m, EX=EX, θ=θ, P=Pθ, TP=TPθ, η=η, p_above=p_above)
end

@time simulateClaimsMC(; q=0.01, c=100_000, θ=[0.00,0.05,0.10,0.15,0.20], n=10_000, m=1_000_000, η=0.05)