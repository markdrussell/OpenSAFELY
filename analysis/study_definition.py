from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists, filter_codes_by_category

from codelists import *

year_preceding = "2018-03-01"
start_date = "2019-03-01"
end_date = "today"

# Date of first EIA code in primary care record (captures everyone with first EIA code; refine in Stata)
def first_code_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        find_first_match_in_period=True,
        include_month=True,
        include_day=True,
        return_expectations={
            "incidence": 0.99,
            "date": {"earliest": "2018-01-01", "latest": end_date},
        },
    )

# Presence/date of specified comorbidities (first match up to point of EIA code)
def first_comorbidity_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        between=["1900-01-01", "eia_code_date"],
        find_first_match_in_period=True,
        include_month=True,
        include_day=True,
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "1950-01-01", "latest": end_date},
        },
    )

# Presence of medications (first prescription)
def get_medication_for_dates(med_codelist, with_med_func, high_cost, dates):
    if (high_cost):
        date_format="YYYY-MM"
    else:
        date_format="YYYY-MM-DD"
    return with_med_func(
        med_codelist,
        between=dates,
        returning="date",
        date_format=date_format,
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.1,
            "date": {"earliest": start_date, "latest": end_date},
        },
    )

def medication_counts_and_dates(var_name, med_codelist_file, high_cost):
    """
    Generates dictionary of covariates for a medication including counts (or binary flags for high cost drugs) and dates
    Takes a variable prefix and medication codelist filename (minus .csv)
    Returns a dictionary suitable for unpacking into the main study definition
    This will include all five of the items defined in the functions above
    """
    definitions={}
    
    if (med_codelist_file[0:5] == "cross"):
        med_codelist_file = "crossimid-codelists/" + med_codelist_file
    else:
        med_codelist_file = "codelists/" + med_codelist_file
    if (high_cost):
        med_codelist=codelist_from_csv(med_codelist_file + ".csv", system="high_cost_drugs", column="olddrugname")
        with_med_func=patients.with_high_cost_drugs
        high_cost=True
    else:
        if ("medication" in med_codelist_file):
            column_name="snomed_id"
        else:
            column_name="dmd_id"
        med_codelist=codelist_from_csv(med_codelist_file + ".csv", system="snomed", column=column_name)
        with_med_func=patients.with_these_medications
        high_cost=False
    
    med_functions=[get_medication_for_dates, {"dates": ["1900-01-01", end_date]}],

    for (fun, params) in med_functions:
        definitions[var_name] = fun(med_codelist, with_med_func, high_cost, **params)
    return definitions

study = StudyDefinition(
    
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": end_date},
        "rate": "uniform",
        "incidence": 0.5,
    },
 
    # EIA disease codes (note: cross-IMID codes used for PsA and AS - all CTV3)
    eia_code_date=first_code_in_period(eia_diagnosis_codes),
    ra_code_date=first_code_in_period(rheumatoid_arthritis_codes),
    psa_code_date=first_code_in_period(psoriatic_arthritis_codes),
    anksp_code_date=first_code_in_period(ankylosing_spondylitis_codes),

    # Define study population 
    population=patients.satisfying(
            """
            eia_code_date AND
            has_follow_up AND
            (eia_code_date >= 2018-03-01) AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
            has_follow_up=patients.registered_with_one_practice_between(
                "eia_code_date - 1 year", "eia_code_date + 6 months"        
            ),
        ),
    
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/33
    age=patients.age_as_of(
        "eia_code_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/46
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
    prac_id = patients.registered_practice_as_of(
        "eia_code_date",
        returning="pseudo_id",
        return_expectations={
            "rate" : "universal", 
            "int" : {"distribution":"normal", "mean":1500, "stddev":50}
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/54
    stp=patients.registered_practice_as_of(
        "eia_code_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/52
    imd=patients.address_as_of(
        "eia_code_date",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
   
    # Outcomes
    ## First rheumatology outpatient date in the year before EIA diagnosis code appears in GP record
    ## https://github.com/opensafely-core/cohort-extractor/issues/673
    rheum_appt_date=patients.outpatient_appointment_date(
        returning="date",
        find_first_match_in_period=True,
        with_these_treatment_function_codes='410',
        date_format="YYYY-MM-DD",
        between=["eia_code_date - 1 year", "eia_code_date"],
        return_expectations={
            "incidence": 0.9,
            "date": {"earliest": year_preceding, "latest": end_date},
        },
    ),

    ## Rheumatology referral codes (last referral in the year before rheumatology outpatient)
    referral_rheum_prerheum = patients.with_these_clinical_events(
        referral_rheumatology,
        find_last_match_in_period = True,
        between = ["rheum_appt_date - 1 year", "rheum_appt_date"],
        returning = "date",
        date_format = "YYYY-MM-DD",
        return_expectations = {
            "date": {"earliest":year_preceding, "latest":end_date},
            "incidence": 0.9,
        },
    ),

    ## Rheumatology referral codes (last rheum ref in the year before before EIA code)
    referral_rheum_precode = patients.with_these_clinical_events(
        referral_rheumatology,
        find_last_match_in_period = True,
        between = ["eia_code_date - 1 year", "eia_code_date"],
        returning = "date",
        date_format = "YYYY-MM-DD",
        return_expectations = {
            "date": {"earliest":year_preceding, "latest":end_date},
            "incidence": 0.9,
        },
    ),
   
    ## GP consultation date (last appt in the year before rheumatology outpatient)
    last_gp_prerheum_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["rheum_appt_date - 1 year", "rheum_appt_date"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## GP consultation date (last appt in the year before EIA code)
    last_gp_precode_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["eia_code_date - 1 year", "eia_code_date"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## GP consultation date (last appt in the year before rheum ref pre-appt)
    last_gp_refrheum_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["referral_rheum_prerheum - 1 year", "referral_rheum_prerheum"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## GP consultation date (last GP appt in the year before rheum ref pre-code)
    last_gp_refcode_date=patients.with_gp_consultations(
        returning="date",
        find_last_match_in_period=True,
        date_format="YYYY-MM-DD",
        between = ["referral_rheum_precode - 1 year", "referral_rheum_precode"],
        return_expectations={
            "date": {"earliest": year_preceding, "latest": end_date},
            "incidence": 0.9,
        },
    ),

    ## Death
    died_date_ons=patients.died_from_any_cause(
        between=[year_preceding, end_date],
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": start_date}, "incidence": 0.1},
    ),

    # Comorbidities (first comorbidity code before EIA diagnosis date; for bloods, test closest to EIA date chosen)
    chronic_cardiac_disease=first_comorbidity_in_period(chronic_cardiac_disease_codes),
    diabetes=first_comorbidity_in_period(diabetes_codes),
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before="eia_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": end_date},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before="eia_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
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
        on_or_before="eia_code_date",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
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
        include_month=True,
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
            on_or_before="eia_code_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="eia_code_date",
        ),
    ),

    # Medications
    **medication_counts_and_dates("hydroxychloroquine", "opensafely-hydroxychloroquine-medication", False),
    **medication_counts_and_dates("leflunomide", "opensafely-leflunomide-dmd", False),
    **medication_counts_and_dates("methotrexate", "opensafely-methotrexate-oral", False),
    **medication_counts_and_dates("methotrexate_inj", "opensafely-methotrexate-injectable", False),
    **medication_counts_and_dates("sulfasalazine", "opensafely-sulfasalazine-oral-dmd", False),
    **medication_counts_and_dates("abatacept", "opensafely-high-cost-drugs-abatacept", True),
    **medication_counts_and_dates("adalimumab", "opensafely-high-cost-drugs-adalimumab", True),
    **medication_counts_and_dates("baricitinib", "opensafely-high-cost-drugs-baricitinib", True),
    **medication_counts_and_dates("certolizumab", "opensafely-high-cost-drugs-certolizumab", True),
    **medication_counts_and_dates("etanercept", "opensafely-high-cost-drugs-etanercept", True),
    **medication_counts_and_dates("golimumab", "opensafely-high-cost-drugs-golimumab", True),
    **medication_counts_and_dates("guselkumab", "opensafely-high-cost-drugs-guselkumab", True),
    **medication_counts_and_dates("infliximab", "opensafely-high-cost-drugs-infliximab", True),
    **medication_counts_and_dates("ixekizumab", "opensafely-high-cost-drugs-ixekizumab", True),
    **medication_counts_and_dates("methotrexate_hcd", "opensafely-high-cost-drugs-methotrexate", True),
    **medication_counts_and_dates("rituximab", "opensafely-high-cost-drugs-rituximab", True),
    **medication_counts_and_dates("sarilumab", "opensafely-high-cost-drugs-sarilumab", True),
    **medication_counts_and_dates("secukinumab", "opensafely-high-cost-drugs-secukinumab", True),
    **medication_counts_and_dates("tocilizumab", "opensafely-high-cost-drugs-tocilizumab", True),
    **medication_counts_and_dates("tofacitinib", "opensafely-high-cost-drugs-tofacitinib", True),
    **medication_counts_and_dates("upadacitinib", "opensafely-high-cost-drugs-upadacitinib", True),
    **medication_counts_and_dates("ustekinumab", "opensafely-high-cost-drugs-ustekinumab", True),
)