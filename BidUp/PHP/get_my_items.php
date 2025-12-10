<?php
session_start();
header('Content-Type: application/json');
require_once 'config.php';

if (!isset($_SESSION['user'])) {
    echo json_encode(['success' => false, 'error' => 'Not logged in']);
    exit;
}

$user_id = $_SESSION['user']['user_id'];

try {
    $query = "
    SELECT i.item_id, i.title, i.description, i.image_path, i.category,
    i.starting_price, i.current_price, i.status, i.created_at,
    i.winner_id, w.full_name as winner_name
    FROM items i
    LEFT JOIN users w ON i.winner_id = w.user_id
    WHERE i.owner_id = ?
    ORDER BY i.created_at DESC
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $items = [];
    while ($row = $result->fetch_assoc()) {
        $items[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $items]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>