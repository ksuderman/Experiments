const fs = require('fs');

function callback(data) {
  console.log("callback")
  fs.writeFile("aws-price-list.json", JSON.stringify(data), err => {
    console.error(err)
  })
  console.log("Wrote file")
}

//const file = fs.createReadStream("aws-price-list.js");
fs.readFile("aws-price-list.js", 'utf-8', (err,data) => {
  if (err) {
    console.error(err)
    return
  }
  //console.log(data)
  eval(data)
})

console.log("Done")

//const request = http.get("http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js", function(response) {
//  eval(response)
//});
