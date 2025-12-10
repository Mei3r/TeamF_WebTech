<?php
header('Content-Type: application/json');
require_once 'config.php';

 $owner_id = $_POST['user_id'] ?? '';
 $title = trim($_POST['title'] ?? '');
 $description = trim($_POST['description'] ?? '');
 $category = trim($_POST['category'] ?? '');
 $starting_price = $_POST['starting_price'] ?? 0;

 $duration_hours = $_POST['duration_hours'] ?? 24; // Default to 24 if not sent

 $valid_categories = ['Electronics', 'Fashion', 'Collectibles', 'Art', 'Other'];

if (empty($owner_id) || empty($title) || empty($description) || empty($category) || $starting_price <= 0) {
    echo json_encode(['success' => false, 'error' => 'Please complete all fields.']);
    exit;
}

if (!in_array($category, $valid_categories)) {
    echo json_encode(['success' => false, 'error' => 'Invalid category selected.']);
    exit;
}

 $image_path = null;
if (!empty($_FILES['image']['name'])) {
    $target_dir = "uploads/";
    if (!is_dir($target_dir)) mkdir($target_dir);
    $file_name = time() . "_" . basename($_FILES['image']['name']);
    $target_file = $target_dir . $file_name;

    if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
        $image_path = $target_file;
    }
}

try {
    $current_price = $starting_price;
    $status = 'pending';

    $stmt = $conn->prepare("
    INSERT INTO items (owner_id, title, description, category, starting_price, current_price, image_path, status, duration_hours, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ");

    $stmt->bind_param("isssddssi", $owner_id, $title, $description, $category, $starting_price, $current_price, $image_path, $status, $duration_hours);
    $stmt->execute();

    echo json_encode(['success' => true]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>