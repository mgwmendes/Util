
--dependencia dos objetos
select db.*
  from sys."_ACTUAL_EDITION_OBJ" specobj, DBA_SOURCE db
  where db.NAME = specobj.name
   and upper(db.text) like upper('%COMPANY_PERS_ASSIGN_API%')
 and obj# in
       (select dep.d_obj#
          from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep --, sys.objauth$ oa
         where specobj.owner# = 81
           and specobj.name = upper('Company_Pers_Assign_API')
           and dep.p_obj# = specobj.obj#
         group by dep.d_obj#, specobj.name);
              
