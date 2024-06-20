const counter = document.querySelector("#visitor");
async function updateCounter() {
    let response = await fetch(" https://ke1c0veccc.execute-api.us-east-1.amazonaws.com/add_visitor_dynamo_lambda");
    let data = await response.json();
    counter.innerHTML = `${data}`;
}

updateCounter();