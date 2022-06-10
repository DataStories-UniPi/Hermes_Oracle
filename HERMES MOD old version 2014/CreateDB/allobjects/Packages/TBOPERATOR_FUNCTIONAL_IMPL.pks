Prompt Package TBOPERATOR_FUNCTIONAL_IMPL;
CREATE OR REPLACE PACKAGE tbOperator_Functional_Impl AS
    --This Function corresponds to the unit_type function of Hermes
    --returns 1 if a specific timepoint is included in trajectory of
    --a single moving point
    Function tb_multi_traj_unit_type_Func(mp moving_point, tp tau_tll.d_timepoint_sec) return number;
    --a function that finds the moving points rowids of those moving points that intersect a given geometry
    Function tb_ntersects(mp moving_point,geom MDSYS.SDO_GEOMETRY) return number;
    --a function that returns the moving points that fully contain a given timeperiod
    Function tb_contains_Timeperiod_Func(mp moving_point,tp tau_tll.d_period_sec) return number;
    --a function that returns the moving points that contain all the timeperiods included in the D_Temp_element_sec
    Function tb_contains_Temp_Element_Func(mp moving_point,tp tau_tll.D_Temp_element_sec) return number;
    --a function that returns the moving points itnercecting a given geometry and cosntrained in a certain time period
    Function tb_SpatioTemp_Wind_Func(mp moving_point,geom MDSYS.SDO_GEOMETRY,tp tau_tll.D_Period_sec) return number;
END tbOperator_Functional_Impl;
/


