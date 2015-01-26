'use strict';
var http = require('http');
var url = require('url');
var pingpp = require('pingpp')('sk_live_POCCqLW9uTe9efjjvTbPqXnT');
function payf(req, res) {
  req.setEncoding('utf-8');
  var post_data = "";
  req.addListener("data", function (chunk) {
    post_data += chunk;
  });
  req.addListener("end", function () {
  var resp = function (ret, http_code) {
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
    console.log("dizhishi"+req.url);
    switch (req.url) {
      case "/myPay1.js":
 console.log("dizhishi"+req.url);
var client_ip = req.connection.remoteAddress;
        var params;
        try {
          params = JSON.parse(post_data);
        } catch (err) {
          return resp({error:"json_parse_error"});
        }
        var channel = params["channel"];
        var amount = params["amount"];
        var order_no = params["order_no"];
        var subject=params["subject"];
        var extra = {};
        console.log(channel+"  "+amount+" "+subject);
        switch (channel) {
          case pingpp.channel.ALIPAY_WAP:
            extra = {
              'success_url': 'http://www.yourdomain.com/success',
              'cancel_url': 'http://www.yourdomain.com/cancel'
            };
            break;
          case pingpp.channel.UPMP_WAP:
            extra = {
              'result_url': 'http://www.yourdomain.com/result?code='
            };
            break;
        }
        pingpp.charges.create({
          order_no:  order_no,
          app:       {id: "app_0S8yTGrfzH4OSqn1"},
          channel:   channel,
          amount:    amount,
          client_ip: client_ip,
          currency:  "cny",
          subject:   subject,
          body:      "Your Body",
          extra:     extra
        }, function(err, charge) {
          if (charge != null) {
            return resp(charge);
          }
          return resp({error:err.raw});
        });
        break;
      case "/noticeFromPlus.js":
      var notify;
        try {
          notify = JSON.parse(post_data);
        } catch (err) {
          return resp('fail');
        }
        if (notify.object === undefined) {
          return resp('fail');
        }
        switch (notify.object) {
          case "charge":
            // 开发者在此处加入对支付异步通知的处理代码
            var opt = {
                 host:'182.254.216.91',
                 port:'2348',
                 method:'POST',
                 path:'/trans/check_pay',
                 headers:{

                 }
            }
            var body = '';
            var req = http.request(opt, function(res) {
                console.log("Got response: " + res.statusCode);
                res.on('data',function(d){
                    body += d;
                }).on('end', function(){
                    console.log(res.headers)
                    console.log(body)
                });
            }).on('error', function(e) {
                console.log("Got error: " + e.message);
            })
            req.write(notify);
            req.end();
            return resp("success");
          default:
            return resp("fail");
        }
        break;
      default:
        resp("", 404);
        break;
    }
  });
}
exports.payf=payf;
