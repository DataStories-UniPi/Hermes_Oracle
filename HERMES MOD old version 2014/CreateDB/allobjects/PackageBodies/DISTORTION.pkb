Prompt Package Body DISTORTION;
CREATE OR REPLACE PACKAGE BODY DISTORTION
IS

-- -----------------------------------------------------
-- Procedure distortion_volume
-- -----------------------------------------------------
  PROCEDURE distortion_volume
  IS
    res dpv_nt;
    bids number_nt;

    t1 dpv_nt;
    k NUMBER;
    vol_t NUMBER;
    sum_t NUMBER;

    pos1 NUMBER;
    pos2 NUMBER;
    pos3 NUMBER;
  BEGIN
    SELECT dpv(n.bid, n.nr_of_fakes, m.vol)
      BULK COLLECT INTO res
    FROM h_benchmark_run m
      INNER JOIN
    (
      SELECT hb.bid, hb.qtyp, hb.k_param, hbr.nr_of_fakes, min(hbr.rid) min_rid
      FROM h_benchmark hb
        INNER JOIN h_benchmark_run hbr ON hb.bid = hbr.bid
      WHERE hbr.nr_of_fakes <> 0
      GROUP BY hb.bid, hb.qtyp, hb.k_param, hbr.nr_of_fakes
      ORDER BY hb.bid, hbr.nr_of_fakes
    )n ON m.bid = n.bid AND m.rid = n.min_rid
    ORDER BY n.bid, n.nr_of_fakes;

    SELECT DISTINCT m.bid
      BULK COLLECT INTO bids
    FROM TABLE(res) m
    ORDER BY m.bid;

    pos1 := bids.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      SELECT dpv(m.bid, m.nr_of_fakes, m.vol)
        BULK COLLECT INTO t1
      FROM TABLE(res) m
      WHERE m.bid = bids(pos1)
      ORDER BY m.nr_of_fakes;

      FOR pos2 IN 1..10 LOOP
        vol_t := pos2 / 100;
        sum_t := 0;

        pos3 := t1.FIRST;
        WHILE pos3 IS NOT NULL LOOP
          IF t1(pos3).vol = vol_t THEN
            IF t1.FIRST = pos3 THEN
              sum_t := t1(pos3).nr_of_fakes;
            ELSE
              sum_t := sum_t + (t1(pos3).nr_of_fakes - t1(t1.PRIOR(pos3)).nr_of_fakes);
            END IF;
          END IF;
          pos3 := t1.NEXT(pos3);
        END LOOP;

        SELECT hb.k_param INTO k FROM h_benchmark hb WHERE hb.bid = bids(pos1);
        INSERT INTO dist_vol VALUES (bids(pos1), k, vol_t, sum_t);
      END LOOP;
      pos1 := bids.NEXT(pos1);
    END LOOP;
  END distortion_volume;

END DISTORTION;
/


