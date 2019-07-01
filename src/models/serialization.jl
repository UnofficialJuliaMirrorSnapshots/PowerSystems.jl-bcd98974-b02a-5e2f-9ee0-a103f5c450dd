
"""Serializes a PowerSystemType to a JSON file."""
function to_json(obj::T, filename::String) where {T <: PowerSystemType}
    return open(filename, "w") do io
        return to_json(io, obj)
    end

    @info "Serialized $T to $filename"
end

"""Serializes a PowerSystemType to a JSON string."""
function to_json(obj::T)::String where {T <: PowerSystemType}
    return JSON2.write(obj)
end

"""JSON Serializes a PowerSystemType to an IO stream in JSON."""
function to_json(io::IO, obj::T) where {T <: PowerSystemType}
    return JSON2.write(io, obj)
end

"""Deserializes a PowerSystemType from a JSON filename."""
function from_json(::Type{T}, filename::String) where {T <: PowerSystemType}
    return open(filename) do io
        from_json(io, T)
    end
end

"""Deserializes a PowerSystemType from String or IO."""
function from_json(io::Union{IO, String}, ::Type{T}) where {T <: PowerSystemType}
    return JSON2.read(io, T)
end

"""Enables JSON deserialization of TimeSeries.TimeArray.
The default implementation fails because the data field is defined as an AbstractArray.
Deserialization can't determine the actual concrete type.
"""
function JSON2.read(io::IO, ::Type{T}) where {T <: TimeSeries.TimeArray}
    data = JSON2.read(io)
    timestamp = [Dates.DateTime(x) for x in data.timestamp]
    values = [Float64(x) for x in data.values]
    colnames = [Symbol(x) for x in data.colnames]
    meta = data.meta
    return TimeSeries.TimeArray(timestamp, values, colnames, meta)
end

"""Enables JSON deserialization of Dates.Period.
The default implementation fails because the field is defined as abstract.
Encode the type when serializing so that the correct value can be deserialized.
"""
function JSON2.write(resolution::Dates.Period)
    return JSON2.write(encode_for_json(resolution))
end

function JSON2.write(io::IO, resolution::Dates.Period)
    return JSON2.write(io, encode_for_json(resolution))
end

function encode_for_json(resolution::Dates.Period)
    return (value=resolution.value,
            unit=strip_module_names(string(typeof(resolution))))
end

function JSON2.read(io::IO, ::Type{T}) where {T <: Dates.Period}
    data = JSON2.read(io)
    return getfield(Dates, Symbol(data.unit))(data.value)
end

"""
The next few methods fix serialization of UUIDs. The underlying type of a UUID is a UInt128.
JSON2 tries to encode this as a number in JSON. Encoding integers greater than can
be stored in a signed 64-bit integer sometimes does not work - at least when using the
JSON2.@pretty option. The number gets converted to a float in scientific notation, and so
the UUID is truncated and essentially lost. These functions cause JSON2 to encode UUIDs as
strings and then convert them back during deserialization.
"""

function JSON2.write(uuid::Base.UUID)
    return JSON2.write(encode_for_json(uuid))
end

function JSON2.write(io::IO, uuid::Base.UUID)
    return JSON2.write(io, encode_for_json(uuid))
end

function JSON2.read(io::IO, ::Type{Base.UUID})
    data = JSON2.read(io)
    return Base.UUID(data.value)
end

function encode_for_json(uuid::Base.UUID)
    return (value=string(uuid),)
end

"""Enables deserialization of EconThermal. The default implementation can't figure out the
variablecost Union.
"""
function JSON2.read(io::IO, ::Type{T}) where {T <: EconThermal}
    data = JSON2.read(io)
    @assert length(data.variablecost) > 0
    if data.variablecost[1] isa Array
        variablecost = Vector{Tuple{Float64, Float64}}()
        for array in data.variablecost
            push!(variablecost, Tuple{Float64, Float64}(array))
        end
    else
        @assert data.variablecost isa Tuple || data.variablecost isa Array
        variablecost = Tuple{Float64, Float64}(data.variablecost)
    end

    internal = convert_type(PowerSystemInternal, data.internal)
    return EconThermal(data.capacity, variablecost, data.fixedcost, data.startupcost,
                       data.shutdncost, data.annualcapacityfactor, internal)
end

# Refer to docstrings in services.jl.

function JSON2.write(io::IO, forecast::Deterministic)
    return JSON2.write(io, encode_for_json(forecast))
end

function JSON2.write(forecast::Deterministic)
    return JSON2.write(encode_for_json(forecast))
end

function encode_for_json(forecast::Deterministic)
    fields = fieldnames(Deterministic)
    vals = []

    for name in fields
        val = getfield(forecast, name)
        if val isa Component
            push!(vals, get_uuid(val))
        else
            push!(vals, val)
        end
    end

    return NamedTuple{fields}(vals)
end

"""Creates a Deterministic object by decoding the data that was in JSON. This data stores
the values for the field contributingdevices as UUIDs, so this will lookup each device in
devices.
"""
function convert_type(
                      ::Type{T},
                      data::NamedTuple,
                      components::LazyDictFromIterator,
                      parameter_types::Vector{DataType},
                     ) where T <: Deterministic
    @debug T data
    values = []
    component_type = nothing

    for (fieldname, fieldtype)  in zip(fieldnames(T), fieldtypes(T))
        val = getfield(data, fieldname)
        if fieldtype <: Component
            uuid = Base.UUID(val.value)
            component = get(components, uuid)

            if isnothing(component)
                throw(DataFormatError("failed to find $uuid"))
            end

            component_type = typeof(component)
            @assert length(parameter_types) == 1
            @assert component_type == parameter_types[1]
            push!(values, component)
        else
            obj = convert_type(fieldtype, val)
            push!(values, obj)
        end
    end

    @assert !isnothing(component_type)

    return T{component_type}(values...)
end

function convert_type(::Type{T}, data::Any) where T <: Deterministic
    error("This form of convert_type is not supported for Deterministic")
end

"""Return a Tuple of type and parameter types for cases where a parametric type has been
encoded as a string. If the type is not parameterized then just return the type.
"""
function separate_type_and_parameter_types(name::String)
    parameters = Vector{String}()
    index_start_brace = findfirst("{", name)
    if isnothing(index_start_brace)
        type_str = name
    else
        type_str = name[1: index_start_brace.start - 1]
        index_close_brace = findfirst("}", name)
        @assert index_start_brace.start < index_close_brace.start
        for x in split(name[index_start_brace.start + 1: index_close_brace.start - 1], ",")
            push!(parameters, strip(x))
        end
    end

    return (type_str, parameters)
end