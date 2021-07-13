const mysql = require('mysql');
const fs = require('fs');

configPath = 'server/db/config/config.json'
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

const pool = mysql.createPool({
    connectionLimit: 20,
    password: config.development.password,
    user: config.development.user,
    database: config.development.database,
    host: config.development.host,
    port: config.development.port
});

let obs_db = {};

obs_db.all = (table) => {
    return new Promise((resolve, reject) => {
        pool.query(`SELECT * FROM ${table}`, (err, results) =>{
            if(err) {
                return reject(err);
            }
            return resolve(results);
        });
    });
};

obs_db.one = (table, id) => {
    return new Promise((resolve, reject) => {
        pool.query(`SELECT * FROM ${table} WHERE id = ${id}`, (err, results) =>{
            if(err) {
                return reject(err);
            }
            return resolve(results[0]);
        });
    });
};

obs_db.compound_query = (compound_name) => {
    return new Promise((resolve, reject) => {
        pool.query(
          `
            SELECT 
                profiles.id, CONCAT(reference.first_author, ' ', reference.publication_year) AS 'reference', profiles.observation_id, profiles.demographics_id, profiles.event_id
            FROM 
                profiles
            JOIN reference
            ON profiles.reference_id = reference.id           

            WHERE 
                profiles.profile_compounds_id IN (
                SELECT DISTINCT
                    profile_compounds.group_id
                FROM
                    profile_compounds
                WHERE profile_compounds.compound_id IN (
                    SELECT 
                        compounds.id 
                    FROM 
                        compounds
                    WHERE 
                        compounds.compound_name LIKE '%${compound_name}%' OR 
                        compounds.compound_alias LIKE '%${compound_name}%'));`,
          (err, results) => {
            if (err) {
              return reject(err);
            }
            return resolve(results);
          }
        );
    });
};

module.exports = obs_db; 