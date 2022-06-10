Prompt Package MODEL_TRACLUS;
CREATE OR REPLACE PACKAGE MODEL_TRACLUS
IS

	-- e eps, min_lns minimum lines, smooth_factor smoothing parameter, compression_method compression method, tol tolerance
	PROCEDURE run_traclus(e IN NUMBER, min_lns IN INTEGER, smooth_factor IN INTEGER, compression_method IN NUMBER, tol IN NUMBER);

END MODEL_TRACLUS;
/


