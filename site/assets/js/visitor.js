fetch("https://ekxt6jfn62.execute-api.us-east-1.amazonaws.com/test")//invoke url
    .then(response => response.json())
    .then((data) => {
        document.getElementById('visitor').innerText = data.count
    })