<?php
// get_bidders.php
session_start();
header('Content-Type: application/json');
require_once 'config.php';

$item_id = $_GET['item_id'] ?? '';

if (empty($item_id)) {
  echo json_encode(['success' => false, 'error' => 'Missing item ID']);
  exit;
}

try {
  // Get item details including owner
  $itemStmt = $conn->prepare("
    SELECT i.title, i.owner_id, i.status, u.full_name as owner_name, u.email as owner_email
    FROM items i
    JOIN users u ON i.owner_id = u.user_id
    WHERE i.item_id = ?
  ");
  $itemStmt->bind_param("i", $item_id);
  $itemStmt->execute();
  $itemResult = $itemStmt->get_result();
  $itemData = $itemResult->fetch_assoc();
  
  if (!$itemData) {
    echo json_encode(['success' => false, 'error' => 'Item not found']);
    exit;
  }

  // Get bidders
  $stmt = $conn->prepare("
    SELECT b.bid_id, b.bid_amount, b.bid_time, b.bidder_id, u.full_name, u.username, u.email
    FROM bids b
    JOIN users u ON b.bidder_id = u.user_id
    WHERE b.item_id = ?
    ORDER BY b.bid_amount DESC
  ");
  $stmt->bind_param("i", $item_id);
  $stmt->execute();
  $result = $stmt->get_result();

  $bidders = [];
  while ($row = $result->fetch_assoc()) {
    $bidders[] = $row;
  }

  echo json_encode([
    'success' => true, 
    'data' => $bidders,
    'item_title' => $itemData['title'],
    'owner_id' => $itemData['owner_id'],
    'owner_name' => $itemData['owner_name'],
    'owner_email' => $itemData['owner_email'],
    'status' => $itemData['status']
  ]);
} catch (Exception $e) {
  echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>