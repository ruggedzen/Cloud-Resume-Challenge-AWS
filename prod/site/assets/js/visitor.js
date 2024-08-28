const counter = document.querySelector("#visitor");
async function updateCount() {
    let response = await fetch("https://api.sheepwithnolegs.com/visitor_count");
    let data = await response.json();
    counter.innerHTML = `${data}`;
}

updateCount();
