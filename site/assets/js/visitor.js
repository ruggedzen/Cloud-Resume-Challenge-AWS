fetch("https://ekxt6jfn62.execute-api.us-east-1.amazonaws.com/test/visitor")
    .then(response => response.json())
    .then((data) => {
        document.getElementById('visitor').innerText = data.count
    })