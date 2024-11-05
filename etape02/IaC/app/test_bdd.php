<?php
$servername = "data";
$username = "valentin";
$password = "valentinpwd";
$dbname = "testdb";

try {
    // Connexion PDO
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);

    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $conn->exec("CREATE TABLE IF NOT EXISTS test_table (
        id INT AUTO_INCREMENT PRIMARY KEY,
        content VARCHAR(255) NOT NULL
    )");

    $conn->exec("INSERT INTO test_table (content) VALUES ('Hello, World!')");

    $stmt = $conn->query("SELECT content FROM test_table ORDER BY id DESC LIMIT 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        echo "Dernière entrée : " . $row["content"];
    } else {
        echo "Aucune donnée disponible.";
    }
} catch (PDOException $e) {
    echo "Erreur de connexion : " . $e->getMessage();
}

$conn = null;
?>