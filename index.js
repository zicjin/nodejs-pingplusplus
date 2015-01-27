var http = require("http");
var pay =require("./myPay1.js");
console.log("sb coming ");
http.createServer(pay.payf).listen(1111);
