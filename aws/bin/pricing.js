const fs = require('fs');

function callback(data) {
    //fs.writeFile("aws-price-list.json", JSON.stringify(data), err => {
    //  console.error(err)
    //})
    //console.log("Wrote file")
    regions = data['config']['regions']
    for (var region_data of regions) {
        region = region_data['region']
        for (var instance_data of region_data['instanceTypes']) {
            for (var size_data of instance_data['sizes']) {
                size = size_data['size']
                cpu = size_data['vCPU']
                mem = size_data['memoryGiB']
                price = size_data['valueColumns'][0]['prices']['USD']
                console.log([region, size, cpu, mem, price].join(","))
            }
        }
    }

}

//const file = fs.createReadStream("aws-price-list.js");
// fs.readFile("aws-price-list.js", 'utf-8', (err, data) => {
//     if (err) {
//         console.error(err)
//         return
//     }
//     //console.log(data)
//     eval(data)
// })

/*
 * The file that is downloaded is a JSONP file, so we `eval` it to invoke
 * the `callback` function above.
 */
let http = require("http")
http.get("http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js", (response) => {
  let data = ''
  response.on('data', (chunk) => {
      console.log("chunk")
      data += chunk
  })
  response.on('end', () => {
      console.log("end")
      eval(data)
  })
})

console.log("Done")

