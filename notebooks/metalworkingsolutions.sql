/*
# Metalworking Solutions

Metalworking Solutions is a sheet metal fabricator based in Chattanooga, Tennessee. 
Established in 2006, the company offers laser cutting, punching, bending, welding, finishing, and delivery services and ships over 2 million parts annually. 

You've been provided a dataset of jobs since the beginning of 2023.

A few tips for navigating the database: Each job can have multiple job operations in the job_operations_2023/job_operations_2024 table. 
You can connect the jobs to the job_operations. The jmp_job_id references jmo_job_id in the job_operations_2023/job_operations_2024 tables.  
Jobs can be connected to sales orders through the sales_order_job_links table.  

For your project, your group will be responsible for one of the following sets of questions. Construct an R Shiny app to show your findings.

2. Analyze parts. The part can be identified by the jmp_part_id from the jobs table or the jmp_part_id from the job_operations_2023/job_operations_2024 tables. Here are some questions to get started:    
    a. Break down parts by volume of jobs. Which parts are making up the largest volume of jobs? 
	Which ones are taking the largest amount of production hours (based on the jmo_actual_production_hours in the job_operations tables)?  
    b. How have the parts produced changed over time? Are there any trends? 
	Are there parts that were prominent in 2023 but are no longer being produced or are being produced at much lower volumes in 2024? 
	Have any new parts become more commonly produced over time?  
    c. Are there parts that frequently exceed their planned production hours 
	(determined by comparing the jmo_estimated_production_hours to the jmo_actual_production_hours in the job_operations tables)?  
    d. Are the most high-volume parts also ones that are generating the most revenue per production hour?  
*/

WITH job_ops_parts AS (
	SELECT jmo_part_id, jmo_estimated_production_hours, jmo_completed_production_hours
	FROM job_operations_2023
	WHERE jmo_part_id IS NOT NULL AND jmo_completed_production_hours <> 0 AND jmo_estimated_production_hours <> 0
	UNION ALL
	SELECT jmo_part_id, jmo_estimated_production_hours, jmo_completed_production_hours
	FROM job_operations_2024
	WHERE jmo_part_id IS NOT NULL AND jmo_completed_production_hours <> 0 AND jmo_estimated_production_hours <> 0
	)
SELECT 
	jmo_part_id
	, COUNT(jmo_part_id)
	, ROUND(AVG(jmo_completed_production_hours - jmo_estimated_production_hours)::numeric,2) AS avg_diff
FROM job_ops_parts
WHERE jmo_completed_production_hours - jmo_estimated_production_hours <> 0
GROUP BY jmo_part_id
ORDER BY avg_diff DESC;

--remath estimated hours

WITH blah AS(
	SELECT 
		jmo_job_id
		, jmo_part_id
		, CASE WHEN jmo_standard_factor = 'SP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 3600)::numeric,2)
			WHEN jmo_standard_factor = 'MP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 60)::numeric,2)
			WHEN jmo_standard_factor = 'HP' THEN jmo_production_standard * jmo_operation_quantity
			WHEN jmo_standard_factor = 'PM' AND jmo_production_standard <> 0 THEN ROUND(((jmo_operation_quantity / jmo_production_standard) / 60)::numeric, 2)
			WHEN jmo_standard_factor = 'PH' AND jmo_production_standard <> 0 THEN ROUND((jmo_operation_quantity / jmo_production_standard)::numeric, 2)		
			WHEN jmo_standard_factor ILIKE 'TM' THEN ROUND((jmo_production_standard / 60)::numeric, 2)
			WHEN jmo_standard_factor ILIKE 'TH' THEN jmo_production_standard
			WHEN jmo_standard_factor ILIKE 'TD' THEN ROUND((jmo_production_standard * 24)::numeric,2)
		ELSE 0 END AS reestimated_hours
		, jmo_estimated_production_hours
		, jmo_production_standard
		, jmo_standard_factor
		, jmo_operation_quantity
		, jmo_completed_production_hours
	FROM job_operations_2023
	)
SELECT *
FROM blah
WHERE reestimated_hours IS NULL

WHERE reestimated_hours <> jmo_estimated_production_hours AND jmo_part_id ILIKE '%Y002%'

SELECT jmo_part_id, jmo_production_standard, jmo_standard_factor, jmo_operation_quantity, jmo_estimated_production_hours
FROM job_operations_2023
WHERE jmo_standard_factor = 'PM'

WITH job_ops_parts AS (
	SELECT jmo_part_id, jmo_estimated_production_hours, jmo_completed_production_hours
	FROM job_operations_2023
	WHERE jmo_part_id IS NOT NULL AND jmo_completed_production_hours <> 0 AND jmo_estimated_production_hours <> 0
	UNION ALL
	SELECT jmo_part_id, jmo_estimated_production_hours, jmo_completed_production_hours
	FROM job_operations_2024
	WHERE jmo_part_id IS NOT NULL AND jmo_completed_production_hours <> 0 AND jmo_estimated_production_hours <> 0
	)
SELECT 
	jmo_part_id
	, COUNT(jmo_part_id)
	, ROUND(AVG(jmo_completed_production_hours - jmo_estimated_production_hours)::numeric,2) AS avg_diff
FROM job_ops_parts
WHERE jmo_completed_production_hours - jmo_estimated_production_hours <> 0
GROUP BY jmo_part_id
ORDER BY avg_diff DESC;



-- culling uninteresting columns
SELECT *
FROM job_operations_2023
WHERE jmo_part_id = 'M030-0008'

SELECT jmo_production_rate, COUNT(jmo_job_id)
FROM job_operations_2023
GROUP BY jmo_production_rate

SELECT 
	jmo_job_id
	, jmo_job_assembly_id
	, jmo_job_operation_id
	, jmo_operation_type
	, jmo_plant_id
	, jmo_work_center_id
	, jmo_process_id
	, jmo_process_short_description
	, jmo_quantity_per_assembly
	, jmo_queue_time
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_setup_rate
	, jmo_production_rate
	, jmo_overhead_rate
	, jmo_operation_quantity
	, jmo_quantity_complete
	, jmo_setup_percent_complete
	, jmo_actual_setup_hours
	, jmo_actual_production_hours
	, jmo_quantity_to_inspect
	, jmo_overlap_operation_id
	, jmo_move_time
	, jmo_setup_complete
	, jmo_production_complete
	, jmo_overlap_offset_time
	, jmo_part_id
	, jmo_unit_of_measure --'EA' or null
	, jmo_supplier_organization_id
	, jmo_purchase_order_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_start_date
	, jmo_due_date
	, jmo_start_hour -- each department / job is supposed to scan in
	, jmo_due_hour --ditto above
	, jmo_estimated_production_hours
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
--	, jmo_sfemessage_text -- some silly messages in there
	, jmo_created_date
FROM job_operations_2023

SELECT *
FROM job_operations_2023
WHERE jmo_estimated_unit_cost <> jmo_calculated_unit_cost
	AND jmo_estimated_unit_cost > 0
	AND jmo_calculated_unit_cost > 0

--job ops has close date (when finished cutting) but if someone forgets to close jobs, the system will not auto-complete 
--> shipments as ultimate completetion
-- no inventory build-up (ships as completes)
-- jobs >
-- 10 = laser (cut)
-- 20 = wrap/pack (for shipping)
-- production standard number of TH/SP/etc (total hours, seconds per piece)
-- estimated production hours based off of that, so 25 SP * 2500 quant. = 17.36 -> assume used in quotes
-- shipments = revenue
-- jmo_estimated_unit_cost includes machine setup time (.25 = 15mins)
-- operation quantity = what was ordered
-- quantity complete = what was made 
-- production standard * quantity complete + setup hours

WITH all_ops AS (
	SELECT
	jmo_job_id
	, jmo_job_operation_id
	, jmo_process_short_description
	, jmo_queue_time
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_operation_quantity
	, jmo_estimated_production_hours --jmo_production_standard * jmo_operation_quantity
	, jmo_setup_rate
	, jmo_production_rate
	, jmo_overhead_rate -- what is this??
	, jmo_quantity_complete
	, jmo_actual_setup_hours
	, jmo_actual_production_hours -- this column doesn't make sense
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
	, jmo_move_time
	, jmo_part_id
	, jmo_supplier_organization_id
	, jmo_purchase_order_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_created_date
	FROM job_operations_2023
	UNION ALL
	SELECT
	jmo_job_id
	, jmo_job_operation_id
	, jmo_process_short_description
	, jmo_queue_time
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_operation_quantity
	, jmo_estimated_production_hours --jmo_production_standard * jmo_operation_quantity
	, jmo_setup_rate -- what is this?? either 25 or 0 for everything
	, jmo_production_rate -- what is this?? either 25 or 0 for everything
	, jmo_overhead_rate -- what is this??
	, jmo_quantity_complete
	, jmo_actual_setup_hours
	, jmo_actual_production_hours
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
	, jmo_move_time
	, jmo_part_id
	, jmo_supplier_organization_id
	, jmo_purchase_order_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_created_date
	FROM job_operations_2024
	)
SELECT 
	jmo_part_id
	, COUNT(jmo_part_id)
	, ROUND(AVG(jmo_completed_production_hours - jmo_estimated_production_hours)::numeric,2) AS avg_hour_diff
	, ROUND(AVG(jmo_quantity_complete - jmo_operation_quantity)::numeric,2) AS avg_parts_produced_diff
FROM all_ops
WHERE jmo_completed_production_hours - jmo_estimated_production_hours <> 0
GROUP BY jmo_part_id
ORDER BY avg_hour_diff DESC;	

WITH all_ops AS (
	SELECT
	jmo_job_id
	, jmo_job_operation_id
	, jmo_process_short_description
	, jmo_queue_time
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_operation_quantity
	, jmo_estimated_production_hours --jmo_production_standard * jmo_operation_quantity
	, jmo_quantity_complete
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
	, jmo_move_time
	, jmo_part_id
	, jmo_supplier_organization_id
	, jmo_purchase_order_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_created_date
	FROM job_operations_2023
	UNION ALL
	SELECT
	jmo_job_id
	, jmo_job_operation_id
	, jmo_process_short_description
	, jmo_queue_time
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_operation_quantity
	, jmo_estimated_production_hours --jmo_production_standard * jmo_operation_quantity
--	, jmo_setup_rate -- what is this?? either 25 or 0 for everything
--	, jmo_production_rate -- what is this?? either 25 or 0 for everything
--	, jmo_overhead_rate -- what is this??
	, jmo_quantity_complete
--	, jmo_actual_setup_hours
--	, jmo_actual_production_hours -- this column doesn't make sense
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
	, jmo_move_time
	, jmo_part_id
	, jmo_supplier_organization_id
	, jmo_purchase_order_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_created_date
	FROM job_operations_2024
	)
SELECT *
FROM all_ops
WHERE jmo_part_id = 'V007-1023A'

jmo_job_id = '35695-0007-001'


SELECT *
FROM jobs

WITH shipped AS (
	SELECT sml_job_id, SUM(sml_extended_price_base) AS order_total, SUM(sml_job_quantity_shipped) AS quantity_total
	FROM shipment_lines
	GROUP BY sml_job_id
	)
SELECT DISTINCT sml_job_id, order_total, quantity_total, sml_sodelivery_quantity
FROM shipped
INNER JOIN shipment_lines
USING (sml_job_id)
WHERE sml_job_id IS NOT NULL AND quantity_total <> sml_sodelivery_quantity

SELECT *
FROM shipment_lines
WHERE sml_job_id = '28505-0001-001'

SELECT *
FROM shipments

SELECT *
FROM part_operations

SELECT *
FROM part_assemblies

SELECT jmp_part_id, COUNT(jmp_job_id)
FROM jobs
GROUP BY jmp_part_id

SELECT 
	sml_job_quantity_shipped
	,jmp_order_quantity
	,sml_job_id
	,sml_extended_price_base
	,jmp_part_id
	,sml_created_date
	,jmp_created_date
	,sml_shipped_complete
FROM shipment_lines
INNER JOIN jobs
	ON sml_part_id = jmp_part_id
	AND sml_job_id = jmp_job_id
	WHERE sml_job_quantity_shipped <> jmp_order_quantity
ORDER BY jmp_job_id, jmp_part_id, sml_created_date;

--final edited table w/ ops 23 + 24
SELECT
jmo_job_id AS job_id
, jmo_part_id AS part_id
, jmo_job_operation_id AS op_id
, jmo_process_short_description AS description
, CASE WHEN jmo_process_short_description ILIKE '%LASER%' THEN 'LASER'
	WHEN jmo_process_short_description ILIKE '%WELD%' THEN 'WELD'
	WHEN jmo_process_short_description ILIKE '%WRAP%' OR jmo_process_short_description ILIKE '%PACK%' THEN 'PACK'
	WHEN jmo_process_short_description ILIKE '%BRAKE%' THEN 'PRESS_BRAKE'
	WHEN jmo_process_short_description ILIKE '%GALVANIZE%' THEN 'GALVANIZE'
	WHEN jmo_process_short_description ILIKE '%POWDER%' THEN 'POWDER_COAT'
	WHEN jmo_process_short_description ILIKE '%TRANSFER%' THEN 'PART_TRANSFER'
	WHEN jmo_process_short_description ILIKE '%ZINC%' THEN 'ZINC_PLATE'
	WHEN jmo_process_short_description ILIKE '%SAW%' THEN 'SAW'
	WHEN jmo_process_short_description ILIKE '%MACHIN%' THEN 'MACHINE'
	WHEN jmo_process_short_description ILIKE '%TURRET%' THEN 'TURRET_PUNCH'
	WHEN jmo_process_short_description ILIKE '%SET%' THEN 'SET_UP'
	ELSE 'OTHER' END AS short_description
, jmo_setup_hours AS est_setup_hours
, jmo_production_standard AS prodution_standard
, jmo_standard_factor AS standard_factor
, jmo_operation_quantity AS ordered_quantity
, jmo_estimated_production_hours AS est_hours --jmo_production_standard * jmo_operation_quantity
, CASE WHEN jmo_standard_factor = 'SP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 3600)::numeric,2)
	WHEN jmo_standard_factor = 'MP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 60)::numeric,2)
	WHEN jmo_standard_factor = 'HP' THEN jmo_production_standard * jmo_operation_quantity
	WHEN jmo_standard_factor = 'PM' AND jmo_production_standard <> 0 THEN ROUND(((jmo_operation_quantity / jmo_production_standard) / 60)::numeric, 2)
	WHEN jmo_standard_factor = 'PH' AND jmo_production_standard <> 0 THEN ROUND((jmo_operation_quantity / jmo_production_standard)::numeric, 2)		
	WHEN jmo_standard_factor ILIKE 'TM' THEN ROUND((jmo_production_standard / 60)::numeric, 2)
	WHEN jmo_standard_factor ILIKE 'TH' THEN jmo_production_standard
	WHEN jmo_standard_factor ILIKE 'TD' THEN ROUND((jmo_production_standard * 24)::numeric,2)
ELSE 0 END AS reestimated_hours	
, jmo_quantity_complete AS quantity_complete
, jmo_completed_setup_hours AS completed_setup_hours
, jmo_completed_production_hours AS completed_production_hours
, jmo_estimated_unit_cost AS estimated_unit_cost
, jmo_calculated_unit_cost AS calculated_unit_cost
, jmo_created_date AS created_date
FROM job_operations_2023
UNION ALL
SELECT
jmo_job_id AS job_id
, jmo_part_id AS part_id
, jmo_job_operation_id AS op_id
, jmo_process_short_description AS description
, CASE WHEN jmo_process_short_description ILIKE '%LASER%' THEN 'LASER'
	WHEN jmo_process_short_description ILIKE '%WELD%' THEN 'WELD'
	WHEN jmo_process_short_description ILIKE '%WRAP%' OR jmo_process_short_description ILIKE '%PACK%' THEN 'PACK'
	WHEN jmo_process_short_description ILIKE '%BRAKE%' THEN 'PRESS_BRAKE'
	WHEN jmo_process_short_description ILIKE '%GALVANIZE%' THEN 'GALVANIZE'
	WHEN jmo_process_short_description ILIKE '%POWDER%' THEN 'POWDER_COAT'
	WHEN jmo_process_short_description ILIKE '%TRANSFER%' THEN 'PART_TRANSFER'
	WHEN jmo_process_short_description ILIKE '%ZINC%' THEN 'ZINC_PLATE'
	WHEN jmo_process_short_description ILIKE '%SAW%' THEN 'SAW'
	WHEN jmo_process_short_description ILIKE '%MACHIN%' THEN 'MACHINE'
	WHEN jmo_process_short_description ILIKE '%TURRET%' THEN 'TURRET_PUNCH'
	WHEN jmo_process_short_description ILIKE '%SET%' THEN 'SET_UP'
	ELSE 'OTHER' END AS short_description
, jmo_setup_hours AS est_setup_hours
, jmo_production_standard AS prodution_standard
, jmo_standard_factor AS standard_factor
, jmo_operation_quantity AS ordered_quantity
, jmo_estimated_production_hours AS est_hours --jmo_production_standard * jmo_operation_quantity
, CASE WHEN jmo_standard_factor = 'SP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 3600)::numeric,2)
	WHEN jmo_standard_factor = 'MP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 60)::numeric,2)
	WHEN jmo_standard_factor = 'HP' THEN jmo_production_standard * jmo_operation_quantity
	WHEN jmo_standard_factor = 'PM' AND jmo_production_standard <> 0 THEN ROUND(((jmo_operation_quantity / jmo_production_standard) / 60)::numeric, 2)
	WHEN jmo_standard_factor = 'PH' AND jmo_production_standard <> 0 THEN ROUND((jmo_operation_quantity / jmo_production_standard)::numeric, 2)		
	WHEN jmo_standard_factor ILIKE 'TM' THEN ROUND((jmo_production_standard / 60)::numeric, 2)
	WHEN jmo_standard_factor ILIKE 'TH' THEN jmo_production_standard
	WHEN jmo_standard_factor ILIKE 'TD' THEN ROUND((jmo_production_standard * 24)::numeric,2)
ELSE 0 END AS reestimated_hours	
, jmo_quantity_complete AS quantity_complete
, jmo_completed_setup_hours AS completed_setup_hours
, jmo_completed_production_hours AS completed_production_hours
, jmo_estimated_unit_cost AS estimated_unit_cost
, jmo_calculated_unit_cost AS calculated_unit_cost
, jmo_created_date AS created_date
FROM job_operations_2024

--

WITH all_ops AS (
	SELECT
	jmo_job_id AS job_id
	, jmo_part_id AS part_id
	, jmo_job_operation_id AS op_id
	, jmo_process_short_description AS description
	, CASE WHEN jmo_process_short_description ILIKE '%LASER%' THEN 'LASER'
		WHEN jmo_process_short_description ILIKE '%WELD%' THEN 'WELD'
		WHEN jmo_process_short_description ILIKE '%WRAP%' OR jmo_process_short_description ILIKE '%PACK%' THEN 'PACK'
		WHEN jmo_process_short_description ILIKE '%BRAKE%' THEN 'PRESS_BRAKE'
		WHEN jmo_process_short_description ILIKE '%GALVANIZE%' THEN 'GALVANIZE'
		WHEN jmo_process_short_description ILIKE '%POWDER%' THEN 'POWDER_COAT'
		WHEN jmo_process_short_description ILIKE '%TRANSFER%' THEN 'PART_TRANSFER'
		WHEN jmo_process_short_description ILIKE '%ZINC%' THEN 'ZINC_PLATE'
		WHEN jmo_process_short_description ILIKE '%SAW%' THEN 'SAW'
		WHEN jmo_process_short_description ILIKE '%MACHIN%' THEN 'MACHINE'
		WHEN jmo_process_short_description ILIKE '%TURRET%' THEN 'TURRET_PUNCH'
		WHEN jmo_process_short_description ILIKE '%SET%' THEN 'SET_UP'
		ELSE 'OTHER' END AS short_description
	, jmo_setup_hours AS est_setup_hours
	, jmo_production_standard AS prodution_standard
	, jmo_standard_factor AS standard_factor
	, jmo_operation_quantity AS ordered_quantity
	, jmo_estimated_production_hours AS est_hours --jmo_production_standard * jmo_operation_quantity
	, CASE WHEN jmo_standard_factor = 'SP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 3600)::numeric,2)
		WHEN jmo_standard_factor = 'MP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 60)::numeric,2)
		WHEN jmo_standard_factor = 'HP' THEN jmo_production_standard * jmo_operation_quantity
		WHEN jmo_standard_factor = 'PM' AND jmo_production_standard <> 0 THEN ROUND(((jmo_operation_quantity / jmo_production_standard) / 60)::numeric, 2)
		WHEN jmo_standard_factor = 'PH' AND jmo_production_standard <> 0 THEN ROUND((jmo_operation_quantity / jmo_production_standard)::numeric, 2)		
		WHEN jmo_standard_factor ILIKE 'TM' THEN ROUND((jmo_production_standard / 60)::numeric, 2)
		WHEN jmo_standard_factor ILIKE 'TH' THEN jmo_production_standard
		WHEN jmo_standard_factor ILIKE 'TD' THEN ROUND((jmo_production_standard * 24)::numeric,2)
	ELSE NULL END AS reestimated_hours	
	, jmo_quantity_complete AS quantity_complete
	, jmo_completed_setup_hours AS completed_setup_hours
	, jmo_completed_production_hours AS completed_production_hours
	, jmo_estimated_unit_cost AS estimated_unit_cost
	, jmo_calculated_unit_cost AS calculated_unit_cost
	, jmo_created_date AS created_date
	FROM job_operations_2023
	UNION ALL
	SELECT
	jmo_job_id AS job_id
	, jmo_part_id AS part_id
	, jmo_job_operation_id AS op_id
	, jmo_process_short_description AS description
	, CASE WHEN jmo_process_short_description ILIKE '%LASER%' THEN 'LASER'
		WHEN jmo_process_short_description ILIKE '%WELD%' THEN 'WELD'
		WHEN jmo_process_short_description ILIKE '%WRAP%' OR jmo_process_short_description ILIKE '%PACK%' THEN 'PACK'
		WHEN jmo_process_short_description ILIKE '%BRAKE%' THEN 'PRESS_BRAKE'
		WHEN jmo_process_short_description ILIKE '%GALVANIZE%' THEN 'GALVANIZE'
		WHEN jmo_process_short_description ILIKE '%POWDER%' THEN 'POWDER_COAT'
		WHEN jmo_process_short_description ILIKE '%TRANSFER%' THEN 'PART_TRANSFER'
		WHEN jmo_process_short_description ILIKE '%ZINC%' THEN 'ZINC_PLATE'
		WHEN jmo_process_short_description ILIKE '%SAW%' THEN 'SAW'
		WHEN jmo_process_short_description ILIKE '%MACHIN%' THEN 'MACHINE'
		WHEN jmo_process_short_description ILIKE '%TURRET%' THEN 'TURRET_PUNCH'
		WHEN jmo_process_short_description ILIKE '%SET%' THEN 'SET_UP'
		ELSE 'OTHER' END AS short_description
	, jmo_setup_hours AS est_setup_hours
	, jmo_production_standard AS prodution_standard
	, jmo_standard_factor AS standard_factor
	, jmo_operation_quantity AS ordered_quantity
	, jmo_estimated_production_hours AS est_hours --jmo_production_standard * jmo_operation_quantity
	, CASE WHEN jmo_standard_factor = 'SP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 3600)::numeric,2)
		WHEN jmo_standard_factor = 'MP' THEN ROUND((jmo_production_standard * jmo_operation_quantity / 60)::numeric,2)
		WHEN jmo_standard_factor = 'HP' THEN jmo_production_standard * jmo_operation_quantity
		WHEN jmo_standard_factor = 'PM' AND jmo_production_standard <> 0 THEN ROUND(((jmo_operation_quantity / jmo_production_standard) / 60)::numeric, 2)
		WHEN jmo_standard_factor = 'PH' AND jmo_production_standard <> 0 THEN ROUND((jmo_operation_quantity / jmo_production_standard)::numeric, 2)		
		WHEN jmo_standard_factor ILIKE 'TM' THEN ROUND((jmo_production_standard / 60)::numeric, 2)
		WHEN jmo_standard_factor ILIKE 'TH' THEN jmo_production_standard
		WHEN jmo_standard_factor ILIKE 'TD' THEN ROUND((jmo_production_standard * 24)::numeric,2)
	ELSE NULL END AS reestimated_hours	
	, jmo_quantity_complete AS quantity_complete
	, jmo_completed_setup_hours AS completed_setup_hours
	, jmo_completed_production_hours AS completed_production_hours
	, jmo_estimated_unit_cost AS estimated_unit_cost
	, jmo_calculated_unit_cost AS calculated_unit_cost
	, jmo_created_date AS created_date
	FROM job_operations_2024
	)
SELECT *
FROM all_ops
WHERE job_id LIKE '27648%'


	
SELECT short_short_description, COUNT(jmo_job_id), ROUND(AVG(jmo_completed_production_hours - jmo_estimated_production_hours)::numeric,2) AS avg_diff
FROM all_ops
WHERE jmo_completed_production_hours - jmo_estimated_production_hours <> 0
GROUP BY short_short_description
ORDER BY avg_diff DESC;


-- testing CASE WHEN:
WITH blah AS (
	SELECT
	jmo_job_id
	, jmo_job_operation_id
	, jmo_process_short_description
	, CASE WHEN jmo_process_short_description ILIKE '%LASER%' THEN 'LASER'
		WHEN jmo_process_short_description ILIKE '%WELD%' THEN 'WELD'
		WHEN jmo_process_short_description ILIKE '%WRAP%' OR jmo_process_short_description ILIKE '%PACK%' THEN 'PACK'
		WHEN jmo_process_short_description ILIKE '%BRAKE%' THEN 'BRAKE'
		WHEN jmo_process_short_description ILIKE '%GALVANIZE%' THEN 'GALVANIZE'
		WHEN jmo_process_short_description ILIKE '%POWDER%' THEN 'POWDER_COAT'
		WHEN jmo_process_short_description ILIKE '%TRANSFER%' THEN 'PART_TRANSFER'
		WHEN jmo_process_short_description ILIKE '%ZINC%' THEN 'ZINC_PLATE'
		WHEN jmo_process_short_description ILIKE '%SAW%' THEN 'SAW'
		WHEN jmo_process_short_description ILIKE '%MACHIN%' THEN 'MACHINE'
		WHEN jmo_process_short_description ILIKE '%TURRET%' THEN 'TURRET_PUNCH'
		WHEN jmo_process_short_description ILIKE '%SET%' THEN 'SET_UP'
		END AS short_short_description
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_operation_quantity
	, jmo_estimated_production_hours --jmo_production_standard * jmo_operation_quantity
	, jmo_quantity_complete
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
	, jmo_part_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_created_date
	FROM job_operations_2023
	)
SELECT *
FROM blah
WHERE short_short_description IS NULL

SELECT *
FROM parts
WHERE imp_part_id IN ('F022-0007', 'M030-0004', 'S046-0156', 'S046-0169')