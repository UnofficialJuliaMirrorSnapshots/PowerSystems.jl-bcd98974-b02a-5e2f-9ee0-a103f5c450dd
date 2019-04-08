"Abstract struct for thermal generation technologies"
abstract type
    ThermalGen <: Generator
end

""""
Data Structure for thermal generation technologies.
    The data structure contains all the information for technical and economical modeling.
    The data fields can be filled using named fields or directly.

    Examples




"""
struct ThermalDispatch <: ThermalGen
    name::String
    available::Bool
    bus::Bus
    tech::Union{TechThermal,Nothing}
    econ::Union{EconThermal,Nothing}
end

ThermalDispatch(; name = "init",
                status = false,
                bus = Bus(),
                tech = TechThermal(),
                econ = EconThermal()) = ThermalDispatch(name, status, bus, tech, econ)




""""
Data Structure for thermal generation technologies subjecto to seasonality constraints.
    The data structure contains all the information for technical and economical modeling and an extra field for a time series.
    The data fields can be filled using named fields or directly.

    Examples

"""
struct ThermalGenSeason <: ThermalGen
    name::String
    available::Bool
    bus::Bus
    tech::Union{TechThermal,Nothing}
    econ::Union{EconThermal,Nothing}
    scalingfactor::TimeSeries.TimeArray
end

ThermalGenSeason(; name = "init",
                status = false,
                bus = Bus(),
                tech = TechThermal(),
                econ = EconThermal(),
                scalingfactor = TimeSeries.TimeArray(Dates.today(),ones(1))) = ThermalGenSeason(name, status, bus, tech, econ, scalingfactor)
