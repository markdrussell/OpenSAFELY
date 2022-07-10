from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists, filter_codes_by_category

from codelists import *

year_preceding = "2018-04-01"
start_date = "2019-04-01"
end_date = "today"

# Date of first EIA code in primary care record
def first_code_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.99,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    )

# Presence/date of specified comorbidities (first match up to point of EIA code)
def first_comorbidity_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        between = ["1900-01-01", "eia_code_date"],
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "1950-01-01", "latest": end_date},
        },
    )

# Presence of medications (first prescription date)
def get_medication_for_dates(med_codelist, with_med_func, high_cost, dates):
    if (high_cost):
        date_format="YYYY-MM"
    else:
        date_format="YYYY-MM-DD"
    return with_med_func(
        med_codelist,
        between = dates,
        returning="date",
        date_format=date_format,
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": start_date, "latest": end_date},
        },
    )

# Medication count
def get_medcounts_for_dates(med_codelist, with_med_func, high_cost, dates):
    if (high_cost):
        returning="number_of_matches_in_period"
    else:
        returning="number_of_matches_in_period"
    return with_med_func(
        med_codelist,
        between = dates,
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.2,
        },
    )    

def medication_dates(var_name, med_codelist_file, high_cost, return_count):
    """
    Generates dictionary of covariates for a medication and dates
    Takes a variable prefix and medication codelist filename (minus .csv)
    Returns a dictionary suitable for unpacking into the main study definition
    This will include all of the items defined in the functions above
    """
    definitions={}
    
    med_codelist_file = "codelists/" + med_codelist_file
    if (high_cost):
        med_codelist=codelist_from_csv(med_codelist_file + ".csv", system="high_cost_drugs", column="olddrugname")
        with_med_func=patients.with_high_cost_drugs
        high_cost=True
    else:
        if ("hydroxychloroquine" in med_codelist_file):
            column_name="snomed_id"
        else:
            column_name="dmd_id"
        med_codelist=codelist_from_csv(med_codelist_file + ".csv", system="snomed", column=column_name)
        with_med_func=patients.with_these_medications
        high_cost=False
    
    med_functions=[
        ("date", get_medication_for_dates, {"dates": ["1900-01-01", end_date]}),
    ]
    if (return_count):
        med_functions += [("count", get_medcounts_for_dates, {"dates": ["1900-01-01", end_date]})]
    for (suffix, fun, params) in med_functions:
        definitions[var_name + "_" + suffix] = fun(med_codelist, with_med_func, high_cost, **params)
    return definitions

study = StudyDefinition(
    
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": end_date},
        "rate": "uniform",
        "incidence": 0.5,
    },
 
    # EIA disease codes
    eia_code_date=first_code_in_period(eia_diagnosis_codes),
    ra_code_date=first_code_in_period(rheumatoid_arthritis_codes),
    psa_code_date=first_code_in_period(psoriatic_arthritis_codes),
    anksp_code_date=first_code_in_period(ankylosing_spondylitis_codes),
    undiff_code_date=first_code_in_period(undifferentiated_arthritis_codes),

    # First rheumatology outpatient date in the 12 months before EIA diagnosis code appears in GP record (original)
    rheum_appt1st_date=patients.outpatient_appointment_date(
        returning="date",
        find_first_match_in_period=True,
        with_these_treatment_function_codes = ["410"],
        date_format="YYYY-MM-DD",
        between = ["eia_code_date - 1 year", "eia_code_date + 60 days"],
        return_expectations={
            "incidence": 0.9,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    ),

    # First rheumatology outpatient date in the 12 months before EIA diagnosis code appears in GP record (with first option ticked)
    rheum_appt_date=patients.outpatient_appointment_date(
        returning="date",
        find_first_match_in_period=True,
        is_first_attendance=True,
        with_these_treatment_function_codes = ["410"],
        date_format="YYYY-MM-DD",
        between = ["eia_code_date - 1 year", "eia_code_date + 60 days"],
        return_expectations={
            "incidence": 0.9,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    ),

    # First rheumatology outpatient date in the 6 months before EIA diagnosis code appears in GP record
    rheum_appt2_date=patients.outpatient_appointment_date(
        returning="date",
        find_first_match_in_period=True,
        with_these_treatment_function_codes = ["410"],
        date_format="YYYY-MM-DD",
        between = ["eia_code_date - 6 months", "eia_code_date + 60 days"],
        return_expectations={
            "incidence": 0.9,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    ),
    
    # First rheumatology outpatient date in the 2 years before EIA diagnosis code appears in GP record
    rheum_appt3_date=patients.outpatient_appointment_date(
        returning="date",
        find_first_match_in_period=True,
        with_these_treatment_function_codes = ["410"],
        date_format="YYYY-MM-DD",
        between = ["eia_code_date - 2 years", "eia_code_date + 60 days"],
        return_expectations={
            "incidence": 0.9,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    ),

    # Rheumatology outpatient count in the 1 year before EIA diagnosis code appears in GP record
    rheum_appt_count=patients.outpatient_appointment_date(
        returning="number_of_matches_in_period",
        with_these_treatment_function_codes = ["410"],
        between = ["eia_code_date - 1 years", "eia_code_date"],
        return_expectations={
            "incidence": 0.9,
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
        },
    ),    

    # Define study population 
    population=patients.satisfying(
            """
            eia_code_date AND
            has_follow_up AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
            has_follow_up=patients.registered_with_one_practice_between(
                "eia_code_date - 1 year", "eia_code_date"        
            ),
        ),
    
    has_6m_follow_up=patients.registered_with_one_practice_between(
            start_date = "rheum_appt_date", 
            end_date = "rheum_appt_date + 6 months",
            return_expectations={"incidence": 0.95}       
    ),

    has_12m_follow_up=patients.registered_with_one_practice_between(
            start_date = "rheum_appt_date", 
            end_date = "rheum_appt_date + 1 year",
            return_expectations={"incidence": 0.90}       
    ),

    age=patients.age_as_of(
        "eia_code_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"1": 0.5, "2": 0.2, "3": 0.1, "4": 0.1, "5": 0.1}},
            "incidence": 0.75,
        },
    ),
    stp=patients.registered_practice_as_of(
        "eia_code_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    region=patients.registered_practice_as_of(
        "eia_code_date",
        returning="nuts1_region_name",
        return_expectations={
            "incidence": 0.99,
            "category": {
            "ratios": {
                "North East": 0.1,
                "North West": 0.1,
                "South West": 0.1,
                "Yorkshire and The Humber": 0.1,
                "East Midlands": 0.1,
                "West Midlands": 0.1,
                "East": 0.1,
                "London": 0.2,
                "South East": 0.1,
                },
            },
        },    
    ),
    imd=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "eia_code_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
    ),
   
    # Outcomes
    ## Rheumatology referral codes (last referral in the 2 years before rheumatology outpatient)
    referral_rheum_prerheum = patients.with_these_clinical_events(
        referral_rheumatology,
        find_last_match_in_period = True,
        between = ["rheum_appt_date - 2 years", "rheum_appt_date"],
        returning = "date",
        date_format = "YYYY-MM-DD",
        return_expectations = {
            "date": {"earliest":year_preceding, "latest":end_date},
            "incidence": 0.9,
        },
    ),

    ## Rheumatology referral codes (last rheum ref in the 2 years before before EIA code)
    referral_rheum_precode = patients.with_these_clinical_events(
        referral_rheumatology,
        find_last_match_in_period = True,
        between = ["eia_code_date - 2 years", "eia_code_date"],
        returning = "date",
        date_format = "YYYY-MM-DD",
        return_expectations = {
            "date": {"earliest":year_preceding, "latest":end_date},
            "incidence": 0.9,
        },
    ),
   
    ## GP consultation date (last appt in the 2 years before rheumatology outpatient)
    last_gp_prerheum_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["rheum_appt_date - 2 years", "rheum_appt_date"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## GP consultation date (last appt in the 2 years before EIA code)
    last_gp_precode_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["eia_code_date - 2 years", "eia_code_date"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## GP consultation date (last appt in the 2 years before rheum ref pre-appt)
    last_gp_refrheum_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["referral_rheum_prerheum - 2 years", "referral_rheum_prerheum"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## GP consultation date (last GP appt in the 2 years before rheum ref pre-code)
    last_gp_refcode_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["referral_rheum_precode - 2 years", "referral_rheum_precode"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## Death
    died_date_ons=patients.died_from_any_cause(
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": start_date}, "incidence": 0.1},
    ),

    # Comorbidities (first comorbidity code prior to EIA code date; for bloods, test closest to EIA date chosen)
    chronic_cardiac_disease=first_comorbidity_in_period(chronic_cardiac_disease_codes),
    diabetes=first_comorbidity_in_period(diabetes_codes),
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before = "eia_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"latest": end_date},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before = "eia_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"latest": end_date},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),
    hypertension=first_comorbidity_in_period(hypertension_codes),
    chronic_respiratory_disease=first_comorbidity_in_period(chronic_respiratory_disease_codes),
    copd=first_comorbidity_in_period(copd_codes),
    chronic_liver_disease=first_comorbidity_in_period(chronic_liver_disease_codes),
    stroke=first_comorbidity_in_period(stroke_codes),
    lung_cancer=first_comorbidity_in_period(lung_cancer_codes),
    haem_cancer=first_comorbidity_in_period(haem_cancer_codes),
    other_cancer=first_comorbidity_in_period(other_cancer_codes),
    esrf=first_comorbidity_in_period(ckd_codes),
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before = "eia_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        date_format="YYYY-MM",
        return_expectations={
            "float": {"distribution": "normal", "mean": 100.0, "stddev": 100.0},
            "date": {"latest": end_date},
            "incidence": 0.95,
        },
    ),
    organ_transplant=first_comorbidity_in_period(organ_transplant_codes),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/10
    bmi=patients.most_recent_bmi(
        between = ["eia_code_date - 10 years", "eia_code_date"],
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        date_format="YYYY-MM",
        return_expectations={
            "incidence": 0.6,
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
        },
    ),

    # Smoking
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (    
                       most_recent_smoking_code = 'N' AND ever_smoked   
                     )  
                """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before = "eia_code_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before = "eia_code_date",
        ),
    ),

    # Medications dates 
    **medication_dates("hydroxychloroquine", "opensafely-hydroxychloroquine", False, True),
    **medication_dates("leflunomide", "opensafely-leflunomide-dmd", False, True),
    **medication_dates("methotrexate", "opensafely-methotrexate-oral", False, True),
    **medication_dates("methotrexate_inj", "opensafely-methotrexate-injectable", False, True),
    **medication_dates("sulfasalazine", "opensafely-sulfasalazine-oral-dmd", False, True),
    **medication_dates("abatacept", "opensafely-high-cost-drugs-abatacept", True, False),
    **medication_dates("adalimumab", "opensafely-high-cost-drugs-adalimumab", True, False),
    **medication_dates("baricitinib", "opensafely-high-cost-drugs-baricitinib", True, False),
    **medication_dates("certolizumab", "opensafely-high-cost-drugs-certolizumab", True, False),
    **medication_dates("etanercept", "opensafely-high-cost-drugs-etanercept", True, False),
    **medication_dates("golimumab", "opensafely-high-cost-drugs-golimumab", True, False),
    **medication_dates("guselkumab", "opensafely-high-cost-drugs-guselkumab", True, False),
    **medication_dates("infliximab", "opensafely-high-cost-drugs-infliximab", True, False),
    **medication_dates("ixekizumab", "opensafely-high-cost-drugs-ixekizumab", True, False),
    **medication_dates("methotrexate_hcd", "opensafely-high-cost-drugs-methotrexate", True, False),
    **medication_dates("rituximab", "opensafely-high-cost-drugs-rituximab", True, False),
    **medication_dates("sarilumab", "opensafely-high-cost-drugs-sarilumab", True, False),
    **medication_dates("secukinumab", "opensafely-high-cost-drugs-secukinumab", True, False),
    **medication_dates("tocilizumab", "opensafely-high-cost-drugs-tocilizumab", True, False),
    **medication_dates("tofacitinib", "opensafely-high-cost-drugs-tofacitinib", True, False),
    **medication_dates("upadacitinib", "opensafely-high-cost-drugs-upadacitinib", True, False),
    **medication_dates("ustekinumab", "opensafely-high-cost-drugs-ustekinumab", True, False),
)