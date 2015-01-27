var http = require("http");
var http = require("http");
http.createServer(payf()).listen(1112);
function payf(req, res) {
    req.setEncoding('utf-8');
   req.addListener("data", function(chunk) {
        post_data += chunk;
    });
    req.addListener("end", function() {
       console.log("dizhishi" + req.url);
    }

        var opt = {
                            host: '115.159.46.34',
                            port: '1111',
                            method: 'POST',
                            path: '/noticeFromPlus.js',
                            headers: {}
                        }
        var body = '';
        var req = http.request(opt, function(res) {
                            console.log("Got response: " + res.statusCode);
                            res.on('data', function(d) {
                                body += d;
                            }).on('end', function() {
                                console.log(res.headers)
                                console.log(body)
                            });
                        }).on('error', function(e) {
                            console.log("Got error: " + e.message);
                        })

}
