<?php
session_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');
require_once 'config.php'; // or whatever your connection file is called

if (!isset($_SESSION['user_id'])) {
  echo json_encode(['success' => false, 'error' => 'Not logged in']);
  exit;
}

$user_id = $_SESSION['user_id'];
$item_id = intval($_GET['item_id'] ?? 0);
$action  = $_GET['action'] ?? '';

if ($action !== 'end') {
  echo json_encode(['success' => false, 'error' => 'Invalid action']);
  exit;
}

// ✅ Check if the logged-in user owns this item
$check = $conn->prepare("SELECT owner_id FROM items WHERE item_id = ?");
$check->bind_param("i", $item_id);
$check->execute();
$result = $check->get_result();
$item = $result->fetch_assoc();

if (!$item) {
  echo json_encode(['success' => false, 'error' => 'Item not found']);
  exit;
}

if ($item['owner_id'] != $user_id) {
  echo json_encode(['success' => false, 'error' => 'Permission denied']);
  exit;
}

// ✅ End the auction
$stmt = $conn->prepare("UPDATE items SET status = 'ENDED' WHERE item_id = ?");
$stmt->bind_param("i", $item_id);

if ($stmt->execute()) {
  echo json_encode(['success' => true]);
} else {
  echo json_encode(['success' => false, 'error' => 'Database update failed']);
}
?>
