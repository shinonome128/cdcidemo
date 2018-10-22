// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

// document.querySelector('#btn').addEventListener('click', getData);
// 
// function getData() {
//     // TODO implements
//     document.querySelector('#result').innerHTML = "First release";
// }

// const hostname = '<サーバのグローバルIPアドレス>'  
const hostname = '35.200.27.47'
const remote = require('electron').remote  
  
document.querySelector('#btn').addEventListener('click', getData);  
  
function getData() {  
    const net = remote.net;  
    const request = net.request({  
        method: 'GET',  
        protocol: 'http:',  
        hostname: hostname,  
        port: 80,  
        path: '/example.php'  
    })  
  
    request.on('response', (response) => {  
        document.querySelector('#result').innerHTML  = ""  
        response.on('data', (chunk) => {  
            document.querySelector('#result').innerHTML += chunk  
        })  
    })  
    request.on('error', (err) => {  
        document.querySelector('#result').innerHTML = `ERROR: ${JSON.stringify(err)}`  
    })  
    request.end()  
}  
