import JSON2

function validate_serialization(sys::System)
    path, io = mktemp()
    @info "Serializing to $path"

    try
        to_json(io, sys)
    catch
        close(io)
        rm(path)
        rethrow()
    end
    close(io)

    try
        sys2 = System(path)
        return PowerSystems.compare_values(sys, sys2)
    finally
        @debug "delete temp file" path
        rm(path)
    end
end

@testset "Test JSON serialization" begin
    sys = create_rts_system()
    @test validate_serialization(sys)

    # Serialize specific components.
    for component_type in keys(sys.components)
        if component_type <: Service || component_type <: Deterministic
            # These can only be deserialized from within System.
            continue
        end
        for component in get_components(component_type, sys)
            text = to_json(component)
            component2 = from_json(text, typeof(component))
            @test PowerSystems.compare_values(component, component2)
        end
    end

    text = JSON2.write(sys.components)
    @test length(text) > 0
end

@testset "Test serialization utility functions" begin
    text = "SomeType{ParameterType1, ParameterType2}"
    type_str, parameters = PowerSystems.separate_type_and_parameter_types(text)
    @test type_str == "SomeType"
    @test parameters == ["ParameterType1", "ParameterType2"]

    text = "SomeType"
    type_str, parameters = PowerSystems.separate_type_and_parameter_types(text)
    @test type_str == "SomeType"
    @test parameters == []
end
