-- TODO: Add documentation where missing
DROP DATABASE IF EXISTS observed_data_db;
--
CREATE DATABASE IF NOT EXISTS observed_data_db
CHARACTER SET utf8
COLLATE utf8_unicode_ci;
USE observed_data_db;
--
CREATE TABLE IF NOT EXISTS reference(
    -- The "reference" table holds relevant information on the source from which the profile is obtained.
    id INT AUTO_INCREMENT COMMENT "Unique reference identifier. Automatically filled in, increments by 1.",
    doi VARCHAR(100) COMMENT "Document object identifier, preferred identifier for journal articles, etc. Enter where available.",
    pmid INT COMMENT "PubMed identifier. Enter where available.",
    other_identifier VARCHAR(100) COMMENT "Alternative identifier or link. Enter, when no PMID or DOI is available.",
    title VARCHAR(255) COMMENT "Title of the document.",
    first_author VARCHAR(100) COMMENT "First author of the document. Where unavailable, enter responsible organization, agency, or drug manufacturer.",
    reference_type VARCHAR(100) COMMENT "Type of the reference, e.g. journal article, book.",
    publication_year VARCHAR(100) COMMENT "Year of the publication of the manuscript.",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS compound(
    -- This table holds the ids of all compound (analytes and admininistered compound) and their names.
    id INT AUTO_INCREMENT COMMENT "Unique compound identifier. Automatically filled in, increments by 1.",
    pubchem_id INT COMMENT "PubChem identifier. Enter where available.",
    compound_name VARCHAR(100) COMMENT "Compound INN. Enter where available.",
    compound_alias VARCHAR(100) COMMENT "Alternative identifier. Enter when no INN or PubChem identifier is available or name is confidential.",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS molecular_weight(
    -- This table holds the molecular weights of the compound necessary for unit conversion.
    id INT AUTO_INCREMENT COMMENT "Unique compound property identifier. Automatically filled in, increments by 1.",
    compound_id INT COMMENT "Unique compound identifier. References compound.id.",
    compound_mw FLOAT COMMENT "Numeric value of the molecular weight in g/mol, e.g. 356.34.",
    PRIMARY KEY(id),
    FOREIGN KEY(compound_id) REFERENCES compound(id)
);
--
CREATE TABLE IF NOT EXISTS profile(
    --
    id INT AUTO_INCREMENT COMMENT "Unique profile identifier. Automatically filled in, increments by 1.",
    reference_id INT COMMENT "Reference identifier. References reference.id.",
    analyte_id INT COMMENT "",
    start_clocktime TIME COMMENT "Reference clocktime for t = 0 h. Omit when no clocktime is given.",
    profile_type ENUM("PK", "PD") COMMENT "",
    PRIMARY KEY (id),
    FOREIGN KEY(reference_id) REFERENCES reference(id),
    FOREIGN KEY(analyte_id) REFERENCES compound(id)
);
--
CREATE TABLE IF NOT EXISTS demographic(
    -- This table holds all relevant demographic parameters. 
    id INT AUTO_INCREMENT COMMENT "Unique demographic value identifier. Automatically filled in, increments by 1.",
    value_num FLOAT COMMENT "Numeric value of a demographic parameter, e.g. 38.21 for mean population age.",
    value_str VARCHAR(100) COMMENT "Non-numeric value of a demographic parameter, e.g. 'pregnant'.",
    value_unit VARCHAR(100) COMMENT "Unit for the entered demographic parameter, e.g. 'years'.",
    value_dimension VARCHAR(100) COMMENT "Dimension of the demographic parameter, e.g. 'age'.",
    value_type VARCHAR(100) COMMENT "Type of the measure, e.g. 'mean'.",
    value_comment VARCHAR(100) COMMENT "Further description of the demographic parameter.",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS demographic_matcher(
    id INT AUTO_INCREMENT COMMENT "",
    profile_id INT COMMENT "",
    demographic_id INT COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(profile_id) REFERENCES profile(id),
    FOREIGN KEY(demographic_id) REFERENCES demographic(id)
);
--
CREATE TABLE IF NOT EXISTS genetic(
    -- This table holds all relevant information on the genetic of an individual or population.
    id INT AUTO_INCREMENT COMMENT "Unique population or individual genetic identifier. Automatically filled in, increments by 1.",
    ncbi_gene_id INT COMMENT "NCBI gene identifier.",
    gene_name VARCHAR(100) COMMENT "Conventional name of the gene, e.g. 'CYP2D6'.",
    value_num FLOAT COMMENT "Numeric value of a genetic parameter, e.g. 100 for the percentage of CYP2D6*1/*1 individuals in the population.",
    value_str VARCHAR(100) COMMENT "Non-numeric value of a genetic parameter, e.g. 'poor metabolizer' for phenotyped poor metabolizers of CYP2D6",
    value_unit VARCHAR(100) COMMENT "Unit for the entered genetic parameter, e.g. %.",
    value_descr VARCHAR(100) COMMENT "Further description of the demographic parameter, e.g. 'genotype'.",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS genetic_matcher(
    id INT AUTO_INCREMENT COMMENT "",
    profile_id INT COMMENT "",
    genetic_id INT COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(profile_id) REFERENCES profile(id),
    FOREIGN KEY(genetic_id) REFERENCES genetic(id)
);
--
CREATE TABLE IF NOT EXISTS biomarker_and_covariate(
    id INT AUTO_INCREMENT COMMENT "",
    biomarker_covariate_descr VARCHAR(100) COMMENT "",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS biomarker_and_covariate_observation(
    -- This table holds information on biomarkers and covariates for an individual or population.
    id INT AUTO_INCREMENT COMMENT "Unique PK observation identifier. Automatically filled in, increments by 1.",
    compound_id INT COMMENT "Identifier of the observed compound. Omit if the biomarker is not a compound. References compound.id.",
    biomarker_covariate_id INT COMMENT "",
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
    PRIMARY KEY(id),
    FOREIGN KEY(compound_id) REFERENCES compound(id),
    FOREIGN KEY(biomarker_covariate_id) REFERENCES biomarker_and_covariate(id)
);
--
CREATE TABLE IF NOT EXISTS biomarker_and_covariate_matcher(
    id INT AUTO_INCREMENT COMMENT "",
    profile_id INT COMMENT "",
    biomarker_and_covariate_observation_id INT COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(profile_id) REFERENCES profile(id),
    FOREIGN KEY(biomarker_and_covariate_observation_id) REFERENCES biomarker_and_covariate_observation(id)
);
--
CREATE TABLE IF NOT EXISTS administration_protocol(
    --
    id INT AUTO_INCREMENT COMMENT "Unique identifier for a single administration. Automatically filled in, increments by 1.",
    time_value FLOAT COMMENT "Time point of the drug administration.",
    time_unit VARCHAR(100) COMMENT "Unit of the entered time point, e.g. 'hours'.",
    compound_administered_id INT COMMENT "Identifier of the administered compound. References compound.id.",
    dose FLOAT COMMENT "Numeric value of the event parameter, e.g. 100 for the administered dose in mg",
    dose_unit VARCHAR(100) COMMENT "Unit of the entered event parameter, e.g. 'mg' for dose.",
    formulation VARCHAR(100) COMMENT "Formulation of the administered dose, e.g. 'immediate release tablet'.",
    formulation_descr VARCHAR(100) COMMENT "Other information on the formulation, e.g. brand name and manufacturer.",
    administration_route VARCHAR(100) COMMENT "Route of drug administration, e.g. 'oral'.",
    duration_time_value FLOAT COMMENT "",
    duration_time_unit VARCHAR(100) COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(compound_administered_id) REFERENCES compound(id)
);
--
CREATE TABLE IF NOT EXISTS administration_protocol_matcher(
    id INT AUTO_INCREMENT COMMENT "",
    profile_id INT COMMENT "",
    administration_protocol_id INT COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(profile_id) REFERENCES profile(id),
    FOREIGN KEY(administration_protocol_id) REFERENCES administration_protocol(id)
);
--
CREATE TABLE IF NOT EXISTS meal_protocol(
    --
    id INT AUTO_INCREMENT COMMENT "Unique identifier for a single meal administration. Automatically filled in, increments by 1.",
    event_id INT COMMENT "Identifier of all meal administrations belonging to a singular profile. References protocols.id.",
    time_value FLOAT COMMENT "Time point of the drug administration.",
    time_unit VARCHAR(100) COMMENT "Unit of the entered time point, e.g.'hours'.",
    -- TODO: implement clock_time?
    calorific_value FLOAT COMMENT "Approximate caloric content of the meal, e.g. 800 kcal.",
    calorific_value_unit VARCHAR(100) COMMENT "Unit of the caloric content of the meal, e.g. 'kcal'.",
    percentage_carbs INT COMMENT "",
    percentage_protein INT COMMENT "",
    percentage_fat INT COMMENT "",
    meal_descr VARCHAR(100) COMMENT "Further description of the meal, e.g. 'light meal'.",
    meal_comment VARCHAR(100) COMMENT "Other comments.",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS meal_protocol_matcher(
    id INT AUTO_INCREMENT COMMENT "",
    profile_id INT COMMENT "",
    meal_protocol_id INT COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(profile_id) REFERENCES profile(id),
    FOREIGN KEY(meal_protocol_id) REFERENCES meal_protocol(id)
);
--
CREATE TABLE IF NOT EXISTS observation(
    --
    id INT AUTO_INCREMENT COMMENT "Unique PK observation identifier. Automatically filled in, increments by 1.",
    compound_id INT COMMENT "Identifier of the observed compound. References compound.id.",
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
    PRIMARY KEY(id),
    FOREIGN KEY(compound_id) REFERENCES compound(id)
);
--
CREATE TABLE IF NOT EXISTS observation_matcher(
    id INT AUTO_INCREMENT COMMENT "",
    profile_id INT COMMENT "",
    observation_id INT COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(profile_id) REFERENCES profile(id),
    FOREIGN KEY(observation_id) REFERENCES observation(id)
);
--
CREATE TABLE IF NOT EXISTS ddi_profile_compound(
    --
    id INT AUTO_INCREMENT COMMENT "Unique identifier for the profile compound.",
    profile_id INT COMMENT "Group identifier for all compound relevant for a single profile. References profile_compound_group.id",
    compound_id INT COMMENT "Identifier for the compound. References compound.id.",
    compound_role_ddi ENUM("inhibitor", "inducer", "inhibitor and inducer") COMMENT "If the profile is a DDI, enter the role of the compound, e.g. 'perpetrator'.",
    PRIMARY KEY(id),
    FOREIGN KEY(compound_id) REFERENCES compound(id)
);


--
CREATE TABLE IF NOT EXISTS interaction_matcher(
    -- 
    id INT AUTO_INCREMENT COMMENT "",
    effect_profile INT COMMENT "",
    reference_profile INT COMMENT "",
    -- Specify the type of interaction
    ddi BOOLEAN COMMENT "Enter True if profile is a DDI profile, False if not.",
    dgi BOOLEAN COMMENT "Enter True if profile is a DGI profile, False if not.",
    dfi BOOLEAN COMMENT "Enter True if profile is a DFI profile, False if not.",
    PRIMARY KEY(id),
    FOREIGN KEY(reference_profile) REFERENCES profile(id),
    FOREIGN KEY(effect_profile) REFERENCES profile(id)
);
--
CREATE TABLE IF NOT EXISTS interaction_ratio(
    -- This table holds interaction parameters such as DDI or DGI ratios.
    id INT AUTO_INCREMENT COMMENT "Unique parameter identifier. Automatically filled in, increments by 1.",
    interaction_id INT COMMENT "Identifier of the interaction. References interaction_matcher.id.",
    analyte_id_a INT COMMENT "Identifier of the main analyte. References compound.id.",
    analyte_id_b INT COMMENT "Identifier of an additional analyte, e.g. metabolite in case of a parent/metabolite ratio. Omit, when ratio only refers to one compound.",
    ratio_value FLOAT COMMENT "Value of the ratio.",
    ratio_type ENUM("AUC ratio", "Cmax ratio", "Css ratio") COMMENT "",
    ratio_error_value FLOAT COMMENT "",
    ratio_error_unit VARCHAR(100) COMMENT "",
    ratio_error_type VARCHAR(100) COMMENT "",
    param_descr1 VARCHAR(100) COMMENT "",
    param_descr2 VARCHAR(100) COMMENT "",
    PRIMARY KEY(id),
    FOREIGN KEY(analyte_id_a) REFERENCES compound(id),
    FOREIGN KEY(analyte_id_b) REFERENCES compound(id),
    FOREIGN KEY(interaction_id) REFERENCES interaction_matcher(id)
);
--
CREATE TABLE IF NOT EXISTS nca_parameter(
    id INT AUTO_INCREMENT COMMENT "",
    nca_type ENUM("AUC", "Concentration", "Clearance") COMMENT "",
    nca_descr VARCHAR(100) COMMENT "",
    PRIMARY KEY(id)
);
--
CREATE TABLE IF NOT EXISTS nca(
    id INT AUTO_INCREMENT COMMENT "",
    nca_parameter_id INT COMMENT "",
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
    PRIMARY KEY(id),
    FOREIGN KEY(nca_parameter_id) REFERENCES nca_parameter(id)
);
--