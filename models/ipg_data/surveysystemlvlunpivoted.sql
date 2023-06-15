SELECT * FROM {{ref("surveysystemlvlpivoted")}} PIVOT(sum(num_of_responses) AS num_of_responses, AVG(pct_sa_a) AS pct_sa_a, AVG(pct_sa_only) AS pct_sa_only, AVG(pct_agree_only) AS pct_agree_only
FOR question IN 
('better_understanding_of_ipg_c', 'cfg_i_learned_something_c', 'cfg_valuable_use_of_my_time_c', 'clarity_direction_of_work_ahead_c', 'clear_about_change_we_seek_c', 
'clear_about_roles_and_responsibilities_c', 'confidence_ability_support_instruction_c', 'confident_plan_will_achieve_goals_c', 'confident_plc_leads_to_learning_c', 
'equipped_and_supported_c', 'feel_more_equipped_c', 'logistics_were_smooth_c', 'meeting_helped_make_decisions_c', 'objectives_were_met_c', 'plan_effectively_implemented_c',
 'practice_will_improve_based_on_coaching_c', 'understand_state_of_instruction_c')) 