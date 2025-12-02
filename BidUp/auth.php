<?php
// auth.php
session_start();
header('Content-Type: application/json');
require_once 'config.php';

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(['success' => false, 'error' => 'Please enter both fields.']);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'error' => 'User not found.']);
    exit;
}

$user = $result->fetch_assoc();

// Since your database uses plain passwords (no hashing yet)
if ($password === $user['password']) {
    $_SESSION['user'] = [
        'user_id' => $user['user_id'],
        'username' => $user['username'],
        'full_name' => $user['full_name'],
        'user_type' => $user['user_type']
    ];
    echo json_encode(['success' => true, 'user' => $_SESSION['user']]);
} else {
    echo json_encode(['success' => false, 'error' => 'Incorrect password.']);
}
?>