-- INSPIRATION database for observed pharmacokinetic and pharmacodynamic data
-- CAUTION: Running the script will delete all data in the database.

--
DROP DATABASE IF EXISTS observed_data_db;
--
CREATE DATABASE IF NOT EXISTS observed_data_db
CHARACTER SET utf8
COLLATE utf8_unicode_ci;
USE observed_data_db;
--

CREATE TABLE IF NOT EXISTS reference(
    -- The "reference" table holds relevant information on the source
    -- from which the profile is obtained.
    id INT NOT NULL AUTO_INCREMENT
        COMMENT "Unique reference id.",
    doi VARCHAR(100)
        COMMENT "Document object id, preferred id for journal articles, etc.",
    pmid INT NOT NULL COMMENT "PubMed id.",
    alternative_id VARCHAR(100) COMMENT "Alternative id or link.",
    title VARCHAR(500) COMMENT "Title of the document.",
    first_author VARCHAR(500) COMMENT "First author of the document. Where unavailable, enter responsible organization, agency, or drug manufacturer.",
    reference_type VARCHAR(500) COMMENT "Type of the reference, e.g. journal article, book.",
    publication_year INT NOT NULL COMMENT "Year of the publication of the manuscript.",
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS compound(
    -- This table holds the ids of all compound (analytes and admininistered
    -- compound) and their names.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique compound id.",
    pubchem_id INT NOT NULL COMMENT "PubChem id.",
    compound_name VARCHAR(100) COMMENT "Compound INN.",
    compound_alias VARCHAR(100) COMMENT "Alternative id. Enter when no INN or PubChem id is available or name is confidential.",
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS molecular_weight(
    -- This table holds the molecular weights of the compound necessary for
    -- unit conversion.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique compound property id.",
    compound_id INT NOT NULL COMMENT "Unique compound id. References compound.id.",
    compound_mw FLOAT COMMENT "Numeric value of the molecular weight in g/mol, e.g. 356.34.",
    --
    FOREIGN KEY(compound_id)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS profile(
    -- This table holds the IDs of all profiles stored in the database.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique profile id.",
    reference_id INT NOT NULL COMMENT "Reference id. References reference.id.",
    analyte_id INT NOT NULL COMMENT " Analyte id. References compound.id.",
    start_clocktime TIME COMMENT "Reference clocktime for t = 0 h. Omit when no clocktime is given.",
    profile_type ENUM("PK", "PD") COMMENT "Type of the proile, i.e. PK or PD.",
    --
    FOREIGN KEY(reference_id)
        REFERENCES reference(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(analyte_id)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY (id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS demographic(
    -- This table holds all relevant demographic parameters.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique demographic value id.",
    value_num FLOAT COMMENT "Numeric value of a demographic parameter, e.g. 38.21 for mean population age.",
    value_str VARCHAR(100) COMMENT "Non-numeric value of a demographic parameter, e.g. 'pregnant'.",
    value_unit VARCHAR(100) COMMENT "Unit for the entered demographic parameter, e.g. 'years'.",
    value_dimension VARCHAR(100) COMMENT "Dimension of the demographic parameter, e.g. 'age'.",
    value_type VARCHAR(100) COMMENT "Type of the measure, e.g. 'mean'.",
    value_comment VARCHAR(100) COMMENT "Further description of the demographic parameter.",
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS demographic_matcher(
    -- This table matches demographics to a profile.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique demographic matcher id.",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    demographic_id INT NOT NULL COMMENT "Demographic id. References demographic.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(demographic_id)
        REFERENCES demographic(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS genetic(
    -- This table holds all relevant information on the genetic of an
    -- individual or a population.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique population or individual genetic id.",
    ncbi_gene_id INT NOT NULL COMMENT "NCBI gene id.",
    gene_name VARCHAR(100) COMMENT "Conventional name of the gene, e.g. 'CYP2D6'.",
    value_num FLOAT COMMENT "Numeric value of a genetic parameter, e.g. 100 for the percentage of CYP2D6*1/*1 individuals in the population.",
    value_str VARCHAR(100) COMMENT "Non-numeric value of a genetic parameter, e.g. 'poor metabolizer' for phenotyped poor metabolizers of CYP2D6",
    value_unit VARCHAR(100) COMMENT "Unit for the entered genetic parameter, e.g. %.",
    value_descr VARCHAR(100) COMMENT "Further description of the demographic parameter, e.g. 'genotype'.",
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS genetic_matcher(
    -- This table matches genetic profiles to a profile
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique genetic matcher id.",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    genetic_id INT NOT NULL COMMENT "Genetic id. References genetic.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(genetic_id)
        REFERENCES genetic(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS biomarker_and_covariate(
    -- In this table, biomarkers and covariates are defined
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for the biomarker or covariate.",
    biomarker_covariate_descr VARCHAR(100) COMMENT "Description for the biomarker or covariate.",
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS biomarker_and_covariate_observation(
    -- This table holds information on biomarkers and covariates for an individual or population.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique PK observation id.",
    compound_id INT NOT NULL COMMENT "Identifier of the observed compound. Omit if the biomarker is not a compound. References compound.id.",
    biomarker_covariate_id INT NOT NULL COMMENT "Biomarker/covariate id. References biomarker_and_covariate.id.",
    time_value FLOAT COMMENT "Time point of the observation, e.g. 6 for hours after the first drug administration.",
    time_unit VARCHAR(100) COMMENT "Unit of the entered time, e.g. hours.",
    obs_value FLOAT COMMENT "Numeric observed value, e.g. 24.32 for measured concentration in ng/mL.",
    obs_value_unit VARCHAR(100) COMMENT "Unit of the entered observed value, e.g. 'ng/mL'.",
    obs_value_str VARCHAR(100) COMMENT "Non-numeric observed value.",
    -- TODO: change to preset list of compartments, organs and matrices.
    obs_compartment VARCHAR(100) COMMENT "Observed compartment, e.g. 'Peripheral venous blood'.",
    obs_organ VARCHAR(100) COMMENT "Observed organ, e.g. 'kidney'.",
    obs_matrix VARCHAR(100) COMMENT "Observed matrix.",
    obs_error_value FLOAT COMMENT "Numeric value of the error of the observation. e.g. 3.42.",
    obs_error_unit VARCHAR(100) COMMENT "Unit of the error, e.g. 'ng/mL'.",
    obs_error_descr VARCHAR(100) COMMENT "Description of the error value, e.g. 'geometric standard deviation'",
    obs_value_lloq FLOAT COMMENT "Lower limit of quantification for the observation.",
    obs_value_blq BOOLEAN COMMENT "Value is below lower limit of quantification. Enter True or False. ",
    --
    FOREIGN KEY(compound_id)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(biomarker_covariate_id)
        REFERENCES biomarker_and_covariate(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS biomarker_and_covariate_matcher(
    -- In this table, biomarker/covariate observations are matched to the
    -- corresponding profile.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for the biomarker/covariate observation match.",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    biomarker_and_covariate_observation_id INT NOT NULL COMMENT "Biomarker/covariate observation ID. References biomarker_and_covariate_observation.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(biomarker_and_covariate_observation_id)
        REFERENCES biomarker_and_covariate_observation(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS administration_protocol(
    -- This table holds all the information about administration protocols.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for a single administration. ",
    time_value FLOAT COMMENT "Time point of the drug administration.",
    time_unit VARCHAR(100) COMMENT "Unit of the entered time point, e.g. 'hours'.",
    compound_administered_id INT NOT NULL COMMENT "Identifier of the administered compound. References compound.id.",
    dose FLOAT COMMENT "Numeric value of the event parameter, e.g. 100 for the administered dose in mg",
    dose_unit VARCHAR(100) COMMENT "Unit of the entered event parameter, e.g. 'mg' for dose.",
    formulation VARCHAR(100) COMMENT "Formulation of the administered dose, e.g. 'immediate release tablet'.",
    formulation_descr VARCHAR(100) COMMENT "Other information on the formulation, e.g. brand name and manufacturer.",
    administration_route VARCHAR(100) COMMENT "Route of drug administration, e.g. 'oral'.",
    duration_time_value FLOAT COMMENT "Duration of dosing, e.g. infusion time.",
    duration_time_unit VARCHAR(100) COMMENT "Unit for the duration of dosing.",
    --
    FOREIGN KEY(compound_administered_id)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS administration_protocol_matcher(
    -- In this table, administration protocols are matched to the respective
    -- profiles.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id of the protocol match.",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    administration_protocol_id INT NOT NULL COMMENT "Administration protocol id. References administration_protocol.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(administration_protocol_id)
        REFERENCES administration_protocol(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS meal_protocol(
    -- This table contains all the information on meal protocols.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for a single meal administration.",
    event_id INT NOT NULL COMMENT "Identifier of all meal administrations belonging to a singular profile. References protocols.id.",
    time_value FLOAT COMMENT "Time point of the drug administration.",
    time_unit VARCHAR(100) COMMENT "Unit of the entered time point, e.g.'hours'.",
    calorific_value FLOAT COMMENT "Approximate caloric content of the meal, e.g. 800 kcal.",
    calorific_value_unit VARCHAR(100) COMMENT "Unit of the caloric content of the meal, e.g. 'kcal'.",
    percentage_carbs INT NOT NULL COMMENT "Percentage of carbohydrates per meal.",
    percentage_protein INT NOT NULL COMMENT "Percentage of proteins per meal.",
    percentage_fat INT NOT NULL COMMENT "Percentage of fat per meal.",
    meal_descr VARCHAR(100) COMMENT "Further description of the meal, e.g. 'light meal'.",
    meal_comment VARCHAR(100) COMMENT "Other comments.",
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS meal_protocol_matcher(
    -- In this table, meal protocols are matched to the respective profiles.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for the meal protocol match.",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    meal_protocol_id INT NOT NULL COMMENT "Meal protocol id. References meal_protocol.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(meal_protocol_id)
        REFERENCES meal_protocol(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS observation(
    -- This table holds all relevant information on observations as well as
    -- the observations themself.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique PK observation id. ",
    compound_id INT NOT NULL COMMENT "Identifier of the observed compound. References compound.id.",
    -- TODO: PD-parameter
    time_value FLOAT COMMENT "Time point of the observation, e.g. 6 for hours after the first drug administration.",
    time_unit VARCHAR(100) COMMENT "Unit of the entered time, e.g. hours.",
    obs_value FLOAT COMMENT "Numeric observed value, e.g. 24.32 for measured concentration in ng/mL.",
    obs_value_unit VARCHAR(100) COMMENT "Unit of the entered observed value, e.g. 'ng/mL'.",
    obs_value_comment VARCHAR(100) COMMENT "Non-numeric observed value.",
    -- TODO: change to preset list of compartments, organs and matrices.
    obs_compartment VARCHAR(100) COMMENT "Observed compartment, e.g. 'Peripheral venous blood'.",
    obs_organ VARCHAR(100) COMMENT "Observed organ, e.g. 'kidney'.",
    obs_matrix VARCHAR(100) COMMENT "Observed matrix.",
    obs_error_value FLOAT COMMENT "Numeric value of the error of the observation. e.g. 3.42.",
    obs_error_unit VARCHAR(100) COMMENT "Unit of the error, e.g. 'ng/mL'.",
    obs_error_descr VARCHAR(100) COMMENT "Description of the error value, e.g. 'geometric standard deviation'",
    obs_value_lloq FLOAT COMMENT "Lower limit of quantification for the observation.",
    obs_value_blq BOOLEAN COMMENT "Value is below lower limit of quantification. Enter True or False. ",
    obs_value_descr VARCHAR(100) COMMENT "Description of the observed value, e.g. 'concentration measurement'",
    --
    FOREIGN KEY(compound_id)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS observation_matcher(
    -- In this table, observations are matched to the respective profile.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for the observation match.",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    observation_id INT NOT NULL COMMENT "Observation id. References observation.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(observation_id)
        REFERENCES observation(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ddi_profile_compound(
    -- This table holds all DDI compounds relevant to the profile.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for the profile compound.",
    profile_id INT NOT NULL COMMENT "Group id for all compound relevant for a single profile. References profile_compound_group.id",
    compound_id INT NOT NULL COMMENT "Identifier for the compound. References compound.id.",
    compound_role_ddi ENUM("inhibitor", "inducer", "inhibitor and inducer") COMMENT "If the profile is a DDI, enter the role of the compound, e.g. 'perpetrator'.",
    --
    FOREIGN KEY(compound_id)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS interaction_matcher(
    -- In this table, interaction profiles are matched to the respective
    -- reference profile. Also holds information about the interaction type.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id of the interaction match.",
    effect_profile INT NOT NULL COMMENT "Profile id of the effect profile, e.g., DDI, DGI. References profile.id.",
    reference_profile INT NOT NULL COMMENT "Profile id of the reference profile. References profile.id.",
    -- Specify the type of interaction
    ddi BOOLEAN DEFAULT FALSE COMMENT "True if profile is a DDI profile, False if not.",
    dgi BOOLEAN DEFAULT FALSE COMMENT "True if profile is a DGI profile, False if not.",
    dfi BOOLEAN DEFAULT FALSE COMMENT "True if profile is a DFI profile, False if not.",
    --
    FOREIGN KEY(reference_profile)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(effect_profile)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id),
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS interaction_ratio(
    -- This table holds interaction parameters such as DDI or DGI ratios.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique parameter id.",
    interaction_id INT NOT NULL COMMENT "Identifier of the interaction. References interaction_matcher.id.",
    analyte_id_a INT NOT NULL COMMENT "Identifier of the main analyte. References compound.id.",
    analyte_id_b INT NOT NULL COMMENT "Identifier of an additional analyte, e.g. metabolite in case of a parent/metabolite ratio. Omit, when ratio only refers to one compound.",
    ratio_value FLOAT NOT NULL COMMENT "Value of the ratio.",
    ratio_type ENUM("AUC ratio", "Cmax ratio", "Css ratio") COMMENT "Type of the ratio, e.g. AUC ratio.",
    ratio_error_value FLOAT COMMENT "Numeric value of the error of the ratio.",
    ratio_error_unit VARCHAR(100) COMMENT "Unit of the error of the ratio.",
    ratio_error_type VARCHAR(100) COMMENT "Type of the error. E.g., SD.",
    param_descr1 VARCHAR(100) COMMENT "Description of the ratio.",
    param_descr2 VARCHAR(100) COMMENT "Description of the ratio.",
    --
    FOREIGN KEY(analyte_id_a)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(analyte_id_b)
        REFERENCES compound(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(interaction_id)
        REFERENCES interaction_matcher(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS nca_parameter(
    -- This table stores all relevant NCA parameters.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique id for the nca_parameter.",
    nca_type ENUM("AUC", "Concentration", "Clearance") COMMENT "Type of the NCA parameter, e.g., AUC, Clearance.",
    nca_descr VARCHAR(100) COMMENT "Further description. E.g., steady state, 0-infinite.",
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS nca(
    -- This table contains reported NCA parameters.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique NCA id.",
    nca_parameter_id INT NOT NULL COMMENT "NCA parameter id. References nca_parameter.id.",
    nca_value FLOAT COMMENT "Numeric observed value, e.g. 24.32 for measured concentration in ng/mL.",
    nca_value_unit VARCHAR(100) COMMENT "Unit of the entered observed value, e.g. 'ng/mL'.",
    nca_value_comment VARCHAR(100) COMMENT "Non-numeric observed value.",
    -- TODO: change to preset list of compartments, organs and matrices.
    nca_compartment VARCHAR(100) COMMENT "Observed compartment, e.g. 'Peripheral venous blood'.",
    nca_organ VARCHAR(100) COMMENT "Observed organ, e.g. 'kidney'.",
    nca_matrix VARCHAR(100) COMMENT "Observed matrix.",
    nca_error_value FLOAT COMMENT "Numeric value of the error of the observation. e.g. 3.42.",
    nca_error_unit VARCHAR(100) COMMENT "Unit of the error, e.g. 'ng/mL'.",
    nca_error_descr VARCHAR(100) COMMENT "Description of the error value, e.g. 'geometric standard deviation'",
    --
    FOREIGN KEY(nca_parameter_id)
        REFERENCES nca_parameter(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS nca_matcher(
    -- In this table, NCA values are matched to the respective profiles.
    id INT NOT NULL AUTO_INCREMENT COMMENT "Unique matcher id for noncompartimental analyses",
    profile_id INT NOT NULL COMMENT "Profile id. References profile.id.",
    nca_id INT NOT NULL COMMENT "NCA id. References nca.id.",
    --
    FOREIGN KEY(profile_id)
        REFERENCES profile(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(nca_id)
        REFERENCES nca(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    --
    PRIMARY KEY(id)
    --
) ENGINE=INNODB;
