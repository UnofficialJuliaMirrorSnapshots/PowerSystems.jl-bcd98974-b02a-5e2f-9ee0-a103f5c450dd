#=
This file is auto-generated. Do not edit.
=#

"""As implemented in Milano&#39;s Book, Page 397"""
mutable struct VSCDCLine <: DCBranch
    name::String
    available::Bool
    activepower_flow::Float64
    arc::Arc
    rectifier_taplimits::Min_Max
    rectifier_xrc::Float64
    rectifier_firing_angle::Min_Max
    inverter_taplimits::Min_Max
    inverter_xrc::Float64
    inverter_firing_angle::Min_Max
    internal::PowerSystemInternal
end

function VSCDCLine(name, available, activepower_flow, arc, rectifier_taplimits, rectifier_xrc, rectifier_firing_angle, inverter_taplimits, inverter_xrc, inverter_firing_angle, )
    VSCDCLine(name, available, activepower_flow, arc, rectifier_taplimits, rectifier_xrc, rectifier_firing_angle, inverter_taplimits, inverter_xrc, inverter_firing_angle, PowerSystemInternal())
end

function VSCDCLine(; name, available, activepower_flow, arc, rectifier_taplimits, rectifier_xrc, rectifier_firing_angle, inverter_taplimits, inverter_xrc, inverter_firing_angle, )
    VSCDCLine(name, available, activepower_flow, arc, rectifier_taplimits, rectifier_xrc, rectifier_firing_angle, inverter_taplimits, inverter_xrc, inverter_firing_angle, )
end

# Constructor for demo purposes; non-functional.

function VSCDCLine(::Nothing)
    VSCDCLine(;
        name="init",
        available=false,
        activepower_flow=0.0,
        arc=Arc(Bus(nothing), Bus(nothing)),
        rectifier_taplimits=(min=0.0, max=0.0),
        rectifier_xrc=0.0,
        rectifier_firing_angle=(min=0.0, max=0.0),
        inverter_taplimits=(min=0.0, max=0.0),
        inverter_xrc=0.0,
        inverter_firing_angle=(min=0.0, max=0.0),
    )
end

"""Get VSCDCLine name."""
get_name(value::VSCDCLine) = value.name
"""Get VSCDCLine available."""
get_available(value::VSCDCLine) = value.available
"""Get VSCDCLine activepower_flow."""
get_activepower_flow(value::VSCDCLine) = value.activepower_flow
"""Get VSCDCLine arc."""
get_arc(value::VSCDCLine) = value.arc
"""Get VSCDCLine rectifier_taplimits."""
get_rectifier_taplimits(value::VSCDCLine) = value.rectifier_taplimits
"""Get VSCDCLine rectifier_xrc."""
get_rectifier_xrc(value::VSCDCLine) = value.rectifier_xrc
"""Get VSCDCLine rectifier_firing_angle."""
get_rectifier_firing_angle(value::VSCDCLine) = value.rectifier_firing_angle
"""Get VSCDCLine inverter_taplimits."""
get_inverter_taplimits(value::VSCDCLine) = value.inverter_taplimits
"""Get VSCDCLine inverter_xrc."""
get_inverter_xrc(value::VSCDCLine) = value.inverter_xrc
"""Get VSCDCLine inverter_firing_angle."""
get_inverter_firing_angle(value::VSCDCLine) = value.inverter_firing_angle
"""Get VSCDCLine internal."""
get_internal(value::VSCDCLine) = value.internal
