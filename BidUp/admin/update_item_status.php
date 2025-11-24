<?php
// update_item_status.php - Updated with winner notification
session_start();
header('Content-Type: application/json');
require_once 'config.php';

$item_id = $_POST['item_id'] ?? '';
$action = $_POST['action'] ?? '';

if (empty($item_id) || empty($action)) {
    echo json_encode(['success' => false, 'error' => 'Missing data.']);
    exit;
}

if (!isset($_SESSION['user'])) {
    echo json_encode(['success' => false, 'error' => 'Not logged in.']);
    exit;
}

$current_user = $_SESSION['user'];

try {
    $itemCheck = $conn->prepare("SELECT owner_id, status, title FROM items WHERE item_id = ?");
    $itemCheck->bind_param("i", $item_id);
    $itemCheck->execute();
    $itemResult = $itemCheck->get_result();
    $itemData = $itemResult->fetch_assoc();

    if (!$itemData) {
        echo json_encode(['success' => false, 'error' => 'Item not found.']);
        exit;
    }

    if ($action === 'approve') {
        if ($current_user['user_type'] !== 'admin') {
            echo json_encode(['success' => false, 'error' => 'Permission denied.']);
            exit;
        }
        $stmt = $conn->prepare("UPDATE items SET status = 'active' WHERE item_id = ?");
        $stmt->bind_param("i", $item_id);
        $stmt->execute();
        echo json_encode(['success' => true, 'message' => 'Item approved and now active.']);
        
    } elseif ($action === 'reject') {
        if ($current_user['user_type'] !== 'admin') {
            echo json_encode(['success' => false, 'error' => 'Permission denied.']);
            exit;
        }
        $stmt = $conn->prepare("UPDATE items SET status = 'rejected' WHERE item_id = ?");
        $stmt->bind_param("i", $item_id);
        $stmt->execute();
        echo json_encode(['success' => true, 'message' => 'Item rejected successfully.']);
        
    } elseif ($action === 'end') {
        if ($current_user['user_type'] !== 'admin' && $itemData['owner_id'] != $current_user['user_id']) {
            echo json_encode(['success' => false, 'error' => 'Only the item owner can end this auction.']);
            exit;
        }
        
        if ($itemData['status'] !== 'active') {
            echo json_encode(['success' => false, 'error' => 'Auction is not active.']);
            exit;
        }
        
        // Get the highest bidder
        $bidQuery = $conn->prepare("
            SELECT bidder_id, bid_amount 
            FROM bids 
            WHERE item_id = ? 
            ORDER BY bid_amount DESC 
            LIMIT 1
        ");
        $bidQuery->bind_param("i", $item_id);
        $bidQuery->execute();
        $bidResult = $bidQuery->get_result();
        $winner = $bidResult->fetch_assoc();
        
        if ($winner) {
            // End auction and set winner
            $updateStmt = $conn->prepare("
                UPDATE items 
                SET status = 'ended', winner_id = ?, manually_ended = 1 
                WHERE item_id = ?
            ");
            $updateStmt->bind_param("ii", $winner['bidder_id'], $item_id);
            $updateStmt->execute();
            
            // Notify winner
            $winnerMsg = "🎉 Congratulations! You won the auction for '" . $itemData['title'] . 
                        "' with a bid of ₱" . number_format($winner['bid_amount'], 2) . 
                        ". The owner has ended the bidding. Please proceed to payment.";
            $notifWinner = $conn->prepare("INSERT INTO notifications (user_id, item_id, message) VALUES (?, ?, ?)");
            $notifWinner->bind_param("iis", $winner['bidder_id'], $item_id, $winnerMsg);
            $notifWinner->execute();
            
            // Notify all other bidders they didn't win
            $otherBiddersQuery = $conn->prepare("
                SELECT DISTINCT bidder_id 
                FROM bids 
                WHERE item_id = ? AND bidder_id != ?
            ");
            $otherBiddersQuery->bind_param("ii", $item_id, $winner['bidder_id']);
            $otherBiddersQuery->execute();
            $otherBiddersResult = $otherBiddersQuery->get_result();
            
            $loserMsg = "The auction for '" . $itemData['title'] . "' has ended. Unfortunately, you did not win this auction.";
            while ($bidder = $otherBiddersResult->fetch_assoc()) {
                $notifLoser = $conn->prepare("INSERT INTO notifications (user_id, item_id, message) VALUES (?, ?, ?)");
                $notifLoser->bind_param("iis", $bidder['bidder_id'], $item_id, $loserMsg);
                $notifLoser->execute();
            }
            
            echo json_encode([
                'success' => true, 
                'message' => 'Auction ended successfully. Winner has been notified.',
                'winner_id' => $winner['bidder_id']
            ]);
        } else {
            // No bids, just end the auction
            $updateStmt = $conn->prepare("
                UPDATE items 
                SET status = 'ended', manually_ended = 1 
                WHERE item_id = ?
            ");
            $updateStmt->bind_param("i", $item_id);
            $updateStmt->execute();
            
            echo json_encode([
                'success' => true, 
                'message' => 'Auction ended. No bids were placed.'
            ]);
        }
        
    } else {
        echo json_encode(['success' => false, 'error' => 'Invalid action.']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>