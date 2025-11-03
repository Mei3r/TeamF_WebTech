<?php
// place_bid.php
header('Content-Type: application/json');
require_once 'config.php';

$item_id = $_POST['item_id'] ?? '';
$user_id = $_POST['user_id'] ?? '';
$bid_amount = $_POST['bid_amount'] ?? '';

if (empty($item_id) || empty($user_id) || empty($bid_amount)) {
    echo json_encode(['success' => false, 'error' => 'Incomplete data.']);
    exit;
}

try {
    // Get current item details
    $itemQuery = $conn->prepare("SELECT current_price, status FROM items WHERE item_id = ?");
    $itemQuery->bind_param("i", $item_id);
    $itemQuery->execute();
    $item = $itemQuery->get_result()->fetch_assoc();

    if (!$item) {
        echo json_encode(['success' => false, 'error' => 'Item not found.']);
        exit;
    }

    if ($item['status'] !== 'active') {
        echo json_encode(['success' => false, 'error' => 'Auction already ended.']);
        exit;
    }

    if ($bid_amount <= $item['current_price']) {
        echo json_encode(['success' => false, 'error' => 'Your bid must be higher than the current price.']);
        exit;
    }

    // Insert bid
    $insert = $conn->prepare("INSERT INTO bids (item_id, user_id, bid_amount, bid_time) VALUES (?, ?, ?, NOW())");
    $insert->bind_param("iid", $item_id, $user_id, $bid_amount);
    $insert->execute();

    // Update item current price
    $update = $conn->prepare("UPDATE items SET current_price = ? WHERE item_id = ?");
    $update->bind_param("di", $bid_amount, $item_id);
    $update->execute();

    echo json_encode(['success' => true]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>

