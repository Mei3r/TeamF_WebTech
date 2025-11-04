<?php
// update_item_status.php
header('Content-Type: application/json');
require_once 'config.php';

$item_id = $_POST['item_id'] ?? '';
$action = $_POST['action'] ?? '';

if (empty($item_id) || empty($action)) {
    echo json_encode(['success' => false, 'error' => 'Missing data.']);
    exit;
}

try {
    if ($action === 'approve') {
        $stmt = $conn->prepare("UPDATE items SET status = 'active' WHERE item_id = ?");
        $stmt->bind_param("i", $item_id);
        $stmt->execute();
        echo json_encode(['success' => true, 'message' => 'Item approved and now active.']);
    } elseif ($action === 'reject') {
        $stmt = $conn->prepare("UPDATE items SET status = 'rejected' WHERE item_id = ?");
        $stmt->bind_param("i", $item_id);
        $stmt->execute();
        echo json_encode(['success' => true, 'message' => 'Item rejected successfully.']);
    } elseif ($action === 'end') {
        // End auction
        $stmt = $conn->prepare("UPDATE items SET status = 'ended' WHERE item_id = ?");
        $stmt->bind_param("i", $item_id);
        $stmt->execute();
        echo json_encode(['success' => true, 'message' => 'Auction ended.']);
    } else {
        echo json_encode(['success' => false, 'error' => 'Invalid action.']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
