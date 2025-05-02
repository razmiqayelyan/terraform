#!/bin/bash
apt update -y
apt install -y apache2

systemctl enable apache2
systemctl start apache2

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Welcome to ${my_name}'s Site</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f9f9f9;
      color: #333;
      padding: 40px;
      text-align: center;
    }
    h1 {
      color: #e91e63;
    }
    li {
      background: #fff;
      margin: 10px auto;
      padding: 10px;
      width: 280px;
      border-radius: 6px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
  </style>
</head>
<body>
  <h1>Hello from ${my_name} ${last_initial} 👋</h1>
  <p>Here are some cities I've visited:</p>
  <ul>
    %{ for city in visited_cities ~}
      <li>I visited ${city}!</li>
    %{ endfor ~}
  </ul>
</body>
</html>
EOF

systemctl restart apache2
