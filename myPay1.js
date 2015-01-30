'use strict';
var http = require('http');
var url = require('url');
var pingpp = require('pingpp')('sk_live_POCCqLW9uTe9efjjvTbPqXnT');

function payf(req, res) {
    req.setEncoding('utf-8');
    var post_data = "";
    req.addListener("data", function(chunk) {
        post_data += chunk;
    });
    req.addListener("end", function() {
        var resp = function(ret, http_code) {
            http_code = typeof http_code == "undefined" ? 200 : http_code;
            res.writeHead(http_code, {
                "Content-Type": "application/json;charset=utf-8"
            });
            if (typeof ret != "string") {
                ret = JSON.stringify(ret)
            }
            res.end(ret);
        }
        console.log("some sb coming inside1");
        console.log("dizhishi" + req.url);
        switch (req.url) {
            case "/myPay1.js":
                var client_ip = req.connection.remoteAddress;
                var params;
                try {
                    params = JSON.parse(post_data);
                } catch (err) {
                    return resp({
                        error: "json_parse_error"
                    });
                }
                var channel = params["channel"];
                var amount = params["amount"];
                var order_no = params["order_no"];
                var subject = params["subject"];
                var extra = {};
                console.log(channel + "  " + amount + " " + subject);
                pingpp.charges.create({
                    order_no: order_no,
                    app: {
                        id: "app_0S8yTGrfzH4OSqn1"
                    },
                    channel: channel,
                    amount: amount,
                    client_ip: client_ip,
                    currency: "cny",
                    subject: subject,
                    body: "Your Body",
                    extra: extra
                }, function(err, charge) {
                    if (charge != null) {
                        return resp(charge);
                    }
                    return resp({
                        error: err.raw
                    });
                });
                break;
            case "/noticeFromPlus.js":
                var notify;
                try {
                    notify = JSON.parse(post_data);
                } catch (err) {
                    return resp('fail1');
                }
                if (notify.object === undefined) {
                    return resp('fail2');
                }
                console.log("notice wei:"+notify)
                switch (notify.object) {
                    case "charge":
                        // 开发者在此处加入对支付异步通知的处理代码
                        var opt = {
                            host: '182.254.216.91',
                            port: '2348',
                            method: 'POST',
                            path: '/trans/check_pay',
                            headers: {}
                        }
                        var body = '';
                        var req1 = http.request(opt, function(res) {
                            console.log("Got response: " + res.statusCode);
                            res.on('data', function(d) {
                                body += d;
                            }).on('end', function() {
                                // 读取完成的操作
                            });
                        }).on('error', function(e) {
                            console.log("Got error: " + e.message);
                        })
                        console.log(JSON.stringify(notify));
                        req1.write(JSON.stringify(notify));
                        req1.end();
                        return resp("success");
                    default:
                        return resp("fail3");
                }
                break;
            default:
                resp("", 404);
                break;
        }
    });
}
exports.payf = payf;
