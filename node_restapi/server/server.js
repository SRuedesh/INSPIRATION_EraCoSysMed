const express = require("express");
const apiRouter = require("./routes");
// const exphbs = require("express-handlebars");
const path = require("path");
const db = require("./db");

const app = express();

// // Handlebars
// app.engine("handlebars", exphbs({ defaultLayout: "main" }));
// app.set("view engine", "handlebars");

// // Routes
// app.get("/", (req, res) => res.render("home"));
// app.get("/documentation", (req, res) => res.render("documentation"));
// app.get("/about", (req, res) => res.render("about"));
// app.get("/contact", (req, res) => res.render("contact"));
// app.get("/results", require("./routes"));

// // Set static folder
// app.use(express.static("./public"));
// app.use("/css", express.static(__dirname + "public/css"));

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
