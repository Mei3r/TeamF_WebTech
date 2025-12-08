<?php
session_start();
header('Content-Type: application/json');
require_once 'config.php';

if (!isset($_SESSION['user'])) {
    echo json_encode(['success' => false, 'error' => 'Not logged in']);
    exit;
}

$item_id = $_POST['item_id'] ?? '';
$payment_method = $_POST['payment_method'] ?? '';

if (empty($item_id) || empty($payment_method)) {
    echo json_encode(['success' => false, 'error' => 'Missing data']);
    exit;
}

$user_id = $_SESSION['user']['user_id'];

try {
    // ✅ Get item, owner, and winning bid info
    $query = $conn->prepare("
        SELECT i.item_id, i.title, i.owner_id, i.winner_id, i.current_price,
               u.full_name as owner_name, u.email as owner_email,
               b.bid_id, b.bid_amount
        FROM items i
        JOIN users u ON i.owner_id = u.user_id
        LEFT JOIN bids b ON b.item_id = i.item_id AND b.bidder_id = ?
        WHERE i.item_id = ? AND i.status = 'ended' AND i.winner_id = ?
        ORDER BY b.bid_amount DESC
        LIMIT 1
    ");
    $query->bind_param("iii", $user_id, $item_id, $user_id);
    $query->execute();
    $result = $query->get_result();
    $data = $result->fetch_assoc();

    if (!$data) {
        echo json_encode(['success' => false, 'error' => 'Invalid payment request']);
        exit;
    }

    // ✅ Check if payment already exists
    $checkPayment = $conn->prepare("SELECT payment_id FROM payments WHERE bid_id = ?");
    $checkPayment->bind_param("i", $data['bid_id']);
    $checkPayment->execute();
    if ($checkPayment->get_result()->fetch_assoc()) {
        echo json_encode(['success' => false, 'error' => 'Payment already processed']);
        exit;
    }

    // ✅ Create unique reference
    $transaction_ref = strtoupper($payment_method) . '-' . date('Ymd') . '-' . $item_id . '-' . rand(1000, 9999);

    // ✅ Insert payment
    $insertPayment = $conn->prepare("
        INSERT INTO payments 
        (bid_id, owner_id, owner_name, owner_email, owner_contact, item_title, payment_method, amount, payment_status, transaction_ref)
        VALUES (?, ?, ?, ?, 'N/A', ?, ?, ?, 'completed', ?)
    ");
    $payment_method_lower = strtolower($payment_method);
    $insertPayment->bind_param("iisssdss",
        $data['bid_id'],
        $data['owner_id'],
        $data['owner_name'],
        $data['owner_email'],
        $data['title'],
        $payment_method_lower,
        $data['bid_amount'],
        $transaction_ref
    );

    if (!$insertPayment->execute()) {
        echo json_encode(['success' => false, 'error' => $insertPayment->error]);
        exit;
    }

    // ✅ Insert notifications
    $notifOwner = "You have received payment of ₱" . number_format($data['bid_amount'], 2) .
                  " from " . $_SESSION['user']['full_name'] . " for your item '" . $data['title'] .
                  "' via " . strtoupper($payment_method) . ". Transaction ref: " . $transaction_ref;
    $insertNotifOwner = $conn->prepare("INSERT INTO notifications (user_id, item_id, message) VALUES (?, ?, ?)");
    $insertNotifOwner->bind_param("iis", $data['owner_id'], $item_id, $notifOwner);
    $insertNotifOwner->execute();

    $notifWinner = "Payment of ₱" . number_format($data['bid_amount'], 2) .
                   " for '" . $data['title'] . "' has been processed successfully via " .
                   strtoupper($payment_method) . ". Transaction ref: " . $transaction_ref;
    $insertNotifWinner = $conn->prepare("INSERT INTO notifications (user_id, item_id, message) VALUES (?, ?, ?)");
    $insertNotifWinner->bind_param("iis", $user_id, $item_id, $notifWinner);
    $insertNotifWinner->execute();

    echo json_encode([
        'success' => true,
        'message' => 'Payment processed successfully',
        'transaction_ref' => $transaction_ref,
        'owner_name' => $data['owner_name'],
        'owner_email' => $data['owner_email']
    ]);

} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
