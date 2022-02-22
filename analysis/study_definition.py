from cohortextractor import StudyDefinition, patients, codelists, codelist_from_csv  # NOQA

from codelists import *

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    index_date=(
        "2019-09-01"
    ),

    population=patients.registered_with_one_practice_between(
        "2019-02-01", "2020-02-01"
    ),
     age=patients.age_as_of(
        "2019-09-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    imd=patients.address_as_of(
        "2020-02-01",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        },
    ),
    imid = patients.with_these_clinical_events(
            ra-sle-psoriasis_codes,
            returning = "binary_flag",
            find_first_match_in_period = True,
            between = [index_date, "today"],
            return_expectations = {"incidence": 0.2}
    )
)