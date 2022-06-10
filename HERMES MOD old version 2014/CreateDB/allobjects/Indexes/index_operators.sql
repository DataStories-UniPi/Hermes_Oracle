/**********************************************************************************/
/**********************Implementation of index operators***************************/
/**********************************************************************************/
--return the moving points that include a certain time point
CREATE OPERATOR contains_timepoint
BINDING (moving_point, tau_tll.d_timepoint_sec) return number
using tbOperator_Functional_Impl.tb_multi_traj_unit_type_func;


/*CREATE OPERATOR check_sorting
BINDING (tmpoint) RETURN INTEGER
WITH INDEX CONTEXT, SCAN CONTEXT tbTree_idxtype_im
USING tbHermes.check_sorting_f;*/

--returns the moving points that intersect with a given geomentry so as to be
CREATE OPERATOR tb_intersects
BINDING (moving_point,MDSYS.SDO_GEOMETRY) return number
using tbOperator_Functional_Impl.tb_ntersects;


--returns the moving points that include a certain time period
CREATE OPERATOR contains_timeperiod
BINDING (moving_point,tau_tll.D_Period_Sec) return number
using tbOperator_Functional_Impl.tb_contains_timeperiod_func;


--returns the moving points that include a temporal element expressed in seconds
CREATE OPERATOR contains_temporal_element
BINDING (moving_point,tau_tll.D_Temp_Element_Sec) return number
using tbOperator_Functional_Impl.tb_contains_Temp_Element_Func;


--return the moving points that include a certain time point
CREATE OPERATOR mp_in_SpatioTemp_Win
BINDING (moving_point, MDSYS.SDO_GEOMETRY,tau_tll.d_period_sec) return number
using tbOperator_Functional_Impl.tb_spatiotemp_wind_func;

