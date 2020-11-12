***** 2_RedcapCodebook.do *****
/*
Copy/paste code from Redcap's exported Stata do-file. The first few lines (import as delimited) should NOT be copied.
*/

label define inclu_database_ 1 "T93 database" 2 "ALE database" 3 "Lars records" 
label define adrenalectomy_ 1 "Yes" 0 "No" 
label define exclu_diag_ 0 "Adrenal metastasis" 1 "Adrenocortical adenoma (ACA)" 2 "Adrenocortical carcinoma (ACC)" 3 "Pheochromocytoma (PCC)" 4 "Neuroblastoma" 5 "Lymphoma" 6 "Conns tumor" 7 "Hemorrhage" 8 "Cyst" 9 "Myelolipom" 10 "Paraganglioma" 44 "No tumor found in pathology" 55 "Never investigated (pathology)" 66 "Wrong diagnosis code" 77 "Unknown tumor" 88 "Other indication for OP" 
label define adrmet_disc_ 1 "Biopsy" 2 "Autopsy" 
label define inclu_cancer_ 1 "Lung" 2 "Renal" 3 "Oesophagus" 4 "Ventricle" 5 "Colorectal" 6 "Liver" 7 "Pancreas" 8 "Bladder" 9 "Breast" 10 "Cervix" 11 "Prostate" 12 "Thyroid" 13 "Ovarian" 14 "Melanoma" 15 "Mesothelioma" 88 "Unknown" 99 "Other" 
label define immunocancer_ 1 "Adenokarcinoma" 2 "Small cell karcinoma" 3 "Large cell karcinoma" 4 "Combined" 5 "Planocellular karcinoma" 6 "Urothelial karcinoma" 7 "Renal cell karcinoma" 8 "Transitio cellular karcinoma" 9 "Non-small cell karcinoma" 10 "Sarkomatoid karcinoma" 11 "Malignant melanoma" 12 "Low differentiated" 13 "Hepatocellular karcinoma" 14 "Malignant mesothelioma" 15 "Neuroendocrine karcinoma" 16 "Pleomorph karcinoma" 17 "Karcinosarcoma" 18 "Adenosquamous" 19 "Sarcoma" 99 "Unsure" 
label define incidentaloma_ 1 "Likely benign" 2 "Likely metastasis" 3 "Dont know, could be either" 
label define doubt_ 0 "No" 1 "Yes, find health record" 2 "Yes, consult with LR" 
label define ophospital_ 1 "Herlev urologisk" 2 "Rigshospitalet urologisk" 3 "Aarhus mave-tarm" 4 "Aalborg urologisk" 5 "Odense urologisk" 6 "Aarhus urologisk" 99 "Other" 
label define onco_dep_ 1 "Aarhus" 2 "Aalborg" 3 "Herlev" 4 "Rigshospitalet" 5 "Odense" 6 "Herning/Holstebro" 99 "Other" 
label define registry_screening_e_v_0_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define gender_ 0 "Female" 1 "Male" 
label define patient_information_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define biopsymet_ 1 "Yes" 0 "No" 
label define ps_ 1 "0" 2 "1" 3 "2" 4 "3" 5 "4" 
label define asa_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 
label define hospital_ 1 "Aarhus" 2 "Riget" 3 "Glostrup" 4 "Aalborg" 5 "Odense" 6 "Herlev" 99 "Other" 
label define optype_ 1 "Laparoscopic unilateral" 2 "Laparoscopic bilateral" 3 "Conversion" 4 "Open unilateral" 5 "Open bilateral" 6 "Large open tværincision" 7 "Open unilateral+laparoscopic unilateral" 
label define loca_adrmet_ 1 "Left" 2 "Right" 3 "Bilateral" 
label define removal_ 1 "Yes" 0 "No" 
label define compli_during_ 1 "Yes" 0 "No" 
label define compli_during_type___1_ 0 "Unchecked" 1 "Checked" 
label define compli_during_type___2_ 0 "Unchecked" 1 "Checked" 
label define compli_during_type___3_ 0 "Unchecked" 1 "Checked" 
label define compli_during_type___4_ 0 "Unchecked" 1 "Checked" 
label define operation_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define compli_after_ 1 "Yes" 0 "No" 
label define complications___1_ 0 "Unchecked" 1 "Checked" 
label define complications___2_ 0 "Unchecked" 1 "Checked" 
label define complications___3_ 0 "Unchecked" 1 "Checked" 
label define complications___4_ 0 "Unchecked" 1 "Checked" 
label define complications___5_ 0 "Unchecked" 1 "Checked" 
label define complications___6_ 0 "Unchecked" 1 "Checked" 
label define complications___7_ 0 "Unchecked" 1 "Checked" 
label define complications___99_ 0 "Unchecked" 1 "Checked" 
label define transfer_ 1 "Yes" 0 "No" 
label define transfer_depart_ 1 "Transfer to medical department" 2 "Transfer to surgical department" 3 "Transfer to local hospital" 
label define hospitalization_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define cancertype_2_ 1 "Lung" 2 "Renal" 3 "Oesophagus" 4 "Ventricle" 5 "Colorectal" 6 "Liver" 7 "Pancreas" 8 "Bladder" 9 "Breast" 10 "Cervix" 11 "Prostate" 12 "Thyroid" 13 "Ovarian" 14 "Melanoma" 15 "Mesothelioma" 88 "Unknown" 99 "Other" 
label define immunocancer_2_ 1 "Adenokarcinoma" 2 "Small cell karcinoma" 3 "Large cell karcinoma" 4 "Combined" 5 "Planocellular karcinoma" 6 "Urothelial karcinoma" 7 "Renal cell karcinoma" 8 "Transitio cellular karcinoma" 9 "Non-small cell karcinoma" 10 "Sarkomatoid karcinoma" 11 "Malignant melanoma" 12 "Low differentiated" 13 "Hepatocellular karcinoma" 14 "Malignant mesothelioma" 15 "Neuroendocrine karcinoma" 16 "Pleomorph karcinoma" 17 "Karcinosarcoma" 18 "Adenosquamous" 19 "Sarcoma" 20 "Follicular carcinoma" 21 "Merckel cell carcinoma" 22 "Papillary adenokarcinoma" 23 "Seminoma" 99 "Unsure" 
label define synvsmeta_ 1 "Synchronous" 2 "Metachronous" 
label define imaging___1_ 0 "Unchecked" 1 "Checked" 
label define imaging___2_ 0 "Unchecked" 1 "Checked" 
label define imaging___3_ 0 "Unchecked" 1 "Checked" 
label define imaging___4_ 0 "Unchecked" 1 "Checked" 
label define patosizeyesno_ 1 "Yes" 0 "No" 
label define ki67yesno_ 1 "Yes" 0 "No" 
label define pet_ 1 "Yes" 0 "No" 
label define treat_primary_ 1 "Yes" 0 "No" 
label define how_treat_primary_ 1 "Surgical resection" 2 "Curative radiation/chemotherapy" 3 "Radiofrequency ablation" 4 "Cryo-therapy" 5 "Other" 
label define radi_primary_ 0 "No" 1 "Yes" 99 "Unsure" 
label define other_metastasis_ 1 "Yes" 0 "No" 
label define radi_pato_ 1 "Yes" 0 "No" 99 "Unsure" 
label define treat_chemo_ 1 "Yes" 2 "No" 
label define treat_radio_ 1 "Yes" 2 "No" 
label define treat_immuno_ 1 "Yes" 2 "No" 
label define treat_chemo_after_ 1 "Yes" 2 "No" 
label define treat_radio_after_ 1 "Yes" 2 "No" 
label define treat_immuno_after_ 1 "Yes" 2 "No" 
label define cancer_information_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define biochemical_informat_v_1_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define alive_ 1 "Yes" 0 "No" 
label define compli_postop_ 1 "Yes" 0 "No" 
label define compli_postop_type___1_ 0 "Unchecked" 1 "Checked" 
label define compli_postop_type___2_ 0 "Unchecked" 1 "Checked" 
label define compli_postop_type___3_ 0 "Unchecked" 1 "Checked" 
label define compli_postop_type___4_ 0 "Unchecked" 1 "Checked" 
label define compli_postop_type___5_ 0 "Unchecked" 1 "Checked" 
label define compli_postop_type___6_ 0 "Unchecked" 1 "Checked" 
label define diseasefree_ 1 "Yes" 0 "No" 
label define relapse_ 1 "Yes" 0 "No" 
label define discuss_ 1 "Yes" 0 "No" 
label define bloodwork_ 0 "No" 1 "Yes" 2 "Partly" 
label define curative_ 1 "Yes" 0 "No" 
label define follow_up_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 

label values inclu_database inclu_database_
label values adrenalectomy adrenalectomy_
label values exclu_diag exclu_diag_
label values adrmet_disc adrmet_disc_
label values inclu_cancer inclu_cancer_
label values immunocancer immunocancer_
label values incidentaloma incidentaloma_
label values doubt doubt_
label values ophospital ophospital_
label values onco_dep onco_dep_
label values registry_screening_e_v_0 registry_screening_e_v_0_
label values gender gender_
label values patient_information_complete patient_information_complete_
label values biopsymet biopsymet_
label values ps ps_
label values asa asa_
label values hospital hospital_
label values optype optype_
label values loca_adrmet loca_adrmet_
label values removal removal_
label values compli_during compli_during_
label values compli_during_type___1 compli_during_type___1_
label values compli_during_type___2 compli_during_type___2_
label values compli_during_type___3 compli_during_type___3_
label values compli_during_type___4 compli_during_type___4_
label values operation_complete operation_complete_
label values compli_after compli_after_
label values complications___1 complications___1_
label values complications___2 complications___2_
label values complications___3 complications___3_
label values complications___4 complications___4_
label values complications___5 complications___5_
label values complications___6 complications___6_
label values complications___7 complications___7_
label values complications___99 complications___99_
label values transfer transfer_
label values transfer_depart transfer_depart_
label values hospitalization_complete hospitalization_complete_
label values cancertype_2 cancertype_2_
label values immunocancer_2 immunocancer_2_
label values synvsmeta synvsmeta_
label values imaging___1 imaging___1_
label values imaging___2 imaging___2_
label values imaging___3 imaging___3_
label values imaging___4 imaging___4_
label values patosizeyesno patosizeyesno_
label values ki67yesno ki67yesno_
label values pet pet_
label values treat_primary treat_primary_
label values how_treat_primary how_treat_primary_
label values radi_primary radi_primary_
label values other_metastasis other_metastasis_
label values radi_pato radi_pato_
label values treat_chemo treat_chemo_
label values treat_radio treat_radio_
label values treat_immuno treat_immuno_
label values treat_chemo_after treat_chemo_after_
label values treat_radio_after treat_radio_after_
label values treat_immuno_after treat_immuno_after_
label values cancer_information_complete cancer_information_complete_
label values biochemical_informat_v_1 biochemical_informat_v_1_
label values alive alive_
label values compli_postop compli_postop_
label values compli_postop_type___1 compli_postop_type___1_
label values compli_postop_type___2 compli_postop_type___2_
label values compli_postop_type___3 compli_postop_type___3_
label values compli_postop_type___4 compli_postop_type___4_
label values compli_postop_type___5 compli_postop_type___5_
label values compli_postop_type___6 compli_postop_type___6_
label values diseasefree diseasefree_
label values relapse relapse_
label values discuss discuss_
label values bloodwork bloodwork_
label values curative curative_
label values follow_up_complete follow_up_complete_



tostring biopsydate, replace
gen _date_ = date(biopsydate,"YMD")
drop biopsydate
rename _date_ biopsydate
format biopsydate %dM_d,_CY

tostring d_foddato, replace
gen _date_ = date(d_foddato,"YMD")
drop d_foddato
rename _date_ d_foddato
format d_foddato %dM_d,_CY

tostring dateop, replace
gen _date_ = date(dateop,"YMD")
drop dateop
rename _date_ dateop
format dateop %dM_d,_CY

tostring discharge, replace
gen _date_ = date(discharge,"YMD")
drop discharge
rename _date_ discharge
format discharge %dM_d,_CY

tostring primary_date, replace
gen _date_ = date(primary_date,"YMD")
drop primary_date
rename _date_ primary_date
format primary_date %dM_d,_CY

tostring adrenal_enlarge, replace
gen _date_ = date(adrenal_enlarge,"YMD")
drop adrenal_enlarge
rename _date_ adrenal_enlarge
format adrenal_enlarge %dM_d,_CY

tostring pet_date, replace
gen _date_ = date(pet_date,"YMD")
drop pet_date
rename _date_ pet_date
format pet_date %dM_d,_CY

tostring follow_up, replace
gen _date_ = date(follow_up,"YMD")
drop follow_up
rename _date_ follow_up
format follow_up %dM_d,_CY

tostring d_dod, replace
gen _date_ = date(d_dod,"YMD")
drop d_dod
rename _date_ d_dod
format d_dod %dM_d,_CY

tostring relapse_date, replace
gen _date_ = date(relapse_date,"YMD")
drop relapse_date
rename _date_ relapse_date
format relapse_date %dM_d,_CY

label variable record_id "Record ID"
label variable inclu_database "Included from"
label variable cpr "CPR"
label variable adrenalectomy "Adrenalectomy?"
label variable exclu_diag "Adrenal diagnosis based on registry data"
label variable adrmet_disc "Is the diagnosis based on autopsy or biopsy?"
label variable exclu_diag_other "Explanation of other indication"
label variable inclu_cancer "Overall type of primary cancer"
label variable expla_other "What other type of cancer?"
label variable immunocancer "Type of cancer"
label variable biopsydate "Date of biopsy"
label variable incidentaloma "Is the tumor most likely benign or malignant?"
label variable doubt "Case of doubt?"
label variable comment_diag "Comments on diagnosis"
label variable expla_doubt "Explanation of doubt about diagnosis"
label variable ophospital "Where was the patient treated?"
label variable expla_hospital "Explanation of other."
label variable onco_dep "Oncology Department"
label variable expla_onco "Explanation of other"
label variable registry_screening_e_v_0 "Complete?"
label variable d_foddato "Date of birth"
label variable gender "Gender"
label variable height "Height (cm)"
label variable weight "Weight (kg)"
label variable bmi "Calculated Field - BMI"
label variable cci "Charlson Comorbidity Index score https://www.mdcalc.com/charlson-comorbidity-index-cci"
label variable patient_information_complete "Complete?"
label variable dateop "Date of operation"
label variable opage "Age at time of surgery"
label variable biopsymet "Was the metastasis biopsy-verified prior to adrenalectomy?"
label variable ps "Performance-score"
label variable asa "ASA-score"
label variable hospital "Hospital localization at time of surgery"
label variable surgeon "Who was the surgeon?"
label variable optime "Kniv tid (min)"
label variable optype "Type of surgery"
label variable loca_adrmet "Localization of adrenal metastasis"
label variable removal "Removal of more than the adrenal gland?"
label variable surg_remove "What was removed?"
label variable compli_during "Were there complications during surgery?"
label variable compli_during_type___1 "Which complications? (choice=Bleeding)"
label variable compli_during_type___2 "Which complications? (choice=Conversion to open surgery)"
label variable compli_during_type___3 "Which complications? (choice=Lesion of organs)"
label variable compli_during_type___4 "Which complications? (choice=Other)"
label variable compli_during_expla "What other complication?"
label variable operation_complete "Complete?"
label variable discharge "When was the patient discharged from the hospital?"
label variable hospitalization_days "Days of hospitalization after procedure"
label variable compli_after "Complications after operation"
label variable complications___1 "Complications (choice=None)"
label variable complications___2 "Complications (choice=Infection)"
label variable complications___3 "Complications (choice=Bleeding)"
label variable complications___4 "Complications (choice=Urinary)"
label variable complications___5 "Complications (choice=Pulmonary)"
label variable complications___6 "Complications (choice=Abdominal)"
label variable complications___7 "Complications (choice=Delirium)"
label variable complications___99 "Complications (choice=Other)"
label variable compli_expla "Comments to complication"
label variable transfer "Need for transfer to another department?"
label variable transfer_depart "Which department?"
label variable trans_cause "What was the cause of the transfer?"
label variable hospitalization_complete "Complete?"
label variable cancertype_2 "Overall type of primary cancer"
label variable subtype_cancer "Subtype of primary cancer"
label variable immunocancer_2 "Which type of cancer is it?"
label variable primary_date "Date of primary tumor cancer diagnosis?"
label variable synvsmeta "Was the adrenal metastasis found synchronous or metachronus with the finding of the primary tumor?"
label variable adrenal_enlarge "Which date was the first suspicion of an adrenal metastasis (seen through imaging)?"
label variable discovery_adrmet "What was the time difference (days) between discovery of the primary tumor to the discovery of the adrenal metastasis?"
label variable discovery_adrmet_2 "What was the time delay (days) between suspicion of the adrenal metastasis to the adrenalectomy?"
label variable adrenalsize "Imaging size of adrenal metastases prior to surgery? (cm)"
label variable imaging___1 "Which imaging technique was used to determine the size of the adrenal gland? (choice=CT)"
label variable imaging___2 "Which imaging technique was used to determine the size of the adrenal gland? (choice=MR)"
label variable imaging___3 "Which imaging technique was used to determine the size of the adrenal gland? (choice=PET)"
label variable imaging___4 "Which imaging technique was used to determine the size of the adrenal gland? (choice=Other)"
label variable technique "What other technique?"
label variable patosizeyesno "Is the tumorsize mentioned in the pathology report?"
label variable patosize "What was the pathologic size? (cm)"
label variable specisize "What was the specimen size?"
label variable ki67yesno "Is Ki-67 mentioned in the pathology report?"
label variable ki67 "Ki-67 index"
label variable pet "Did the pt. have a PET-scan conducted?"
label variable pet_date "Which date did the pt. have the PET?"
label variable treat_primary "Was the primary tumor curatively treated prior to adrenalectomy?"
label variable how_treat_primary "How was the primary tumor treated?"
label variable radi_primary "Was the primary tumor resected with free tumor margins? (radical)"
label variable other_metastasis "Were there other metastasis at time of adrenalectomy?"
label variable other_met_loc "Where were they located and how many?"
label variable tnm "What was the TNM stage prior to surgery?"
label variable radi_pato "Was the tumor radically removed (confirmed by pathologist)?"
label variable treat_chemo "Chemotherapy"
label variable treat_radio "Radiotherapy"
label variable treat_immuno "Immunotherapy"
label variable chemo_prior "Name of chemotherapy."
label variable radio_prior "Dose of radiotherapy (Gray)."
label variable immuno_prior "Name of immunotherapy."
label variable treat_chemo_after "Chemotherapy"
label variable treat_radio_after "Radiotherapy"
label variable treat_immuno_after "Immunotherapy"
label variable chemo_after "Name of chemotherapy."
label variable radio_after "Dose of radiotherapy (Gray)."
label variable immuno_after "Name of immunotherapy."
label variable cancer_information_complete "Complete?"
label variable crp "P-C-reaktivt protein (mg/L)"
label variable neutro "Neutrofilocytter (10^9/L)"
label variable lympho "Lymphocytes (10^9/L)"
label variable nlr "Neutrophil-to-lymphocyte ratio (NLR)"
label variable trombo "B-Trombocytter (10^9/L)"
label variable ldh "P-Lactatdehydrogenase (U/L)"
label variable na "P-Natrium (mmol/L)"
label variable albumin "P-Albumin (g/L)"
label variable haemo "B-Hæmoglobin (mmol/L)"
label variable bf "P-Basisk fosfatase (U/L)"
label variable alat "P-Alanin aminotransferase (U/L)"
label variable comment_blood "Comments on the blood samples."
label variable biochemical_informat_v_1 "Complete?"
label variable follow_up "The date when this information was updated?"
label variable alive "Is the patient alive?"
label variable d_dod "Which date did the patient die?"
label variable days_alive "Days alive after surgery"
label variable days_alive1 "Days alive after surgery?"
label variable days_alive_biopsy "Days alive after biopsy"
label variable cause_death "Cause of death"
label variable compli_postop "Were there complications from surgery after discharge? (30 days)"
label variable compli_postop_type___1 "Which type of complications? (choice=Pain)"
label variable compli_postop_type___2 "Which type of complications? (choice=Minor wound infection)"
label variable compli_postop_type___3 "Which type of complications? (choice=Wound infection (needed treatment))"
label variable compli_postop_type___4 "Which type of complications? (choice=Hernia)"
label variable compli_postop_type___5 "Which type of complications? (choice=Other)"
label variable compli_postop_type___6 "Which type of complications? (choice=Adrenal insufficiency)"
label variable compli_postop_expla "Which complication?"
label variable diseasefree "Was the patient disease-free after adrenalectomy?"
label variable relapse "Did the patient later on experience a relapse?"
label variable relapse_date "Date of relapse"
label variable location_relapse "Location of relapse?"
label variable discuss "Do you need to discuss pt. with Lars og Andreas?"
label variable question "What do you want to ask?"
label variable bloodwork "Bloodwork missing?"
label variable notespt "Additional notes about patient."
label variable curative "Was the operation debulking?"
label variable follow_up_complete "Complete?"

order record_id inclu_database cpr adrenalectomy exclu_diag adrmet_disc exclu_diag_other inclu_cancer expla_other immunocancer biopsydate incidentaloma doubt comment_diag expla_doubt ophospital expla_hospital onco_dep expla_onco registry_screening_e_v_0 d_foddato gender height weight bmi cci patient_information_complete dateop opage biopsymet ps asa hospital surgeon optime optype loca_adrmet removal surg_remove compli_during compli_during_type___1 compli_during_type___2 compli_during_type___3 compli_during_type___4 compli_during_expla operation_complete discharge hospitalization_days compli_after complications___1 complications___2 complications___3 complications___4 complications___5 complications___6 complications___7 complications___99 compli_expla transfer transfer_depart trans_cause hospitalization_complete cancertype_2 subtype_cancer immunocancer_2 primary_date synvsmeta adrenal_enlarge discovery_adrmet discovery_adrmet_2 adrenalsize imaging___1 imaging___2 imaging___3 imaging___4 technique patosizeyesno patosize specisize ki67yesno ki67 pet pet_date treat_primary how_treat_primary radi_primary other_metastasis other_met_loc tnm radi_pato treat_chemo treat_radio treat_immuno chemo_prior radio_prior immuno_prior treat_chemo_after treat_radio_after treat_immuno_after chemo_after radio_after immuno_after cancer_information_complete crp neutro lympho nlr trombo ldh na albumin haemo bf alat comment_blood biochemical_informat_v_1 follow_up alive d_dod days_alive days_alive1 days_alive_biopsy cause_death compli_postop compli_postop_type___1 compli_postop_type___2 compli_postop_type___3 compli_postop_type___4 compli_postop_type___5 compli_postop_type___6 compli_postop_expla diseasefree relapse relapse_date location_relapse discuss question bloodwork notespt curative follow_up_complete 
set more off
describe
