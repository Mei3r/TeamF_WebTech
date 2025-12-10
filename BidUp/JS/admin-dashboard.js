let user = JSON.parse(sessionStorage.getItem("user"));
let allItems = [];
let currentCategory = "all";

if (!user || user.user_type !== "admin") {
  alert("Access denied. Admins only.");
  window.location.href = "./login.html";
}

document.addEventListener("DOMContentLoaded", () => {
  fetchItems();
  document.getElementById("logoutBtn").addEventListener("click", logout);
  document
    .getElementById("statusFilter")
    .addEventListener("change", filterItems);
  document
    .getElementById("closeBiddersModal")
    .addEventListener("click", closeBiddersModal);

  document.querySelectorAll(".category-btn").forEach((btn) => {
    btn.addEventListener("click", function () {
      document
        .querySelectorAll(".category-btn")
        .forEach((b) => b.classList.remove("active"));
      this.classList.add("active");
      currentCategory = this.dataset.category;
      filterItems();
    });
  });
});

async function fetchItems() {
  try {
    const response = await fetch("PHP/admin_get_items.php");
    const data = await response.json();

    if (data.success) {
      allItems = data.data;
      displayItems(allItems);
    } else {
      document.getElementById("itemList").innerHTML = "<p>No items found.</p>";
    }
  } catch (err) {
    console.error("Error loading items:", err);
  }
}

function displayItems(items) {
  const container = document.getElementById("itemList");
  container.innerHTML = "";

  if (!items || items.length === 0) {
    container.innerHTML = "<p>No items available.</p>";
    return;
  }

  items.forEach((item) => {
    const card = document.createElement("div");
    card.classList.add("item-card");

    let actionButtons = "";

    if (item.status === "pending") {
      actionButtons = `
            <button onclick="updateItem(${item.item_id}, 'approve')" style="background: #28a745;">Approve</button>
            <button onclick="updateItem(${item.item_id}, 'reject')" style="background: #dc3545;">Reject</button>
          `;
    } else if (item.status === "active") {
      actionButtons = `
            <button onclick="updateItem(${item.item_id}, 'end')" style="background: #f39c12;">End Auction</button>
          `;
    }

    card.innerHTML = `
          ${
            item.image_path
              ? `<img src="${item.image_path}" alt="${item.title}">`
              : ""
          }
          <div class="item-header">
            <h3>${item.title}</h3>
            <span class="category-badge">${item.category}</span>
          </div>
          <div class="item-body">
            <p>${item.description}</p>
            <p>Current: ₱${parseFloat(item.current_price || 0).toFixed(2)}</p>
            <p>Status: ${item.status.toUpperCase()}</p>
            <p>Owner: ${item.full_name}</p>
          </div>

          <div class="admin-actions">
            ${actionButtons}
            <button onclick="viewBidders(${item.item_id})">View Bidders</button>
          </div>
        `;

    container.appendChild(card);
  });
}

async function updateItem(itemId, action) {
  const formData = new FormData();
  formData.append("item_id", itemId);
  formData.append("action", action);

  try {
    const response = await fetch("PHP/update_item_status.php", {
      method: "POST",
      body: formData,
    });
    const data = await response.json();

    if (data.success) {
      alert(data.message);
      fetchItems();
    } else {
      alert(data.error);
    }
  } catch (err) {
    alert("Server error while updating item.");
  }
}

function filterItems() {
  const statusFilter = document.getElementById("statusFilter").value;

  let filtered = allItems;

  if (statusFilter !== "all") {
    filtered = filtered.filter((item) => item.status === statusFilter);
  }

  if (currentCategory !== "all") {
    filtered = filtered.filter((item) => item.category === currentCategory);
  }

  displayItems(filtered);
}

function logout() {
  sessionStorage.clear();
  window.location.href = "./index.html";
}

async function viewBidders(itemId) {
  try {
    const response = await fetch(`PHP/get_bidders.php?item_id=${itemId}`);
    const data = await response.json();

    if (data.success) {
      if (data.data.length === 0) {
        alert("No bids yet for this item.");
        return;
      }

      showBiddersModal(data.item_title, data.data);
    } else {
      alert("Error: " + data.error);
    }
  } catch (err) {
    alert("Server error loading bidders.");
    console.error(err);
  }
}

function showBiddersModal(itemTitle, bidders) {
  const modal = document.getElementById("biddersModal");
  const modalTitle = document.getElementById("modalTitle");
  const content = document.getElementById("biddersContent");

  modalTitle.textContent = `Bidders for: ${itemTitle}`;

  let html = '<table style="width: 100%; border-collapse: collapse;">';
  html +=
    '<tr style="background: #667eea; color: white;"><th style="padding: 10px;">Rank</th><th style="padding: 10px;">Bidder</th><th style="padding: 10px;">Amount</th><th style="padding: 10px;">Date</th></tr>';

  bidders.forEach((b, index) => {
    const date = new Date(b.bid_time);
    const formattedDate = date.toLocaleString();
    const rank = index + 1;
    const rowColor = rank === 1 ? "background: #fff3cd;" : "";

    html += `
          <tr style="border-bottom: 1px solid #ddd; ${rowColor}">
            <td style="padding: 10px; text-align: center;">${
              rank === 1 ? 1 : rank
            }</td>
            <td style="padding: 10px;">${b.full_name} (${b.username})</td>
            <td style="padding: 10px; font-weight: bold;">₱${parseFloat(
              b.bid_amount
            ).toFixed(2)}</td>
            <td style="padding: 10px;">${formattedDate}</td>
          </tr>
        `;
  });

  html += "</table>";
  content.innerHTML = html;

  modal.classList.remove("hidden");
}

function closeBiddersModal() {
  document.getElementById("biddersModal").classList.add("hidden");
}
