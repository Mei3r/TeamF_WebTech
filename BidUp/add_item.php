<?php
// add_item.php
header('Content-Type: application/json');
require_once 'config.php';

$owner_id = $_POST['user_id'] ?? ''; // still get it from the session as 'user_id'
$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$category = trim($_POST['category'] ?? '');
$starting_price = $_POST['starting_price'] ?? 0;

if (empty($owner_id) || empty($title) || empty($description) || empty($category) || $starting_price <= 0) {
    echo json_encode(['success' => false, 'error' => 'Please complete all fields.']);
    exit;
}

// handle image upload
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

    // ✅ Corrected: use owner_id instead of user_id
    $stmt = $conn->prepare("
        INSERT INTO items (owner_id, title, description, category, starting_price, current_price, image_path, status, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ");
    $stmt->bind_param("isssddss", $owner_id, $title, $description, $category, $starting_price, $current_price, $image_path, $status);
    $stmt->execute();

    echo json_encode(['success' => true]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
