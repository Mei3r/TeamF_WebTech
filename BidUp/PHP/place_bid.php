<?php
// place_bid.php - Updated to prevent owner from bidding
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
    // Get current item details including owner
    $itemQuery = $conn->prepare("SELECT owner_id, current_price, status, title FROM items WHERE item_id = ?");
    $itemQuery->bind_param("i", $item_id);
    $itemQuery->execute();
    $item = $itemQuery->get_result()->fetch_assoc();

    if (!$item) {
        echo json_encode(['success' => false, 'error' => 'Item not found.']);
        exit;
    }

    // Check if user is the owner
    if ($item['owner_id'] == $user_id) {
        echo json_encode(['success' => false, 'error' => 'You cannot bid on your own item.']);
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

    
    $insert = $conn->prepare("INSERT INTO bids (item_id, bidder_id, bid_amount, bid_time) VALUES (?, ?, ?, NOW())");
    $insert->bind_param("iid", $item_id, $user_id, $bid_amount);
    $insert->execute();

    
    $update = $conn->prepare("UPDATE items SET current_price = ? WHERE item_id = ?");
    $update->bind_param("di", $bid_amount, $item_id);
    $update->execute();

    
    $owner_id = $item['owner_id'];
    $item_title = $item['title'];
    $notifMessage = "New bid of ₱" . number_format($bid_amount, 2) . " placed on your item: " . $item_title;
    $notif = $conn->prepare("INSERT INTO notifications (user_id, item_id, message) VALUES (?, ?, ?)");
    $notif->bind_param("iis", $owner_id, $item_id, $notifMessage);
    $notif->execute();

    
    $prevBidQuery = $conn->prepare("
        SELECT bidder_id FROM bids 
        WHERE item_id = ? AND bidder_id != ? 
        ORDER BY bid_amount DESC LIMIT 1
    ");
    $prevBidQuery->bind_param("ii", $item_id, $user_id);
    $prevBidQuery->execute();
    $prevBidResult = $prevBidQuery->get_result();
    
    if ($prevBidder = $prevBidResult->fetch_assoc()) {
        $outbidMsg = "You have been outbid on: " . $item_title;
        $notif2 = $conn->prepare("INSERT INTO notifications (user_id, item_id, message) VALUES (?, ?, ?)");
        $notif2->bind_param("iis", $prevBidder['bidder_id'], $item_id, $outbidMsg);
        $notif2->execute();
    }

    echo json_encode(['success' => true]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>