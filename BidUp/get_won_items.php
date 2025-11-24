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
               i.owner_id, u.full_name as owner_name, u.email as owner_email,
               p.payment_id, p.transaction_ref, p.payment_status,
               w.full_name as winner_name
        FROM items i
        JOIN users u ON i.owner_id = u.user_id
        LEFT JOIN users w ON i.winner_id = w.user_id
        LEFT JOIN bids b ON b.item_id = i.item_id AND b.bidder_id = ?
        LEFT JOIN payments p ON p.bid_id = (
            SELECT bid_id FROM bids 
            WHERE item_id = i.item_id AND bidder_id = ?
            ORDER BY bid_amount DESC LIMIT 1
        )
        WHERE i.winner_id = ? AND i.status = 'ended'
        GROUP BY i.item_id
        ORDER BY i.created_at DESC
    ";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("iii", $user_id, $user_id, $user_id);
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