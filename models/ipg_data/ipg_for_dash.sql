WITH withnames AS (SELECT av.*, dim.name AS staff_name, dim.cluster FROM {{ref("walkthroughsystemlvl")}} av LEFT OUTER JOIN ip-ipg-data.dimension_table.pmdim dim ON av.new_system = dim.new_system),

withemails AS(SELECT withnames.*, e.email_for_access, e.category FROM withnames LEFT OUTER JOIN ip-ipg-data.dimension_table.email_list AS e ON withnames.staff_name = e.staff_member_)

select * from withemails