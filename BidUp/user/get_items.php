<?php
header('Content-Type: application/json');
require_once 'config.php';

try {
    $query = "SELECT item_id, title, description, image_path, category, current_price, status, created_at 
              FROM items 
              WHERE status IN ('active', 'ended', 'approved')
              ORDER BY created_at DESC";
              
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
