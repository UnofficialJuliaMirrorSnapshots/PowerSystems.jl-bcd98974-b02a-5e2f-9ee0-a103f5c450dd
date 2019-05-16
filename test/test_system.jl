
@testset "Test functionality of System" begin
    cdm_dict = PowerSystems.csv2ps_dict(RTS_GMLC_DIR, 100.0)
    sys_rts = PowerSystems._System(cdm_dict)
    rts_da = PowerSystems.make_forecast_array(sys_rts, cdm_dict["forecasts"]["DA"])
    rts_rt = PowerSystems.make_forecast_array(sys_rts, cdm_dict["forecasts"]["RT"])

    PowerSystems.add_forecast!(sys_rts, :DA=>rts_da)
    PowerSystems.add_forecast!(sys_rts, :RT=>rts_rt)

    sys = System(cdm_dict)
    @test length(sys_rts.branches) == length(collect(get_components(Branch, sys)))
    @test length(sys_rts.loads) == length(collect(get_components(ElectricLoad, sys)))
    @test length(sys_rts.storage) == length(collect(get_components(Storage, sys)))
    @test length(sys_rts.generators.thermal) == length(collect(get_components(ThermalGen, sys)))
    @test length(sys_rts.generators.renewable) == length(collect(get_components(RenewableGen, sys)))
    @test length(sys_rts.generators.hydro) == length(collect(get_components(HydroGen, sys)))
    @test length(collect(get_components(Bus, sys))) > 0
    @test length(collect(get_components(ThermalDispatch, sys))) > 0
    summary(devnull, sys)

    # Negative test of missing type.
    components = Vector{ThermalGen}()
    for subtype in PowerSystems.subtypes(ThermalGen)
        if haskey(sys.components, subtype)
            for component in pop!(sys.components, subtype)
                push!(components, component)
            end
        end
    end

    @test length(collect(get_components(ThermalGen, sys))) == 0
    @test length(collect(get_components(ThermalDispatch, sys))) == 0

    # For the next test to work there must be at least one component to add back.
    @test length(components) > 0
    for component in components
        add_component!(sys, component)
    end

    @test length(collect(get_components(ThermalGen, sys))) > 0

    issue_times = collect(get_forecast_issue_times(sys))
    @assert length(issue_times) > 0
    issue_time = issue_times[1]

    # Get forecasts with a label and without.
    forecasts = get_forecasts(sys, issue_time, get_components(HydroCurtailment, sys),
                              "PMax MW")
    @test length(forecasts) > 0

    forecasts = get_forecasts(sys, issue_time, get_components(HydroCurtailment, sys))
    count = length(forecasts)
    @test count > 0

    for forecast in forecasts
        remove_forecast!(sys, forecast)
    end

    # InvalidParameter is thrown if the type is concrete and there is no forecast for a
    # component.
    @test_throws(InvalidParameter,
                 get_forecasts(sys, issue_time, get_components(HydroCurtailment, sys)))

    # But not if the type is abstract.
    new_forecasts = get_forecasts(sys, issue_time, get_components(HydroGen, sys))
    @test length(new_forecasts) == 0

    add_forecasts!(sys, forecasts)

    forecasts = get_forecasts(sys, issue_time, get_components(HydroCurtailment, sys))
    @assert length(forecasts) == count

    pop!(sys.forecasts, issue_time)
    @test_throws(InvalidParameter, get_forecasts(sys, issue_time))
end
