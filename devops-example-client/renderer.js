// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

document.querySelector('#btn').addEventListener('click', getData);

function getData() {
    // TODO implements
    document.querySelector('#result').innerHTML = "First release";
}

