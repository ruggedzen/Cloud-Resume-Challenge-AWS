const counter = document.querySelector("#visitor");
async function updateCounter() {
    let response = await fetch("https://6qb9y4bsvb.execute-api.us-east-1.amazonaws.com/crc_lambda");
    let data = await response.json();
    counter.innerHTML = `${data}`;
}

updateCounter();
