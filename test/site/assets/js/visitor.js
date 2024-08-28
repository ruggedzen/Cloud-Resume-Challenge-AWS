const counter = document.querySelector("#visitor");
async function updateCount() {
    let response = await fetch("https://api.test.sheepwithnolegs.com/crc_lambda_test");
    let data = await response.json();
    counter.innerHTML = `${data}`;
}

updateCount();
