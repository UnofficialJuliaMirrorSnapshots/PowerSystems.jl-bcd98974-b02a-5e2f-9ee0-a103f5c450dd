
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
    @test length(collect(get_components(ThermalStandard, sys))) > 0
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
    @test length(collect(get_components(ThermalStandard, sys))) == 0

    # For the next test to work there must be at least one component to add back.
    @test length(components) > 0
    for component in components
        add_component!(sys, component)
    end

    @test length(collect(get_components(ThermalGen, sys))) > 0

    initial_times = get_forecast_initial_times(sys)
    @assert length(initial_times) > 0
    initial_time = initial_times[1]

    # Get forecasts with a label and without.
    components = get_components(HydroDispatch, sys)
    forecasts = get_forecasts(Forecast, sys, initial_time, components, "PMax MW")
    @test length(forecasts) > 0

    forecasts = get_forecasts(Forecast, sys, initial_time, components)
    count = length(forecasts)
    @test count > 0

    # Verify that the two accessor functions return the same results.
    all_components = get_components(Component, sys)
    all_forecasts1 = get_forecasts(Forecast, sys, initial_time, all_components)
    all_forecasts2 = get_forecasts(Forecast, sys, initial_time)
    @test length(all_forecasts1) == length(all_forecasts2)

    # Get specific forecasts. They should not match.
    specific_forecasts = get_forecasts(Deterministic{Bus}, sys, initial_time)
    @test length(specific_forecasts) < length(all_forecasts1)

    @test get_forecasts_horizon(sys) == 24
    @test get_forecasts_initial_time(sys) == Dates.DateTime("2020-01-01T00:00:00")
    @test get_forecasts_interval(sys) == Dates.Hour(1)  # TODO
    @test get_forecasts_resolution(sys) == Dates.Hour(1)  # TODO

    for forecast in forecasts
        remove_forecast!(sys, forecast)
    end

    # InvalidParameter is thrown if the type is concrete and there is no forecast for a
    # component.
    @test_throws(PowerSystems.InvalidParameter,
                 get_forecasts(Forecast, sys, initial_time, components))

    # But not if the type is abstract.
    new_forecasts = get_forecasts(Forecast, sys, initial_time,
                                  get_components(HydroGen, sys))
    @test length(new_forecasts) == 0

    add_forecasts!(sys, forecasts)

    forecasts = get_forecasts(Forecast, sys, initial_time, components)
    @assert length(forecasts) == count

    pop!(sys.forecasts.data, PowerSystems._ForecastKey(initial_time, Deterministic{Bus}))
    @test_throws(PowerSystems.InvalidParameter,
                 get_forecasts(Deterministic{Bus}, sys, initial_time, components))
end

@testset "Test System iterators" begin
    cdm_dict = PowerSystems.csv2ps_dict(RTS_GMLC_DIR, 100.0)
    sys_rts = PowerSystems._System(cdm_dict)
    rts_da = PowerSystems.make_forecast_array(sys_rts, cdm_dict["forecasts"]["DA"])
    rts_rt = PowerSystems.make_forecast_array(sys_rts, cdm_dict["forecasts"]["RT"])

    PowerSystems.add_forecast!(sys_rts, :DA=>rts_da)
    PowerSystems.add_forecast!(sys_rts, :RT=>rts_rt)

    sys = System(cdm_dict)

    i = 0
    for component in iterate_components(sys)
        i += 1
    end

    components = get_components(Component, sys)
    @test i == length(components)

    i = 0
    for forecast in iterate_forecasts(sys)
        i += 1
    end

    j = 0
    initial_times = get_forecast_initial_times(sys)
    for initial_time in initial_times
        j += length(get_forecasts(Forecast, sys, initial_time))
    end

    @test i == j
end
