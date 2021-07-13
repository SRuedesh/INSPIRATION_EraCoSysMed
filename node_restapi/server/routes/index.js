const express = require("express");
const db = require("../db");
const router = express.Router();

var tables = [
  "compounds",
  "compound_properties",
  "demographics",
  "demographics_matcher",
  "events",
  "events_matcher",
  "genes",
  "genetics",
  "observations_matcher",
  "pd_observations",
  "pk_observations",
  "profiles",
  "profile_compounds",
  "profile_compounds_matcher",
  "reference",
];
// REST emdpoints
tables.forEach((value) => {
  router.get(`/${value}/`, async (req, res, next) => {
    try {
      let results = await db.all(`${value}`);
      res.json(results);
    } catch (e) {
      console.log(e);
      res.sendStatus(499);
    }
  });
  router.get(`/${value}/:id`, async (req, res, next) => {
      try {
          let results = await db.one(value, req.params.id);
          res.json(results);
      } catch(e) {
          console.log(e)
          res.sendStatus(499);
      }
  });
});
router.get(`/compound_query/:term`, async (req, res, next) => {
  try {
    let results = await await db.compound_query(req.params.term);
    res.json(results); 
  } catch(e) {
    console.log(e)
    res.sendStatus(499)
  }
});
// views
router.get('/documentation', (req, res) =>
  res.render('documentation')  
);
router.get('/', (req, res) =>
  res.render('home')  
);
router.get('/about', (req, res) =>
  res.render('about')  
);
router.get('/contact', (req, res) =>
  res.render('contact')  
);




// export
module.exports = router;