const express = require("express");
const apiRouter = require("./routes");
const path = require("path");
const db = require("./db");

const app = express();


app.use(express.json());
app.use("/api", apiRouter);

app.listen(process.env.PORT || "3000", () => {
  console.log(`Server is running on port: ${process.env.PORT || "3000"}`);
});

// test
app.get("/search", function (req, res) {
  //GET method to access DB and return results in JSON
  let { term } = req.query;
  let results = db.one('compounds', term);
});
