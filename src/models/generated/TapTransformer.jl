#=
This file is auto-generated. Do not edit.
=#


mutable struct TapTransformer <: ACBranch
    name::String
    available::Bool
    connectionpoints::NamedTuple{(:from, :to), Tuple{Bus, Bus}}
    r::Float64
    x::Float64
    primaryshunt::Float64
    tap::Float64
    rate::Union{Nothing, Float64}
    internal::PowerSystems.PowerSystemInternal
end

function TapTransformer(name, available, connectionpoints, r, x, primaryshunt, tap, rate, )
    TapTransformer(name, available, connectionpoints, r, x, primaryshunt, tap, rate, PowerSystemInternal())
end

function TapTransformer(; name, available, connectionpoints, r, x, primaryshunt, tap, rate, )
    TapTransformer(name, available, connectionpoints, r, x, primaryshunt, tap, rate, )
end

# Constructor for demo purposes; non-functional.

function TapTransformer(::Nothing)
    TapTransformer(;
        name="init",
        available=false,
        connectionpoints=From_To_Bus((from=Bus(nothing), to=Bus(nothing))),
        r=0.0,
        x=0.0,
        primaryshunt=0.0,
        tap=1.0,
        rate=0.0,
    )
end

"""Get TapTransformer name."""
get_name(value::TapTransformer) = value.name
"""Get TapTransformer available."""
get_available(value::TapTransformer) = value.available
"""Get TapTransformer connectionpoints."""
get_connectionpoints(value::TapTransformer) = value.connectionpoints
"""Get TapTransformer r."""
get_r(value::TapTransformer) = value.r
"""Get TapTransformer x."""
get_x(value::TapTransformer) = value.x
"""Get TapTransformer primaryshunt."""
get_primaryshunt(value::TapTransformer) = value.primaryshunt
"""Get TapTransformer tap."""
get_tap(value::TapTransformer) = value.tap
"""Get TapTransformer rate."""
get_rate(value::TapTransformer) = value.rate
"""Get TapTransformer internal."""
get_internal(value::TapTransformer) = value.internal