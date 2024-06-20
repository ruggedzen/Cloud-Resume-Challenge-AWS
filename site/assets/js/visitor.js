fetch("https://ke1c0veccc.execute-api.us-east-1.amazonaws.com/add_visitor_dynamo_lambda")
    .then(response => response.json())
    .then((data) => {
        document.getElementById('visitor').innerText = data.count
    })