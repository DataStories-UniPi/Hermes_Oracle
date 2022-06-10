Prompt Type SEM_STBLEAF_ENTRY;
CREATE OR REPLACE type sem_stbleaf_entry as object
(
  -- Attributes
  mbb sem_mbb,
  def_tag varchar2(4),
  epis_tag varchar2(50),
  activ_tag varchar2(50)
)
 alter type sem_stbleaf_entry add attribute tlink ref sub_moving_point cascade
/


