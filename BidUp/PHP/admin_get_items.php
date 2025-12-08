<?php
header('Content-Type: application/json');
require_once 'config.php';

try {
    $query = "
        SELECT i.item_id, i.title, i.description, i.image_path, i.category,
               i.current_price, i.status, i.created_at, u.full_name
        FROM items i
        JOIN users u ON i.owner_id = u.user_id
        ORDER BY i.created_at DESC
    ";

    $result = $conn->query($query);
    $items = [];

    while ($row = $result->fetch_assoc()) {
        $items[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $items]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>

