#=
Instalación de paquetes necesarios para el curso Probabilidad II.
Ejecuta este bloque en Julia (REPL o script).
=#

using Pkg

begin
    paquetes = [
        "Distributions",  # distribuciones de probabilidad
        "Plots",          # gráficos
        "StatsBase",      # estadísticos descriptivos, muestreo, conteos
        "DataFrames"      # tablas para resumir resultados
    ]
    for p in paquetes
        println("*** Instalando paquete: ", p)
        Pkg.add(p)
    end
    println("*** Fin de la instalación de paquetes.")
end
