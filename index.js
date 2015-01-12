var http = require("http");
var pay =require("./myPay1.js");
var http = require("http");
console.log("sb coming ");
http.createServer(pay.payf).listen(1111);
