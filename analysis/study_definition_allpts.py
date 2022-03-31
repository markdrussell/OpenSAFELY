from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists, filter_codes_by_category

from codelists import *

year_preceding = "2018-03-01"
start_date = "2019-03-01"
end_date = "today"

# Presence/date of specified comorbidities
def first_comorbidity_in_period(dx_codelist):
    return patients.with_these_clinical_events(
        dx_codelist,
        returning="date",
        find_first_match_in_period=True,
        on_or_before=start_date,
        include_month=True,
        include_day=True,
        return_expectations={
            "incidence": 0.2,
            "date": {"earliest": "1950-01-01", "latest": start_date},
        },
    )

study = StudyDefinition(
    
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": start_date},
        "rate": "uniform",
        "incidence": 0.5,
    },
 
    # Define study population (filter by EIA code data within Stata)
    population=patients.satisfying(
            """
            has_follow_up AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F")
            """,
            has_follow_up=patients.registered_with_one_practice_between(
                "2018-03-01", "2019-03-01"        
            ),
        ),
    
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/33
    age=patients.age_as_of(
        start_date,
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
        start_date,
        returning="pseudo_id",
        return_expectations={
            "rate" : "universal", 
            "int" : {"distribution":"normal", "mean":1500, "stddev":50}
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/54
    stp=patients.registered_practice_as_of(
        start_date,
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/52
    imd=patients.address_as_of(
        start_date,
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
   
    # Comorbidities
    chronic_cardiac_disease=first_comorbidity_in_period(chronic_cardiac_disease_codes),
    diabetes=first_comorbidity_in_period(diabetes_codes),
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before=start_date,
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": start_date},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before=start_date,
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": start_date},
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
        on_or_before=start_date,
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 100.0, "stddev": 100.0},
            "date": {"latest": start_date},
            "incidence": 0.95,
        },
    ),
    organ_transplant=first_comorbidity_in_period(organ_transplant_codes),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/10
    bmi=patients.most_recent_bmi(
        between = ["2009-03-01", "2019-03-01"],
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
            on_or_before=start_date,
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before=start_date,
        ),
    ),
)
